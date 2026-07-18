# AMDK POS — konteks proyek

Aplikasi POS, stok, kas, dan laporan untuk toko air minum kemasan & galon
(AMDK) di Garut. Baca file ini dulu setiap sesi sebelum menulis kode.

## Cara kerja proyek ini (penting)

- **Claude Code yang menulis kodenya.** Owner mengarahkan dan mereview, dan
  TIDAK ingin ngoding sendiri. Jangan menyerahkan tugas coding ke owner —
  implementasikan sendiri, lalu jelaskan singkat apa yang dibuat dan cara
  menjalankan/verifikasinya.
- Owner paham Flutter & arsitektur, jadi penjelasan boleh teknis dan padat.
  Ambil keputusan teknis kecil sendiri; tanyakan hanya yang benar-benar
  mengubah arah produk/bisnis.
- Kerjakan bertahap sesuai roadmap; pastikan tiap langkah bisa dijalankan.

## Prinsip arsitektur (jangan dilanggar)

- **Client = Flutter native, satu app dua peran.** Mode kasir (POS penuh,
  tulis ke DB lokal + sync) dan mode owner (baca laporan dari cloud).
  BUKAN web untuk MVP — keputusan sudah final (lihat di bawah).
- **Kasir jalan di HP Android.** Desain layar POS untuk layar HP: tombol
  produk yang sering dijual dibuat besar, alur input cepat. Buat layout
  responsif supaya mudah pindah ke tablet Android nanti tanpa tulis ulang.
- **Offline-first.** Kasir = sumber kebenaran dan wajib jalan penuh tanpa
  internet. DB lokal SQLite via Drift.
- **Semua data operasional = ledger append-only.** JANGAN pernah UPDATE/DELETE
  baris ledger. Stok & saldo TIDAK disimpan sebagai angka — selalu dihitung
  dari SUM baris:
  - stok produk = `SUM(StockMovements.qtyBase)`
  - saldo kas = `SUM(in) - SUM(out)` (`CashEntries`)
  - saldo galon = `SUM(dFull/dEmpty/dDeposit)` (`GallonLedger`)
- **Tulis transaksi secara atomik** dalam satu `db.transaction(...)`.
  Lihat `SalesService.recordSale` sebagai pola.
- **Clean architecture** ringan: UI → service (domain) → Drift (data).

## Aturan domain paling penting: galon = DUA barang

- **Air** = barang dagangan, habis terjual → lewat stok produk biasa.
- **Wadah galon** = aset berputar bernilai deposit → lewat `GallonLedger`,
  TERPISAH dari stok produk.
- Tiga saldo wadah (kolom `GallonBalance`): `full` (isi, siap jual),
  `empty` (kosong, mau ditukar ke agen), `depositOut` (beredar di tangan
  pelanggan = KEWAJIBAN, bukan omzet).
- Uang deposit masuk kas dengan kategori `gallon_deposit` — jangan dihitung
  sebagai pendapatan/laba.
- Skenario yang sudah ada di `GallonService`: `recordExchange` (tukar),
  `recordNewGallonSale` (pelanggan baru + deposit), `recordDepositReturn`
  (tarik deposit/refund), `recordRestockExchange` (kulakan tukar).

## Keputusan yang sudah diambil (final)

- Client: **Flutter native, satu app, dua peran (kasir + owner)**. Tidak pakai
  web untuk MVP. Dashboard web khusus owner hanya opsi tambahan di Fase 2.
- Kasir: **HP Android** (owner juga pakai HP untuk mode owner).
- Deployment: kasir offline sebagai source of truth + owner baca laporan dari
  cloud → butuh sinkronisasi.
- Sinkronisasi: **push-only, bebas konflik** (dimungkinkan oleh ledger
  append-only + owner read-only). Target Supabase/Postgres. Masih stub di
  `lib/data/sync/sync_service.dart` (Fase 2).
- **Printer struk DITUNDA untuk MVP.** POS cukup mencatat di layar dulu. Kalau
  nanti perlu (langganan/reseller atau nota antar): printer termal Bluetooth
  58mm — didukung baik oleh plugin Flutter, jadi mudah ditambah belakangan.
- **Delivery/antar galon DITUNDA** (Fase 3).
- Stack: Flutter + Drift + Riverpod; Supabase untuk sync (Fase 2).

## Keputusan yang MASIH TERBUKA

- (kosong untuk saat ini)

## Keputusan yang sudah DITUTUP

- **Nilai deposit galon**: DIPUTUS per-produk (kolom `Products.depositPrice`,
  editable di master produk). POS pakai `p.depositPrice`. Backfill galon lama
  ke 40000 saat migrasi v3→v4.

## Roadmap

- **Fase 1 (MVP):** master produk, POS (utamakan kecepatan input, layar HP),
  stok, pembelian, buku kas + tutup kasir, buku galon, laporan harian.
- **Fase 2:** peran owner baca laporan dari cloud, piutang/utang, QRIS/transfer,
  harga reseller, laba-rugi & arus kas, sinkronisasi cloud. (Opsional: dashboard
  web owner.)
- **Fase 3:** antar galon, langganan galon bulanan, multi-toko, analitik.

## Status sekarang

**Fase 1 (MVP) TUNTAS** & terverifikasi di emulator (Pixel 7 API 35):

- Peran kasir/owner (`lib/main.dart` — `roleProvider` = `RoleNotifier`,
  DIPERSIST via shared_preferences; ganti peran dari overflow POS & AppBar
  Owner).
- Seed 8 produk saat DB pertama dibuat (`AppDatabase._seedProducts`).
- POS HP (`lib/ui/pos_screen.dart`) — grid tombol besar, galon wajib pilih
  tukar/baru+deposit, bayar tunai/qris/transfer. Menu lain di overflow.
- Master produk CRUD (`lib/ui/master_product_screen.dart` + `ProductService`) —
  tambah/edit/nonaktif (soft-delete, tak hapus baris); `isGallon` diikat
  kategori=='gallon'.
- Tutup kasir (`lib/ui/cashier_closing_screen.dart` + `CashierService`) —
  `CashierClosings` append-only + baris penyesuaian selisih (schemaVersion 2).
- Kulakan/pembelian (`lib/ui/purchase_screen.dart` + `PurchaseService`) —
  stok masuk, kas keluar, lunas/utang, galon toggle tukar kosong.
- Opname/penyesuaian stok (`lib/ui/stock_take_screen.dart` + `StockTakeService`) —
  hitungan fisik per produk + wadah galon; tulis baris SELISIH (append-only).
- Laporan harian (`lib/ui/daily_report_screen.dart` + `ReportsService.
  dailyReport`) — date picker (id_ID via flutter_localizations), rincian
  penjualan per produk + arus kas per kategori.
- Owner: dashboard hari ini dari DB lokal (cloud = Fase 2) + tombol ke
  laporan harian.
- Sync cloud (`lib/data/sync/sync_service.dart`) — push-only cursor-based ke
  Supabase, gated di kredensial `--dart-define`; DDL di `doc/supabase_setup.sql`.
  Layer jadi & teruji offline; live round-trip nunggu project Supabase.
- Piutang/utang (`lib/domain/services/credit_service.dart` +
  `lib/ui/credit_screen.dart` + `party_picker.dart`) — tab per pihak,
  saldo diturunkan dari SUM, pelunasan append-only. POS punya bayar
  "Piutang (bon)"; kulakan utang pilih supplier.
- Tes service `test/services_test.dart` (16 tes).

Pakai **fvm** (Flutter 3.44.0): `fvm flutter ...`, `fvm dart run build_runner
build --delete-conflicting-outputs`.

## Langkah berikutnya (urutan disarankan)

Fase 1 selesai. Fase 2 berjalan — sisa:

1. Sinkronisasi cloud (Supabase) — layer sudah dibangun (`SyncService`,
   cursor-based, gated di kredensial). Sisanya: owner buat project Supabase
   + jalankan `doc/supabase_setup.sql`, lalu live round-trip diuji.
2. Laba-rugi & arus kas periode (laporan lintas hari/bulan).
3. QRIS/transfer sebagai metode pelunasan piutang/utang (sekarang pelunasan
   default akun `cash`).

SELESAI di Fase 2: piutang/utang (tab per pihak, pelunasan append-only).

DITUNDA (belum ada kebutuhan):
- Harga reseller — belum berencana punya reseller. Tabel `Customers.type`
  sudah punya nilai `reseller`, tapi harga per-tipe tak diimplementasi dulu
  (YAGNI). Aktifkan kalau reseller benar-benar ada.

## Konvensi

- **Kode & komentar: Inggris** (nama tipe/kelas/variabel/method, komentar, dan
  nilai enum string yang tersimpan di DB — mis. `'cash'`, `'paid'`, `'in'`,
  `'sale_exchange'`, kategori `'gallon'/'bottle'/'cup'/'other'`).
- **Display copy tetap Bahasa Indonesia** — semua teks yang dilihat pengguna
  (label, judul layar, tombol, snackbar). Nilai enum Inggris dipetakan ke label
  Indonesia di layer UI (lihat `_paymentOptions` di `pos_screen.dart`,
  `_categories`/`_categoryLabel` di `master_product_screen.dart`,
  `_categoryLabel` di `daily_report_screen.dart`).
- UI phone-first + responsif (siap tablet).
- Uang: `double` untuk scaffold; pertimbangkan integer rupiah bila ingin hindari
  galat pembulatan.
- Nilai enum kategori ditulis sebagai string konstan (lihat komentar di
  `tables.dart`).
