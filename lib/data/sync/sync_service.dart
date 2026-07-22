import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/database.dart';

/// Offline-first sync between two phones and Supabase (Postgres).
///
/// OWNERSHIP IS SPLIT so each logical row has exactly ONE writer — that
/// single-writer property is what keeps sync conflict-free:
///   - LEDGER tables (sales, cash, stock, gallon, …) are OWNED BY THE CASHIER
///     phone: it records transactions, pushes them up, the owner pulls them
///     down for reports.
///   - MASTER tables (products, customers, suppliers) are OWNED BY THE OWNER
///     phone: the owner edits prices/active, pushes them up, the cashier
///     pulls them down. The cashier is read-only for master.
///
/// So each phone runs BOTH directions, but only its own half (see the
/// `ledger`/`master` flags on [pushPending]/[pullUpdates]):
///   - Cashier: push ledger, pull master.
///   - Owner:   push master, pull ledger.
///
/// Table strategies:
///   - LEDGER: append-only, IMMUTABLE rows. Push/pull cursor-based, tracked by
///     a per-table high-water mark in [SyncCursors] (push cursor `<table>`,
///     pull cursor `pull_<table>` — distinct so both live in the same table).
///     Upsert `ignoreDuplicates` — re-sending is safe.
///   - MASTER: MUTABLE (price edited, product soft-deleted). A high-water
///     cursor would never re-send an edited row, so master pushes ALL rows
///     each sync with a MERGE upsert, and pulls a full replace. Small tables.
/// `device_id` is stripped on pull — the local schema lacks that column, it
/// only exists in the Postgres mirror to separate devices.
///
/// Idempotent both ways: the Postgres mirror has PK `(device_id, id)`.
///
/// Postgres setup: see `doc/supabase_setup.sql`.
class SyncService {
  final AppDatabase db;
  final String deviceId;
  final SupabaseClient? client; // null → sync disabled (offline only)
  final SharedPreferences? prefs; // last-auto-sync bookkeeping (optional)

  SyncService(this.db, {required this.deviceId, this.client, this.prefs});

  bool get enabled => client != null;

  static const _lastSyncKey = 'last_sync_at';

  DateTime? get lastSyncAt {
    final ms = prefs?.getInt(_lastSyncKey);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  /// True once a day has passed since the last successful push (or it never
  /// ran) — checked on app launch so the cashier device stays current
  /// without a background service/WorkManager.
  bool get dueForAutoSync {
    final last = lastSyncAt;
    return last == null ||
        DateTime.now().difference(last) >= const Duration(hours: 24);
  }

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

  /// Push rows to Supabase. No-op if sync is disabled. Safe to retry
  /// (idempotent). Returns the number of rows pushed.
  ///
  /// [ledger]/[master] gate which half runs so ownership can be split:
  /// the cashier pushes ledger only (`master: false`), the owner pushes
  /// master only (`ledger: false`). Single writer per table type keeps the
  /// push conflict-free.
  Future<int> pushPending({bool ledger = true, bool master = true}) async {
    final c = client;
    if (c == null) return 0;

    var pushed = 0;

    // Ledgers: cursor-based, ignore duplicates (immutable rows).
    if (ledger) {
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
    }

    // Master data: full merge upsert (edits overwrite the cloud copy).
    if (master) {
      for (final table in _masterTables) {
        final rows = await allRows(table);
        if (rows.isEmpty) continue;
        await c.from(table.actualTableName).upsert(_stamp(rows),
            onConflict: 'device_id,id'); // merge (default) → overwrite
        pushed += rows.length;
      }
    }

    await prefs?.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
    return pushed;
  }

  /// Pull updates from Supabase into the LOCAL mirror — for the owner's
  /// device, which never writes transactional data itself. Master tables:
  /// full replace each pull (small, may have edits). Ledger tables:
  /// cursor-based, append-only (immutable rows, safe to just insert new
  /// ones). No-op if sync is disabled. Returns the number of rows pulled.
  ///
  /// [ledger]/[master] gate which half runs (mirror of [pushPending]): the
  /// cashier pulls master only (`ledger: false`) to receive the owner's
  /// price edits, the owner pulls ledger only (`master: false`) to receive
  /// the cashier's sales for reports.
  Future<int> pullUpdates({bool ledger = true, bool master = true}) async {
    final c = client;
    if (c == null) return 0;

    var pulled = 0;

    // Master data: full replace (edits/soft-deletes must propagate down too).
    if (master) {
      for (final table in _masterTables) {
        final rows = await c.from(table.actualTableName).select();
        for (final row in rows) {
          await _upsertLocal(table, row);
        }
        pulled += rows.length;
      }
    }

    // Ledgers: cursor-based, paginated, ascending.
    if (ledger) {
      for (final table in _ledgerTables) {
        final name = table.actualTableName;
        final cursorKey = 'pull_$name';
        while (true) {
          final cursor = await _cursor(cursorKey);
          final rows = await c
              .from(name)
              .select()
              .gt('id', cursor)
              .order('id')
              .limit(500);
          if (rows.isEmpty) break;
          for (final row in rows) {
            await _upsertLocal(table, row);
          }
          final maxId =
              rows.map((r) => _asInt(r['id'])).reduce((a, b) => a > b ? a : b);
          await _setCursor(cursorKey, maxId);
          pulled += rows.length;
          if (rows.length < 500) break;
        }
      }
    }

    await prefs?.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
    return pulled;
  }

  /// Postgres sends bigint columns (id, epoch dates) as JSON strings to
  /// avoid precision loss — coerce them back to int before binding into
  /// SQLite (which stores the very same raw encoding locally).
  dynamic _coerce(dynamic v) => v is String && int.tryParse(v) != null
      ? int.parse(v)
      : v;

  int _asInt(dynamic v) => v is int ? v : int.parse(v as String);

  /// Insert-or-replace one pulled row into the local table, stripping
  /// `device_id` (only exists in the Postgres mirror) and coercing
  /// bigint-as-string values back to int.
  Future<void> _upsertLocal(TableInfo table, Map<String, dynamic> row) async {
    final data = Map<String, dynamic>.from(row)..remove('device_id');
    final columns = data.keys.map((k) => '"$k"').join(', ');
    final placeholders = List.filled(data.length, '?').join(', ');
    await db.customStatement(
      'INSERT OR REPLACE INTO "${table.actualTableName}" ($columns) VALUES ($placeholders)',
      data.values.map(_coerce).toList(),
    );
  }
}
