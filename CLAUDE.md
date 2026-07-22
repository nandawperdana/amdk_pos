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
- **Tulis transaksi secara atomik** dalam satu `db.transaction(...)`. Satu
  penjualan = air + wadah galon + kas, SEMUA di satu transaksi yang
  diorkestrasi `SalesService.recordSale` (inject `GallonService`); kulakan
  serupa via `PurchaseService`. UI TIDAK mengorkestrasi multi-service. Saldo
  turunan pakai SQL `SUM()` (bukan fold di Dart) + index di kolom filter panas.
- **Clean architecture** ringan: UI → service (domain) → Drift (data). UI tak
  pernah sentuh DB langsung (mis. tambah pelanggan/supplier lewat
  `PartyService`). Provider/DI di `lib/providers.dart` (`main.dart` re-export).

## Aturan domain paling penting: galon = DUA barang, TANPA deposit

- **Air** = barang dagangan, habis terjual → lewat stok produk biasa.
- **Wadah galon** = lewat `GallonLedger`, TERPISAH dari stok produk (dua
  saldo: `full` isi siap jual, `empty` kosong mau ditukar ke agen).
- **TIDAK ADA deposit/refund.** Dua skenario jual galon di POS:
  - **Isi ulang** (`GallonSaleMode.exchange`): pelanggan bawa wadah kosong,
    cuma bayar `sellPrice` (harga air). Wadah: `full -qty`, `empty +qty`.
  - **Galon baru** (`GallonSaleMode.newCustomer`): wadah + isi dijual putus,
    **satu harga** = `sellPrice + depositPrice` (kolom `depositPrice` dipakai
    ulang jadi harga wadah, BUKAN deposit) — **100% masuk omzet**. Wadah
    keluar dari armada toko selamanya: `full -qty` saja, tanpa `empty`/balik.
  - Galon sekali beli (tanpa isi ulang) = produk biasa (`isGallon=false`),
    tanpa penanganan khusus.
- Skenario di `GallonService`: `recordExchange` (isi ulang), `recordNewGallonSale`
  (galon baru, satu harga), `recordRestockExchange` (kulakan tukar kosong ke
  agen). `recordDepositReturn` SUDAH DIHAPUS (Fase 3 P0, lihat riwayat commit).
- Kolom `GallonLedger.dDeposit` & `GallonBalance` field terkait tetap ada di
  schema (dormant, tanpa migrasi) tapi tak lagi ditulis/dibaca kode manapun.

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

- **Harga wadah galon**: DIPUTUS per-produk (kolom `Products.depositPrice`,
  editable di master produk). Backfill galon lama ke 40000 saat migrasi v3→v4.
- **Model galon: TANPA deposit/refund** (diputuskan ulang, gantikan model
  deposit-liability sebelumnya). Galon baru = satu harga (`sellPrice +
  depositPrice`), 100% omzet, wadah keluar armada selamanya. Isi ulang tetap
  swap kosong seperti biasa. Alasan: operasional lebih sederhana, owner belum
  butuh proses pengembalian deposit.

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
  DIPERSIST via shared_preferences; ganti peran dari footer nav drawer,
  kedua peran).
- Seed 8 produk saat DB pertama dibuat (`AppDatabase._seedProducts`).
- POS HP (`lib/ui/pos_screen.dart`) — grid tombol besar, galon wajib pilih
  isi-ulang/galon-baru (satu harga, tanpa deposit), bayar tunai/qris/transfer,
  jual per pcs/dus (`qty_picker.dart`). Navigasi lain di drawer.
- Nav drawer (`lib/ui/app_drawer.dart`, `AppDrawer`) — dipakai kasir & owner,
  isi beda per peran (`roleProvider`); AppBar cuma title + aksi live
  (Sync/Refresh).
- Master produk CRUD (`lib/ui/master_product_screen.dart` + `ProductService`) —
  tambah/edit/nonaktif (soft-delete, tak hapus baris); `isGallon` diikat
  kategori=='gallon'. Kasir cuma toggle aktif/nonaktif, owner full CRUD.
- Tutup kasir (`lib/ui/cashier_closing_screen.dart` + `CashierService`) —
  `CashierClosings` append-only + baris penyesuaian selisih (schemaVersion 2).
- Kulakan/pembelian (`lib/ui/purchase_screen.dart` + `PurchaseService`) —
  stok masuk, kas keluar, lunas/utang, galon toggle tukar kosong, jual per
  pcs/dus. HANYA di menu Owner.
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

**Fase 1 & Fase 2 TUNTAS.**

SELESAI di Fase 2:
- Piutang/utang (tab per pihak, pelunasan append-only).
- Sinkronisasi cloud — project Supabase aktif, `doc/supabase_setup.sql`
  dijalankan, live round-trip terverifikasi (push idempotent, master
  full-merge vs ledger cursor-based, nol duplikat). Jalankan dengan
  `fvm flutter run --dart-define=APP_ENV=dev --dart-define=SUPABASE_URL=...
  --dart-define=SUPABASE_ANON_KEY=...` (kredensial di bagian "Kredensial
  Supabase" di bawah).
- **Pisah kredensial dev vs prod** — `main.dart` const `appEnv`/`isProdEnv`
  dari `--dart-define=APP_ENV=dev|prod`, default `dev` (lupa set flag =
  gagal KELIHATAN, bukan diam-diam nganggep prod). Badge "DEV" muncul di
  header nav drawer kalau `appEnv != 'prod'`. Build prod WAJIB pasang
  `APP_ENV=prod` + kredensial project Supabase prod eksplisit.
  **PENTING**: project Supabase yang dipakai sepanjang sesi testing/dev
  sejauh ini (live round-trip di atas) berisi data uji-coba, bukan data
  toko asli — perlakukan sebagai project DEV. Owner perlu bikin project
  Supabase BARU yang bersih khusus buat PROD sebelum APK dipasang di toko
  beneran (jalankan ulang `doc/supabase_setup.sql` di project baru itu).
- Laba-rugi & arus kas periode — `ReportsService.periodSummary/periodReport
  (start, end)`, `dailySummary/dailyReport` jadi wrapper single-day.
  `lib/ui/daily_report_screen.dart` (layar "Laporan"): preset Hari ini/
  Minggu ini/Bulan ini + date-range picker custom.
- QRIS/transfer sebagai metode pelunasan piutang/utang — dialog di
  `credit_screen.dart` punya pilihan Tunai/QRIS/Transfer, pakai param
  `account` yang sudah ada di `CreditService`.
- Rework model galon: HAPUS deposit/refund total (lihat bagian domain di
  atas). `recordDepositReturn` dihapus, `GallonBalance.depositOut` dihapus,
  tile owner "Galon beredar" & menu "Tarik deposit galon" dihapus, field
  opname "beredar" dihapus. Galon baru sekarang satu harga (100% omzet).

## Penyesuaian requirement (P0 & P1 selesai, P2+ menunggu prioritas eksekusi)

Owner minta beberapa penyesuaian. P0 (rework galon) & P1 sudah selesai:

- **Jual per dus/pack** (POS & kulakan) — `lib/ui/qty_picker.dart`
  (`pickQuantity`), dipakai bersama di kedua layar. Produk dengan
  `packUnit` terisi (mis. gelas/botol dus) buka dialog jumlah+satuan (pcs
  atau dus) saat ditambah ke keranjang; tap angka qty di keranjang untuk
  ubah lagi. Produk tanpa `packUnit` tetap tap-cepat +1 (kecepatan input
  POS tak terganggu).
- **Nav drawer** ganti overflow menu — `lib/ui/app_drawer.dart`
  (`AppDrawer`), dipakai kasir & owner. AppBar cuma title + aksi live
  (Sync/Refresh); semua navigasi (Tutup Kasir, Opname, Piutang & Utang,
  Master Produk, Kulakan, Laporan) pindah ke drawer. Ganti Peran di footer
  drawer (dulu di popup menu).
- **Kontrol akses per peran**:
  - Master produk: kasir cuma toggle aktif/nonaktif (Switch), tombol
    tambah/edit disembunyikan (`isOwner` check di
    `master_product_screen.dart`). Owner tetap full CRUD.
  - Kulakan: HANYA muncul di drawer Owner, dihapus total dari drawer/menu
    Kasir.
- **PIN lokal khusus Owner** (kasir tanpa PIN) —
  `lib/domain/services/pin_service.dart` (hash SHA-256, bukan plaintext,
  via `crypto`), `lib/ui/owner_pin_gate_screen.dart`. Pertama kali masuk
  Owner: buat PIN (min 4 digit + konfirmasi). Berikutnya: wajib verify
  tiap masuk Owner. `ownerUnlockedProvider` (in-memory, TIDAK dipersist)
  reset ke `false` tiap kali Ganti Peran atau app baru dibuka — jadi PIN
  diminta ulang tiap sesi masuk Owner, bukan cuma sekali seumur hidup app.
  Tanpa alur lupa-PIN (clear data/reinstall kalau lupa — cukup untuk toko
  tunggal, satu owner).
- **Auto-sync harian** — `SyncService.dueForAutoSync`/`lastSyncAt` (cek
  timestamp di SharedPreferences, bukan daemon/WorkManager). Kasir
  (`pos_screen.dart` `initState`) cek sekali tiap app dibuka: kalau >24 jam
  sejak sync sukses terakhir (atau belum pernah), push otomatis diam-diam
  (gagal = silent, tombol Sync manual di AppBar tetap ada buat jaga-jaga).
  Timestamp disetel ulang tiap `pushPending()` sukses.
- **Owner baca laporan dari cloud (offline-capable, HP terpisah)** —
  `SyncService.pullUpdates()`: arah kebalikan dari push. Master (produk/
  supplier/customer) full-replace tiap pull; ledger cursor-based pakai key
  `pull_<table>` (beda dari cursor push `<table>`, jadi aman di
  `SyncCursors` yang sama). `device_id` dibuang pas masuk (kolom itu cuma
  ada di mirror Postgres). Owner (`owner_screen.dart`, kini
  `ConsumerStatefulWidget`) auto-pull sekali/hari di `initState` (gantian
  cadence sama seperti auto-push kasir, prefs terpisah per device jadi
  aman) + tombol refresh manual (icon sama, ganti fungsi jadi pull lalu
  invalidate `ownerSummaryProvider`). `ReportsService`/`gallonBalance`/
  `cashBalance` DIPAKAI ULANG tanpa ubah — jalan dari DB lokal yang
  sekarang adalah cermin hasil pull di HP owner, makanya offline-capable
  begitu pernah pull sekali.
  **PENTING — batasan operasional**: HP owner yang terpisah dari kasir
  HANYA boleh dipakai buat lihat laporan (read-only by convention, bukan
  dipaksa di level kode). JANGAN pakai Kulakan/Tutup Kasir/dsb dari HP
  owner terpisah itu — tulisannya cuma nyangkut lokal di HP itu doang,
  TIDAK PERNAH ke-push (owner tidak punya `SyncButton`/push), jadi bikin
  angka beda sama kasir tanpa ketahuan. Kulakan (meski menunya di Owner)
  tetap harus dikerjakan di device kasir (switch ke mode Owner di device
  itu kalau perlu) — bukan di HP pribadi owner. Ini technical debt yang
  perlu solusi lebih baku (mis. flag "primary device") kalau jadi masalah
  nyata; untuk sekarang cukup didokumentasikan sebagai batasan pemakaian.
- **Stok per barang + COGS FIFO** — barang stok ≤0 tak bisa dijual (grid
  POS disable + label "Habis", `stockMapProvider` di `pos_screen.dart`,
  SUM `StockMovements` per produk). `SaleItems.cogs` (schemaVersion 6,
  backfill data lama = `buyPrice master × qty`) dihitung & DIBEKUKAN saat
  jual — `SalesService._fifoCogs` jalanin purchase lot (`PurchaseItems`,
  urut `id`) dari yang PALING LAMA, jadi kalau harga beli kulakan berubah,
  cuma stok baru yang kepakai harga baru; penjualan lama tetap kekunci ke
  harga beli lama. `ReportsService` pakai `SUM(saleItems.cogs)`, bukan
  `product.buyPrice` lagi (buyPrice cuma fallback kalau stok minus/terjual
  melebihi yang pernah dikulak).

Sisa BELUM dikerjakan, urutan disarankan:

- **P2**: release APK ber-signature.
- **P3** (Fase 3 lama): antar galon, langganan galon bulanan, multi-toko,
  analitik — lihat bagian Roadmap di atas.

DITUNDA (belum ada kebutuhan):
- Harga reseller — belum berencana punya reseller. Tabel `Customers.type`
  sudah punya nilai `reseller`, tapi harga per-tipe tak diimplementasi dulu
  (YAGNI). Aktifkan kalau reseller benar-benar ada.

## Kredensial Supabase

`anon public` key — aman ditaruh di sini/di client (bukan secret, akses data
tetap digerbangi RLS di Postgres). JANGAN pernah taruh `service_role` key di
sini atau di client manapun.

**DEV** (data uji-coba, bukan data toko asli — lihat catatan di atas):
```
SUPABASE_URL=https://bzhjreftqbfjhlmtpbpg.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6aGpyZWZ0cWJmamhsbXRwYnBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQzOTkwMjAsImV4cCI6MjA5OTk3NTAyMH0.IT4nvMiflQfRmXZVf7zMi_dLxYhj8KPZKt-fVFGQDNI
```

**PROD** (project bersih, khusus data toko asli):
```
SUPABASE_URL=https://uaswqzhcxffpaesjkgvj.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVhc3dxemhjeGZmcGFlc2prZ3ZqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ0NDcwMDAsImV4cCI6MjEwMDAyMzAwMH0.0C79BPOajXSRiv2Hr38zNDAvpwozjGFPkACFvxUN1vo
```

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
