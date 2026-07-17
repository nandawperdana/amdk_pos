# AMDK POS — scaffold

Fondasi aplikasi POS, stok, kas, dan laporan untuk toko air minum & galon.
Offline-first (Flutter + Drift/SQLite), siap disinkronkan ke cloud agar owner
bisa melihat laporan dari HP.

## Prinsip inti

**Semua data operasional adalah ledger append-only.** Stok dan saldo TIDAK
disimpan sebagai angka yang di-update — keduanya dihitung dari penjumlahan
baris ledger:

- Stok produk = `SUM(StockMovements.qtyBase)` per produk
- Saldo kas = `SUM(masuk) - SUM(keluar)` per akun (`CashEntries`)
- Saldo galon = `SUM(dFull/dEmpty/dDeposit)` (`GalonLedger`)

Keuntungannya: laporan selalu bisa dipertanggungjawabkan (tiap angka bisa
ditelusuri ke barisnya), bebas bug mutasi, dan sinkronisasi jadi mudah —
lihat bagian Sinkronisasi.

## Galon = dua barang

Kesalahan paling umum di toko galon: menganggap galon satu barang. Padahal ada:

- **Air** — barang dagangan, habis terjual → lewat stok produk biasa.
- **Wadah** — aset yang berputar, punya nilai deposit → lewat `GalonLedger`.

`GalonLedger` melacak tiga saldo wadah:

| Saldo   | Arti                                   |
|---------|----------------------------------------|
| isi     | galon isi siap jual                    |
| kosong  | galon kosong, menunggu ditukar ke agen |
| beredar | wadah di tangan pelanggan = KEWAJIBAN  |

Skenario yang sudah ditangani di `GalonService`:

- `recordExchange` — jual + pelanggan tukar galon kosong (isi -1, kosong +1)
- `recordNewGalonSale` — pelanggan baru beli air + wadah/deposit
  (isi -1, beredar +1, uang deposit masuk kas sebagai kewajiban, bukan omzet)
- `recordDepositReturn` — pelanggan kembalikan galon & tarik deposit (refund)
- `recordRestockExchange` — kulakan galon isi dari agen dengan tukar kosong

## Struktur

```
lib/
  main.dart                     entry + provider Riverpod
  data/
    database/
      tables.dart               definisi tabel Drift (master, transaksi, ledger)
      database.dart             AppDatabase + saldo turunan (stok/kas/galon)
    sync/
      sync_service.dart         strategi sinkronisasi push-only (stub, Fase 2)
  domain/
    services/
      sales_service.dart        catat penjualan (atomik: item+stok+kas)
      galon_service.dart        logika wadah galon
      reports_service.dart      ringkasan harian (omzet, laba kotor, kas)
```

Lapisan UI belum dibuat — itu bagian Anda. Semua service sudah bisa dipanggil
dari layar Flutter mana pun.

## Menjalankan

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generate database.g.dart
flutter run
```

Catatan:
- `database.g.dart` sengaja belum ada — dihasilkan oleh build_runner.
- Jika `drift_flutter` bermasalah di platform target Anda, alternatifnya
  pakai paket `drift` + `sqlite3_flutter_libs` + `path_provider` dan buat
  `QueryExecutor` manual, lalu oper ke `AppDatabase(executor)`.
- Versi paket di `pubspec.yaml` boleh disesuaikan saat `pub get`.

## Sinkronisasi (Fase 2)

Karena ledger bersifat append-only dan HP owner hanya membaca, sinkronisasi
cukup **push-only dan bebas konflik**:

1. Kasir = sumber kebenaran, jalan penuh saat offline.
2. Saat online, kirim baris baru ke Supabase (Postgres).
3. HP owner membaca laporan dari Supabase.

Langkah aktivasi ada di komentar `sync_service.dart` (tambah `clientId` +
`syncedAt`, buat tabel mirror di Postgres dengan PK = clientId agar idempotent).

## Peta ke roadmap

- **Fase 1 (MVP)** — master produk, POS, stok, pembelian, kas, buku galon,
  laporan harian. Fondasi datanya ada di scaffold ini; sisanya UI.
- **Fase 2** — piutang/utang, QRIS/transfer, harga reseller, laba-rugi & arus
  kas, sinkronisasi cloud + HP owner.
- **Fase 3** — antar galon (delivery), langganan galon, multi-toko, analitik.

## Langkah berikutnya yang saya sarankan

1. Isi seed master produk (galon Aqua/Le Minerale/dll, gelas, botol).
2. Bangun layar POS lebih dulu — prioritaskan KECEPATAN input.
3. Tambah layar "tutup kasir" (saldo kas awal vs akhir vs hitungan fisik).
4. Baru pembelian, lalu laporan.
