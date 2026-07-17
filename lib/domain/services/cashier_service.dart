import 'package:drift/drift.dart';

import '../../data/database/database.dart';

class CashierService {
  final AppDatabase db;
  CashierService(this.db);

  /// Kas awal shift = hitungan fisik dari tutup kasir terakhir (atau 0
  /// kalau belum pernah tutup kasir).
  Future<double> openingBalance({String account = 'kas'}) async {
    final last = await (db.select(db.cashierClosings)
          ..where((c) => c.account.equals(account))
          ..orderBy([(c) => OrderingTerm.desc(c.closedAt)])
          ..limit(1))
        .getSingleOrNull();
    return last?.physicalCount ?? 0;
  }

  /// Tutup kasir: catat snapshot (saldo sistem vs hitungan fisik). Kalau
  /// beda, tambahkan baris penyesuaian di CashEntries — TIDAK PERNAH
  /// mengubah baris lama — supaya saldo berjalan berikutnya ikut uang
  /// fisik yang benar-benar ada di laci.
  Future<int> recordClosing({
    required double physicalCount,
    String account = 'kas',
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
                direction: diff > 0 ? 'masuk' : 'keluar',
                amount: diff.abs(),
                category: 'penyesuaian',
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
