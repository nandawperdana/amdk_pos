import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/database.dart';

/// Offline-first, PUSH-ONLY sync from the cashier to Supabase (Postgres).
///
/// Why it is easy & conflict-free: every data table is append-only and its
/// rows are IMMUTABLE (never UPDATE/DELETE). So sync just sends new rows —
/// track the high-water mark (lastId) per table via [SyncCursors]. No per-row
/// flag, no mutation of ledger rows.
///
/// Idempotent: the Postgres mirror has PK `(device_id, id)`. Upsert with
/// `ignoreDuplicates` → re-sending is safe (on conflict do nothing). The local
/// id is unique per device; `device_id` separates devices for future
/// multi-store.
///
/// The owner phone only READS reports from Postgres → no concurrent writes.
///
/// Postgres setup: see `doc/supabase_setup.sql`.
class SyncService {
  final AppDatabase db;
  final String deviceId;
  final SupabaseClient? client; // null → sync disabled (offline only)

  SyncService(this.db, {required this.deviceId, this.client});

  bool get enabled => client != null;

  /// Synced tables (snake_case SQL name = Postgres table name).
  /// SyncCursors is intentionally excluded (pure local metadata).
  List<TableInfo> get _syncedTables => [
        db.products,
        db.suppliers,
        db.customers,
        db.purchases,
        db.purchaseItems,
        db.sales,
        db.saleItems,
        db.stockMovements,
        db.cashEntries,
        db.gallonLedger,
        db.cashierClosings,
      ];

  Future<int> _cursor(String table) async {
    final row = await (db.select(db.syncCursors)
          ..where((t) => t.entity.equals(table)))
        .getSingleOrNull();
    return row?.lastId ?? 0;
  }

  Future<void> _setCursor(String table, int lastId) =>
      db.into(db.syncCursors).insertOnConflictUpdate(
          SyncCursorsCompanion.insert(entity: table, lastId: Value(lastId)));

  /// Unsynced rows per table: id > cursor. NO network — self-testable.
  /// Caps at [limit] rows per table per round.
  Future<List<Map<String, dynamic>>> pendingRows(TableInfo table,
      {int limit = 500}) async {
    final name = table.actualTableName;
    final cursor = await _cursor(name);
    final rows = await db.customSelect(
      'SELECT * FROM "$name" WHERE id > ? ORDER BY id LIMIT ?',
      variables: [Variable.withInt(cursor), Variable.withInt(limit)],
    ).get();
    return rows.map((r) => r.data).toList();
  }

  /// Push all pending rows to Supabase, advance the per-table cursor.
  /// No-op if sync is disabled. Safe to retry (idempotent).
  /// Returns the number of rows pushed.
  Future<int> pushPending() async {
    final c = client;
    if (c == null) return 0;

    var pushed = 0;
    for (final table in _syncedTables) {
      final name = table.actualTableName;
      // Batch loop until drained (large tables not sent all at once).
      while (true) {
        final rows = await pendingRows(table);
        if (rows.isEmpty) break;

        final payload = [
          for (final r in rows) {...r, 'device_id': deviceId},
        ];
        await c.from(name).upsert(payload,
            onConflict: 'device_id,id', ignoreDuplicates: true);

        final maxId = rows.map((r) => r['id'] as int).reduce((a, b) => a > b ? a : b);
        await _setCursor(name, maxId);
        pushed += rows.length;

        if (rows.length < 500) break;
      }
    }
    return pushed;
  }
}
