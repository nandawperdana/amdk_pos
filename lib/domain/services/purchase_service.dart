import 'package:drift/drift.dart';

import '../../data/database/database.dart';

class PurchaseLine {
  final int productId;
  final int qtyBase; // in base units
  final double price; // buy price per base unit
  const PurchaseLine({
    required this.productId,
    required this.qtyBase,
    required this.price,
  });
  double get subtotal => qtyBase * price;
}

class PurchaseService {
  final AppDatabase db;
  PurchaseService(this.db);

  /// Record one purchase/restock. Atomic: header + items + stock card (in) +
  /// cash book (out). The inverse of SalesService.recordSale.
  ///
  /// To restock filled gallons with an empty swap, also call
  /// GallonService.recordRestockExchange — water goes here, the container
  /// goes there.
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
      }

      // Cash book: money OUT — only when paid. If debt, skip and record the
      // payment later when the debt feature is added (Phase 2).
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
