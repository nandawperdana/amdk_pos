import 'package:drift/drift.dart';

import '../../data/database/database.dart';

/// A party (customer or supplier) with an outstanding balance.
class PartyBalance {
  final int id;
  final String name;
  final double balance; // still owed (> 0)
  const PartyBalance(
      {required this.id, required this.name, required this.balance});
}

/// Receivables (customers owe us) & payables (we owe suppliers).
///
/// No new tables: a running per-party tab is DERIVED, like every other
/// balance. Never mutates old rows — a payment is a NEW cash row.
///   receivable(customer) = SUM(credit sales) - SUM(receivable_payment in)
///   debt(supplier)       = SUM(debt purchases) - SUM(debt_payment out)
class CreditService {
  final AppDatabase db;
  CreditService(this.db);

  // -------------------------------------------------------------------------
  // Receivables (customer owes us)
  // -------------------------------------------------------------------------

  Future<double> receivableBalance(int customerId) async {
    final sales = await (db.select(db.sales)
          ..where((s) =>
              s.customerId.equals(customerId) &
              s.paymentStatus.equals('receivable')))
        .get();
    final credit = sales.fold<double>(0, (sum, s) => sum + s.totalAmount);

    final payments = await (db.select(db.cashEntries)
          ..where((c) =>
              c.category.equals('receivable_payment') &
              c.refType.equals('customer') &
              c.refId.equals(customerId)))
        .get();
    final paid = payments.fold<double>(0, (sum, c) => sum + c.amount);

    return credit - paid;
  }

  /// Customers with an outstanding receivable (> 0), by name.
  Future<List<PartyBalance>> customersWithReceivable() async {
    final customers = await (db.select(db.customers)
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
    final out = <PartyBalance>[];
    for (final c in customers) {
      final bal = await receivableBalance(c.id);
      if (bal > 0) {
        out.add(PartyBalance(id: c.id, name: c.name, balance: bal));
      }
    }
    return out;
  }

  /// Record money received against a customer's tab. Cash IN, not revenue
  /// (revenue was already booked at sale time).
  Future<void> recordReceivablePayment({
    required int customerId,
    required double amount,
    String account = 'cash',
    String? note,
  }) =>
      db.into(db.cashEntries).insert(
            CashEntriesCompanion.insert(
              direction: 'in',
              amount: amount,
              category: 'receivable_payment',
              account: Value(account),
              refType: const Value('customer'),
              refId: Value(customerId),
              note: Value(note),
            ),
          );

  // -------------------------------------------------------------------------
  // Payables (we owe suppliers)
  // -------------------------------------------------------------------------

  Future<double> debtBalance(int supplierId) async {
    final purchases = await (db.select(db.purchases)
          ..where((p) =>
              p.supplierId.equals(supplierId) &
              p.paymentStatus.equals('debt')))
        .get();
    final debt = purchases.fold<double>(0, (sum, p) => sum + p.totalAmount);

    final payments = await (db.select(db.cashEntries)
          ..where((c) =>
              c.category.equals('debt_payment') &
              c.refType.equals('supplier') &
              c.refId.equals(supplierId)))
        .get();
    final paid = payments.fold<double>(0, (sum, c) => sum + c.amount);

    return debt - paid;
  }

  /// Suppliers we still owe (> 0), by name.
  Future<List<PartyBalance>> suppliersWithDebt() async {
    final suppliers = await (db.select(db.suppliers)
          ..orderBy([(s) => OrderingTerm.asc(s.name)]))
        .get();
    final out = <PartyBalance>[];
    for (final s in suppliers) {
      final bal = await debtBalance(s.id);
      if (bal > 0) {
        out.add(PartyBalance(id: s.id, name: s.name, balance: bal));
      }
    }
    return out;
  }

  /// Record a payment against a supplier's debt. Cash OUT (not a new expense —
  /// the goods/stock were already booked at purchase time).
  Future<void> recordDebtPayment({
    required int supplierId,
    required double amount,
    String account = 'cash',
    String? note,
  }) =>
      db.into(db.cashEntries).insert(
            CashEntriesCompanion.insert(
              direction: 'out',
              amount: amount,
              category: 'debt_payment',
              account: Value(account),
              refType: const Value('supplier'),
              refId: Value(supplierId),
              note: Value(note),
            ),
          );
}
