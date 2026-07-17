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
  - saldo kas = `SUM(masuk) - SUM(keluar)` (`CashEntries`)
  - saldo galon = `SUM(dFull/dEmpty/dDeposit)` (`GalonLedger`)
- **Tulis transaksi secara atomik** dalam satu `db.transaction(...)`.
  Lihat `SalesService.recordSale` sebagai pola.
- **Clean architecture** ringan: UI → service (domain) → Drift (data).

## Aturan domain paling penting: galon = DUA barang

- **Air** = barang dagangan, habis terjual → lewat stok produk biasa.
- **Wadah galon** = aset berputar bernilai deposit → lewat `GalonLedger`,
  TERPISAH dari stok produk.
- Tiga saldo wadah: `isi` (siap jual), `kosong` (mau ditukar ke agen),
  `beredar` (di tangan pelanggan = KEWAJIBAN, bukan omzet).
- Uang deposit masuk kas dengan kategori `deposit_galon` — jangan dihitung
  sebagai pendapatan/laba.
- Skenario yang sudah ada di `GalonService`: `recordExchange` (tukar),
  `recordNewGalonSale` (pelanggan baru + deposit), `recordDepositReturn`
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

- **Nilai deposit galon**: seragam (jadikan konstanta/pengaturan) atau beda per
  merk (kolom di `Products`)? Sekarang masih parameter per transaksi.

## Roadmap

- **Fase 1 (MVP):** master produk, POS (utamakan kecepatan input, layar HP),
  stok, pembelian, buku kas + tutup kasir, buku galon, laporan harian.
- **Fase 2:** peran owner baca laporan dari cloud, piutang/utang, QRIS/transfer,
  harga reseller, laba-rugi & arus kas, sinkronisasi cloud. (Opsional: dashboard
  web owner.)
- **Fase 3:** antar galon, langganan galon bulanan, multi-toko, analitik.

## Status sekarang

Fase 1 (MVP) hampir tuntas. SELESAI & terverifikasi di emulator:

- Peran kasir/owner (`lib/main.dart` — `roleProvider`, pilih saat buka app,
  belum dipersist).
- Seed 8 produk saat DB pertama dibuat (`AppDatabase._seedProducts`).
- POS HP (`lib/ui/pos_screen.dart`) — grid tombol besar, galon wajib pilih
  tukar/baru+deposit, bayar tunai/qris/transfer.
- Tutup kasir (`lib/ui/tutup_kasir_screen.dart` + `CashierService`) —
  `CashierClosings` append-only + baris penyesuaian selisih (schemaVersion 2).
- Kulakan/pembelian (`lib/ui/kulakan_screen.dart` + `PurchaseService`) —
  stok masuk, kas keluar, lunas/utang, galon toggle tukar kosong.
- Laporan harian (`lib/ui/laporan_harian_screen.dart` + `ReportsService.
  dailyReport`) — date picker (id_ID via flutter_localizations), rincian
  penjualan per produk + arus kas per kategori.
- Owner: dashboard hari ini dari DB lokal (cloud = Fase 2) + tombol ke
  laporan harian.
- Tes service `test/services_test.dart` (8 tes).

Pakai **fvm** (Flutter 3.44.0): `fvm flutter ...`, `fvm dart run build_runner
build --delete-conflicting-outputs`.

## Langkah berikutnya (urutan disarankan)

1. Master produk (CRUD: tambah/edit harga, nonaktifkan) — sekarang produk
   cuma dari seed.
2. Persist pilihan peran (shared_preferences) + tombol ganti peran/keluar
   dari POS & Owner (sekarang back Android keluar app).
3. Penyesuaian stok awal (opname) — banyak saldo galon kosong minus karena
   stok awal belum dicatat.
4. Mulai Fase 2: sync cloud (Supabase), piutang/utang, harga reseller.

## Konvensi

- Bahasa domain & komentar: Indonesia. Nama tipe/kelas: Inggris standar Dart.
- UI phone-first + responsif (siap tablet).
- Uang: `double` untuk scaffold; pertimbangkan integer rupiah bila ingin hindari
  galat pembulatan.
- Kategori enum ditulis sebagai string konstan (lihat komentar di `tables.dart`).
