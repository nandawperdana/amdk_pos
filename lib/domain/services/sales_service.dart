import 'package:drift/drift.dart';

import '../../data/database/database.dart';

class SaleLine {
  final int productId;
  final int qtyBase; // in base units
  final double price; // per base unit
  const SaleLine({
    required this.productId,
    required this.qtyBase,
    required this.price,
  });
  double get subtotal => qtyBase * price;
}

class SalesService {
  final AppDatabase db;
  SalesService(this.db);

  /// Record one sale.
  /// EVERYTHING is written in a SINGLE DB transaction for consistency:
  /// header + items + stock card (out) + cash book (in).
  ///
  /// For gallon sales, also call GallonService afterwards with the returned
  /// saleId (water goes through here, the container through there).
  Future<int> recordSale({
    required List<SaleLine> lines,
    int? customerId,
    String paymentMethod = 'cash',
    String account = 'cash',
    String? note,
  }) async {
    final total = lines.fold<double>(0, (sum, l) => sum + l.subtotal);

    return db.transaction(() async {
      final saleId = await db.into(db.sales).insert(
            SalesCompanion.insert(
              customerId: Value(customerId),
              totalAmount: Value(total),
              paymentMethod: Value(paymentMethod),
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
      }

      // Cash book: money IN (for cash/qris/transfer sales).
      // For credit sales (receivable), skip this row and record the payment
      // later — adjust when the receivables feature lands in Phase 2.
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

      return saleId;
    });
  }
}
