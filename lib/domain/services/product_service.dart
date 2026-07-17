import 'package:drift/drift.dart';

import '../../data/database/database.dart';

/// Master produk = master data, BUKAN ledger → UPDATE boleh.
/// (Ledger stok/kas/galon tetap append-only.)
class ProductService {
  final AppDatabase db;
  ProductService(this.db);

  /// Tambah (id null) atau edit (id ada) produk.
  Future<void> save(ProductsCompanion values, {int? id}) async {
    if (id == null) {
      await db.into(db.products).insert(values);
    } else {
      await (db.update(db.products)..where((t) => t.id.equals(id)))
          .write(values);
    }
  }

  /// Nonaktifkan/aktifkan produk (soft-delete). Tidak menghapus baris —
  /// riwayat transaksi lama tetap merujuk ke produk ini.
  Future<void> setActive(int id, bool active) =>
      (db.update(db.products)..where((t) => t.id.equals(id)))
          .write(ProductsCompanion(active: Value(active)));
}
