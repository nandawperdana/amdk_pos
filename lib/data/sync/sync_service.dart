import '../database/database.dart';

/// Sinkronisasi offline-first, PUSH-ONLY dari kasir.
///
/// Kenapa mudah & bebas konflik:
/// semua data operasional berupa ledger append-only (StockMovements,
/// CashEntries, GalonLedger) + header/item transaksi yang TIDAK PERNAH
/// di-UPDATE. Jadi kasir cukup mengirim baris baru ke cloud, tidak pernah
/// mengubah baris lama. HP owner hanya MEMBACA laporan → tidak ada
/// tulis-menulis bersamaan yang bisa bentrok.
///
/// Alur:
///  - Kasir (device utama) = sumber kebenaran, jalan penuh saat offline.
///  - Saat online, kirim baris yang belum tersinkron ke Supabase (Postgres).
///  - HP owner membaca tabel/ view laporan dari Supabase.
///
/// Cara mengaktifkan (Fase 2):
///  1. Buat project Supabase, salin SUPABASE_URL & SUPABASE_ANON_KEY.
///  2. Tambahkan kolom `clientId` (uuid) + `syncedAt` (nullable) di tiap
///     tabel yang disinkronkan, ATAU buat tabel 'outbox' berisi antrean.
///  3. Buat tabel mirror di Postgres dengan primary key = clientId agar
///     upsert bersifat idempotent (aman dikirim ulang).
///  4. Implement [pushPending] di bawah.
class SyncService {
  final AppDatabase db;
  SyncService(this.db);

  /// Kirim semua baris yang belum tersinkron ke cloud.
  Future<void> pushPending() async {
    // TODO(Fase 2):
    // 1. Ambil baris ledger/transaksi yang syncedAt == null (atau dari outbox).
    // 2. Batch upsert ke Supabase, idempotent by clientId.
    // 3. Tandai syncedAt = now (atau hapus dari outbox) setelah sukses.
    throw UnimplementedError('Aktifkan setelah Supabase disiapkan (Fase 2).');
  }
}
