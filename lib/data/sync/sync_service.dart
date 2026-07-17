import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/database.dart';

/// Sinkronisasi offline-first, PUSH-ONLY dari kasir ke Supabase (Postgres).
///
/// Kenapa mudah & bebas konflik: setiap tabel data bersifat append-only dan
/// barisnya IMMUTABLE (tak pernah di-UPDATE/DELETE). Jadi sinkronisasi cukup
/// mengirim baris baru — cukup lacak batas atas (lastId) per tabel via
/// [SyncCursors]. Tak perlu flag per-baris, tak perlu memutasi baris ledger.
///
/// Idempotent: mirror di Postgres ber-PK `(device_id, id)`. Upsert dengan
/// `ignoreDuplicates` → kirim ulang aman (on conflict do nothing). id lokal
/// unik per device; `device_id` memisahkan device kalau nanti multi-toko.
///
/// HP owner hanya MEMBACA laporan dari Postgres → tak ada tulis bersamaan.
///
/// Setup Postgres: lihat `doc/supabase_setup.sql`.
class SyncService {
  final AppDatabase db;
  final String deviceId;
  final SupabaseClient? client; // null → sync nonaktif (offline saja)

  SyncService(this.db, {required this.deviceId, this.client});

  bool get enabled => client != null;

  /// Tabel yang disinkronkan (nama SQL snake_case = nama tabel Postgres).
  /// SyncCursors sengaja TIDAK ikut (murni metadata lokal).
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
        db.galonLedger,
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

  /// Baris yang belum tersinkron per tabel: id > cursor. TANPA jaringan —
  /// bisa diuji sendiri. Batasi [limit] baris per tabel per putaran.
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

  /// Kirim semua baris tertunda ke Supabase, majukan cursor per tabel.
  /// No-op kalau sync nonaktif. Aman diulang (idempotent).
  /// Return jumlah baris terkirim.
  Future<int> pushPending() async {
    final c = client;
    if (c == null) return 0;

    var pushed = 0;
    for (final table in _syncedTables) {
      final name = table.actualTableName;
      // Loop batch sampai habis (tabel besar tak dikirim sekaligus).
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
