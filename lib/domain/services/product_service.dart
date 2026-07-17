import 'package:drift/drift.dart';

import '../../data/database/database.dart';

/// Master products = master data, NOT a ledger → UPDATE is allowed.
/// (The stock/cash/gallon ledgers stay append-only.)
class ProductService {
  final AppDatabase db;
  ProductService(this.db);

  /// Add (id null) or edit (id set) a product.
  Future<void> save(ProductsCompanion values, {int? id}) async {
    if (id == null) {
      await db.into(db.products).insert(values);
    } else {
      await (db.update(db.products)..where((t) => t.id.equals(id)))
          .write(values);
    }
  }

  /// Deactivate/reactivate a product (soft-delete). Does not remove the row —
  /// old transaction history still references this product.
  Future<void> setActive(int id, bool active) =>
      (db.update(db.products)..where((t) => t.id.equals(id)))
          .write(ProductsCompanion(active: Value(active)));
}
