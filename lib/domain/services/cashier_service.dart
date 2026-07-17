import 'package:drift/drift.dart';

import '../../data/database/database.dart';

class CashierService {
  final AppDatabase db;
  CashierService(this.db);

  /// Opening cash for the shift = physical count from the last cashier closing
  /// (or 0 if there has never been a closing).
  Future<double> openingBalance({String account = 'cash'}) async {
    final last = await (db.select(db.cashierClosings)
          ..where((c) => c.account.equals(account))
          ..orderBy([(c) => OrderingTerm.desc(c.closedAt)])
          ..limit(1))
        .getSingleOrNull();
    return last?.physicalCount ?? 0;
  }

  /// Cashier closing: record a snapshot (system balance vs physical count).
  /// If they differ, add an adjustment row in CashEntries — NEVER edit an old
  /// row — so the next running balance follows the actual cash in the till.
  Future<int> recordClosing({
    required double physicalCount,
    String account = 'cash',
    String? note,
  }) async {
    return db.transaction(() async {
      final systemBalance = await db.cashBalance(account: account);
      final diff = physicalCount - systemBalance;

      final id = await db.into(db.cashierClosings).insert(
            CashierClosingsCompanion.insert(
              account: Value(account),
              systemBalance: systemBalance,
              physicalCount: physicalCount,
              difference: diff,
              note: Value(note),
            ),
          );

      if (diff != 0) {
        await db.into(db.cashEntries).insert(
              CashEntriesCompanion.insert(
                direction: diff > 0 ? 'in' : 'out',
                amount: diff.abs(),
                category: 'adjustment',
                account: Value(account),
                refType: const Value('closing'),
                refId: Value(id),
                note: const Value('Penyesuaian tutup kasir'),
              ),
            );
      }

      return id;
    });
  }
}
