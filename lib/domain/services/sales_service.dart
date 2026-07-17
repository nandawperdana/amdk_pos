import 'package:drift/drift.dart';

import '../../data/database/database.dart';

class SaleLine {
  final int productId;
  final int qtyBase; // dalam satuan dasar
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

  /// Catat 1 transaksi penjualan.
  /// SEMUA ditulis dalam SATU transaksi DB agar konsisten:
  /// header + item + kartu stok (keluar) + buku kas (masuk).
  ///
  /// Untuk penjualan galon, panggil juga GalonService setelah ini
  /// dengan saleId yang dikembalikan (air lewat sini, wadah lewat sana).
  Future<int> recordSale({
    required List<SaleLine> lines,
    int? customerId,
    String paymentMethod = 'tunai',
    String account = 'kas',
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

        // Kartu stok: stok KELUAR (negatif).
        await db.into(db.stockMovements).insert(
              StockMovementsCompanion.insert(
                productId: l.productId,
                type: 'penjualan',
                qtyBase: -l.qtyBase,
                refType: const Value('sale'),
                refId: Value(saleId),
              ),
            );
      }

      // Buku kas: uang MASUK (untuk penjualan tunai/qris/transfer).
      // Untuk penjualan kredit (piutang), lewati baris ini dan catat
      // pelunasan nanti — sesuaikan saat menambah fitur piutang di Fase 2.
      await db.into(db.cashEntries).insert(
            CashEntriesCompanion.insert(
              direction: 'masuk',
              amount: total,
              category: 'penjualan',
              account: Value(account),
              refType: const Value('sale'),
              refId: Value(saleId),
            ),
          );

      return saleId;
    });
  }
}
