import 'package:drift/drift.dart';

import '../../data/database/database.dart';
import 'gallon_service.dart';

class PurchaseLine {
  final int productId;
  final int qtyBase; // in base units
  final double price; // buy price per base unit
  /// Gallon only: restock filled containers by swapping empties.
  final bool swapEmpty;
  /// Exact line total when bought by the pack (dus), so cash-out matches the
  /// invoice instead of qtyBase × a rounded per-base price. Null = derive.
  final double? _subtotal;
  const PurchaseLine({
    required this.productId,
    required this.qtyBase,
    required this.price,
    this.swapEmpty = false,
    double? subtotal,
  }) : _subtotal = subtotal;
  double get subtotal => _subtotal ?? qtyBase * price;
}

class PurchaseService {
  final AppDatabase db;
  final GallonService gallon;
  PurchaseService(this.db, this.gallon);

  /// Record one purchase/restock ATOMICALLY: header + items + stock card (in)
  /// + cash book (out) + gallon container swap — all in one transaction.
  /// The inverse of SalesService.recordSale.
  Future<int> recordPurchase({
    required List<PurchaseLine> lines,
    int? supplierId,
    String paymentStatus = 'paid', // 'paid' | 'debt'
    String account = 'cash',
    String? note,
  }) async {
    final total = lines.fold<double>(0, (sum, l) => sum + l.subtotal);

    return db.transaction(() async {
      final purchaseId = await db.into(db.purchases).insert(
            PurchasesCompanion.insert(
              supplierId: Value(supplierId),
              totalAmount: Value(total),
              paymentStatus: Value(paymentStatus),
              note: Value(note),
            ),
          );

      for (final l in lines) {
        await db.into(db.purchaseItems).insert(
              PurchaseItemsCompanion.insert(
                purchaseId: purchaseId,
                productId: l.productId,
                qtyBase: l.qtyBase,
                price: l.price,
                subtotal: l.subtotal,
              ),
            );

        // Stock card: stock IN (positive).
        await db.into(db.stockMovements).insert(
              StockMovementsCompanion.insert(
                productId: l.productId,
                type: 'purchase',
                qtyBase: l.qtyBase,
                refType: const Value('purchase'),
                refId: Value(purchaseId),
              ),
            );

        // Filled gallon containers via empty swap (same transaction).
        if (l.swapEmpty) {
          await gallon.recordRestockExchange(qty: l.qtyBase);
        }
      }

      // Cash book: money OUT — only when paid. If debt, skip and record the
      // payment later via CreditService.recordDebtPayment.
      if (paymentStatus == 'paid') {
        await db.into(db.cashEntries).insert(
              CashEntriesCompanion.insert(
                direction: 'out',
                amount: total,
                category: 'purchase',
                account: Value(account),
                refType: const Value('purchase'),
                refId: Value(purchaseId),
              ),
            );
      }

      return purchaseId;
    });
  }
}
