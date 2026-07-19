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
  const SaleLine({
    required this.productId,
    required this.qtyBase,
    required this.price,
    this.gallonMode = GallonSaleMode.none,
  });
  double get subtotal => qtyBase * price;
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
        await db.into(db.saleItems).insert(
              SaleItemsCompanion.insert(
                saleId: saleId,
                productId: l.productId,
                qtyBase: l.qtyBase,
                price: l.price,
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
}
