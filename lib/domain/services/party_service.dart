import 'package:drift/drift.dart';

import '../../data/database/database.dart';

/// Customers & suppliers (the two "parties" a shop transacts with).
/// A thin home for party writes so the UI never touches the DB directly.
class PartyService {
  final AppDatabase db;
  PartyService(this.db);

  Future<int> addCustomer(String name, {String? phone}) =>
      db.into(db.customers).insert(
          CustomersCompanion.insert(name: name, phone: Value(phone)));

  Future<int> addSupplier(String name, {String? phone}) =>
      db.into(db.suppliers).insert(
          SuppliersCompanion.insert(name: name, phone: Value(phone)));
}
