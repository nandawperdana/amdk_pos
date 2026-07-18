import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/database.dart';

/// Offline-first, PUSH-ONLY sync from the cashier to Supabase (Postgres).
///
/// Two kinds of table need two strategies:
///
/// * LEDGER tables are append-only with IMMUTABLE rows. Sync just sends new
///   rows, tracked by a per-table high-water mark (lastId) in [SyncCursors].
///   Upsert with `ignoreDuplicates` (on conflict do nothing) — re-sending is
///   safe. No per-row flag, no mutation of ledger rows.
///
/// * MASTER tables (products, customers, suppliers) are MUTABLE — a product's
///   price is edited, a product is soft-deleted (active=0). A high-water
///   cursor would never re-send an edited row, so the cloud would go stale.
///   These are small, so we re-push ALL rows every sync with a MERGE upsert
///   (overwrite on conflict).
///
/// Idempotent: the Postgres mirror has PK `(device_id, id)`. The local id is
/// unique per device; `device_id` separates devices for future multi-store.
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

  /// Append-only ledgers: cursor-based, ignore-duplicates (rows immutable).
  List<TableInfo> get _ledgerTables => [
        db.purchases,
        db.purchaseItems,
        db.sales,
        db.saleItems,
        db.stockMovements,
        db.cashEntries,
        db.gallonLedger,
        db.cashierClosings,
      ];

  /// Mutable master data: full merge upsert each sync (edits must propagate).
  List<TableInfo> get _masterTables => [
        db.products,
        db.suppliers,
        db.customers,
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

  /// Unsynced ledger rows: id > cursor. NO network — self-testable.
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

  /// All rows of a master table (for full re-push).
  Future<List<Map<String, dynamic>>> allRows(TableInfo table) async {
    final rows =
        await db.customSelect('SELECT * FROM "${table.actualTableName}"').get();
    return rows.map((r) => r.data).toList();
  }

  List<Map<String, dynamic>> _stamp(List<Map<String, dynamic>> rows) =>
      [for (final r in rows) {...r, 'device_id': deviceId}];

  /// Push pending ledger rows + refresh all master rows to Supabase.
  /// No-op if sync is disabled. Safe to retry (idempotent).
  /// Returns the number of rows pushed.
  Future<int> pushPending() async {
    final c = client;
    if (c == null) return 0;

    var pushed = 0;

    // Ledgers: cursor-based, ignore duplicates (immutable rows).
    for (final table in _ledgerTables) {
      final name = table.actualTableName;
      while (true) {
        final rows = await pendingRows(table);
        if (rows.isEmpty) break;
        await c.from(name).upsert(_stamp(rows),
            onConflict: 'device_id,id', ignoreDuplicates: true);
        final maxId =
            rows.map((r) => r['id'] as int).reduce((a, b) => a > b ? a : b);
        await _setCursor(name, maxId);
        pushed += rows.length;
        if (rows.length < 500) break;
      }
    }

    // Master data: full merge upsert (edits overwrite the cloud copy).
    for (final table in _masterTables) {
      final rows = await allRows(table);
      if (rows.isEmpty) continue;
      await c.from(table.actualTableName).upsert(_stamp(rows),
          onConflict: 'device_id,id'); // merge (default) → overwrite
      pushed += rows.length;
    }

    return pushed;
  }
}
