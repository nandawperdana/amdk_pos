import 'package:drift/drift.dart';

import '../../data/database/database.dart';
import 'gallon_service.dart';

class SaleLine {
  final int productId;
  final int qtyBase; // in base units
  /// Per base unit. For a newCustomer gallon line, this already includes the
  /// container price (water + container, one price, no deposit).
  final double price;
  /// Gallon intent for this line (none for regular products).
  final GallonSaleMode gallonMode;
  /// Exact line total. Set when sold by the pack (dus) so the stored amount is
  /// the whole-pack price, not qtyBase × a rounded per-base price. Null =
  /// derive qtyBase × price (the common per-pcs case).
  final double? _subtotal;
  const SaleLine({
    required this.productId,
    required this.qtyBase,
    required this.price,
    this.gallonMode = GallonSaleMode.none,
    double? subtotal,
  }) : _subtotal = subtotal;
  double get subtotal => _subtotal ?? qtyBase * price;
}

class SalesService {
  final AppDatabase db;
  final GallonService gallon;
  SalesService(this.db, this.gallon);

  /// Record one sale ATOMICALLY in a single DB transaction:
  /// header + items + stock card (out) + cash book (in) + gallon container
  /// movements. Nothing can be left half-written — if any step fails, the
  /// whole sale rolls back.
  ///
  /// On credit (paymentStatus 'receivable'): the sale is still revenue and
  /// stock still goes out, but NO cash row is written — the customer owes
  /// it. Collect later via CreditService.recordReceivablePayment. Requires a
  /// customerId.
  Future<int> recordSale({
    required List<SaleLine> lines,
    int? customerId,
    String paymentMethod = 'cash',
    String paymentStatus = 'paid', // 'paid' | 'receivable'
    String account = 'cash',
    String? note,
  }) async {
    assert(paymentStatus != 'receivable' || customerId != null,
        'Credit sale needs a customerId');
    final total = lines.fold<double>(0, (sum, l) => sum + l.subtotal);

    return db.transaction(() async {
      final saleId = await db.into(db.sales).insert(
            SalesCompanion.insert(
              customerId: Value(customerId),
              totalAmount: Value(total),
              paymentMethod: Value(paymentMethod),
              paymentStatus: Value(paymentStatus),
              note: Value(note),
            ),
          );

      for (final l in lines) {
        // COGS via FIFO: units already sold before this line consume the
        // oldest lots, so this line's cost is the NEXT qty units in purchase
        // order. Computed BEFORE inserting this line's item so the sold-count
        // reflects only prior lines (incl earlier lines of this same sale).
        final soldBefore = await _soldQty(l.productId);
        final cogs = await _fifoCogs(l.productId, soldBefore, l.qtyBase);

        await db.into(db.saleItems).insert(
              SaleItemsCompanion.insert(
                saleId: saleId,
                productId: l.productId,
                qtyBase: l.qtyBase,
                price: l.price,
                cogs: Value(cogs),
                subtotal: l.subtotal,
              ),
            );

        // Stock card: stock OUT (negative).
        await db.into(db.stockMovements).insert(
              StockMovementsCompanion.insert(
                productId: l.productId,
                type: 'sale',
                qtyBase: -l.qtyBase,
                refType: const Value('sale'),
                refId: Value(saleId),
              ),
            );

        // Gallon container (same transaction) — water price already covers
        // the container for a newCustomer line (one price, no deposit).
        switch (l.gallonMode) {
          case GallonSaleMode.exchange:
            await gallon.recordExchange(
                qty: l.qtyBase, customerId: customerId, saleId: saleId);
          case GallonSaleMode.newCustomer:
            await gallon.recordNewGallonSale(
                qty: l.qtyBase, customerId: customerId, saleId: saleId);
          case GallonSaleMode.none:
            break;
        }
      }

      // Cash book: money IN — only for paid sales. Credit sales (receivable)
      // skip this row; the payment is recorded later via CreditService.
      if (paymentStatus != 'receivable') {
        await db.into(db.cashEntries).insert(
              CashEntriesCompanion.insert(
                direction: 'in',
                amount: total,
                category: 'sale',
                account: Value(account),
                refType: const Value('sale'),
                refId: Value(saleId),
              ),
            );
      }

      return saleId;
    });
  }

  /// Total base units of this product sold across ALL sales so far.
  Future<int> _soldQty(int productId) async {
    final sum = db.saleItems.qtyBase.sum();
    final row = await (db.selectOnly(db.saleItems)
          ..addColumns([sum])
          ..where(db.saleItems.productId.equals(productId)))
        .getSingle();
    return row.read(sum) ?? 0;
  }

  /// FIFO cost of `qty` units of a product, where `soldBefore` units have
  /// already been consumed from the oldest lots. Walks purchase lots in
  /// purchase order; units sold beyond everything ever purchased (stock gone
  /// negative) fall back to the product's master buy price.
  Future<double> _fifoCogs(int productId, int soldBefore, int qty) async {
    final lots = await (db.select(db.purchaseItems)
          ..where((i) => i.productId.equals(productId))
          ..orderBy([(i) => OrderingTerm.asc(i.id)]))
        .get();

    final start = soldBefore, end = soldBefore + qty;
    double cost = 0;
    var covered = 0; // units of [start,end) priced from a real lot
    var cursor = 0; // running cumulative purchased units (lot boundary)
    for (final lot in lots) {
      final lotStart = cursor, lotEnd = cursor + lot.qtyBase;
      cursor = lotEnd;
      final ovStart = start > lotStart ? start : lotStart;
      final ovEnd = end < lotEnd ? end : lotEnd;
      final overlap = ovEnd - ovStart;
      if (overlap > 0) {
        cost += overlap * lot.price;
        covered += overlap;
      }
    }

    final uncovered = qty - covered;
    if (uncovered > 0) {
      final p = await (db.select(db.products)
            ..where((t) => t.id.equals(productId)))
          .getSingleOrNull();
      cost += uncovered * (p?.buyPrice ?? 0);
    }
    return cost;
  }
}
