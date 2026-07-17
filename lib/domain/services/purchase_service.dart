import 'package:drift/drift.dart';

import '../../data/database/database.dart';

class PurchaseLine {
  final int productId;
  final int qtyBase; // dalam satuan dasar
  final double price; // harga beli per base unit
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

  /// Catat 1 pembelian/kulakan. Atomik: header + item + kartu stok (masuk) +
  /// buku kas (keluar). Kebalikan dari SalesService.recordSale.
  ///
  /// Untuk kulakan galon isi dengan tukar kosong, panggil juga
  /// GalonService.recordRestockExchange — air lewat sini, wadah lewat sana.
  Future<int> recordPurchase({
    required List<PurchaseLine> lines,
    int? supplierId,
    String paymentStatus = 'lunas', // 'lunas' | 'utang'
    String account = 'kas',
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

        // Kartu stok: stok MASUK (positif).
        await db.into(db.stockMovements).insert(
              StockMovementsCompanion.insert(
                productId: l.productId,
                type: 'pembelian',
                qtyBase: l.qtyBase,
                refType: const Value('purchase'),
                refId: Value(purchaseId),
              ),
            );
      }

      // Buku kas: uang KELUAR — hanya kalau lunas. Kalau utang, lewati dan
      // catat pelunasan nanti saat fitur utang ditambah (Fase 2).
      if (paymentStatus == 'lunas') {
        await db.into(db.cashEntries).insert(
              CashEntriesCompanion.insert(
                direction: 'keluar',
                amount: total,
                category: 'pembelian',
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
