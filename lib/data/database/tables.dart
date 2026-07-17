import 'package:drift/drift.dart';

// ===========================================================================
// MASTER DATA
// ===========================================================================

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get brand => text().withDefault(const Constant(''))();

  /// 'galon' | 'botol' | 'gelas' | 'lainnya'
  TextColumn get category => text().withDefault(const Constant('lainnya'))();

  /// Satuan dasar untuk semua perhitungan stok, mis. 'pcs'.
  TextColumn get baseUnit => text().withDefault(const Constant('pcs'))();

  /// Satuan besar opsional, mis. 'dus'. packSize = isi per dus.
  TextColumn get packUnit => text().nullable()();
  IntColumn get packSize => integer().withDefault(const Constant(1))();

  RealColumn get buyPrice => real().withDefault(const Constant(0))(); // per base unit
  RealColumn get sellPrice => real().withDefault(const Constant(0))(); // per base unit

  /// true = produk galon (punya WADAH yang berputar / deposit).
  /// Airnya tetap lewat stok produk biasa; wadahnya lewat GalonLedger.
  BoolColumn get isGalon => boolean().withDefault(const Constant(false))();

  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

class Suppliers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get note => text().nullable()();
}

class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// 'umum' | 'langganan' | 'reseller'
  TextColumn get type => text().withDefault(const Constant('umum'))();
  TextColumn get phone => text().nullable()();
}

// ===========================================================================
// TRANSAKSI (header + item)
// ===========================================================================

class Purchases extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get supplierId => integer().references(Suppliers, #id).nullable()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  RealColumn get totalAmount => real().withDefault(const Constant(0))();

  /// 'lunas' | 'utang'
  TextColumn get paymentStatus => text().withDefault(const Constant('lunas'))();
  TextColumn get note => text().nullable()();
}

class PurchaseItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get purchaseId => integer().references(Purchases, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get qtyBase => integer()(); // dalam satuan dasar
  RealColumn get price => real()(); // per base unit
  RealColumn get subtotal => real()();
}

class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get customerId => integer().references(Customers, #id).nullable()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  RealColumn get totalAmount => real().withDefault(const Constant(0))();

  /// 'tunai' | 'qris' | 'transfer'
  TextColumn get paymentMethod => text().withDefault(const Constant('tunai'))();

  /// 'lunas' | 'piutang'
  TextColumn get paymentStatus => text().withDefault(const Constant('lunas'))();
  TextColumn get note => text().nullable()();
}

class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer().references(Sales, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get qtyBase => integer()();
  RealColumn get price => real()();
  RealColumn get subtotal => real()();
}

// ===========================================================================
// LEDGER — APPEND-ONLY. Jangan pernah UPDATE/DELETE baris di sini.
// Stok & saldo DITURUNKAN dari SUM baris, tidak disimpan sebagai angka.
// ===========================================================================

/// Kartu stok. Stok berjalan produk = SUM(qtyBase).
class StockMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id)();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();

  /// 'pembelian' | 'penjualan' | 'penyesuaian' | 'retur'
  TextColumn get type => text()();

  /// Bertanda: + masuk, - keluar (dalam base unit).
  IntColumn get qtyBase => integer()();

  TextColumn get refType => text().nullable()(); // 'sale' | 'purchase' | ...
  IntColumn get refId => integer().nullable()();
  TextColumn get note => text().nullable()();
}

/// Buku kas. Saldo akun = SUM(masuk) - SUM(keluar).
class CashEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();

  /// 'masuk' | 'keluar'
  TextColumn get direction => text()();
  RealColumn get amount => real()();

  /// 'penjualan' | 'pembelian' | 'biaya' | 'modal' | 'prive' | 'deposit_galon'
  /// | 'penyesuaian' (selisih tutup kasir, lihat CashierClosings)
  TextColumn get category => text()();

  /// 'kas' | 'bank' | 'qris'
  TextColumn get account => text().withDefault(const Constant('kas'))();

  TextColumn get refType => text().nullable()();
  IntColumn get refId => integer().nullable()();
  TextColumn get note => text().nullable()();
}

/// Tutup kasir — snapshot append-only, bukan koreksi baris lama.
/// Kalau hitungan fisik beda dari saldo sistem, selisihnya dicatat sebagai
/// baris CashEntries kategori 'penyesuaian' (refType 'closing'), supaya
/// saldo berjalan berikutnya ikut uang fisik yang sebenarnya di laci.
class CashierClosings extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get closedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get account => text().withDefault(const Constant('kas'))();

  RealColumn get systemBalance => real()(); // saldo kas menurut ledger
  RealColumn get physicalCount => real()(); // hasil hitung fisik kasir
  RealColumn get difference => real()(); // physicalCount - systemBalance

  TextColumn get note => text().nullable()();
}

/// Buku galon — melacak WADAH (bukan air).
/// Tiga saldo diturunkan dari SUM kolom delta:
///   isi     = SUM(dFull)     galon isi siap jual
///   kosong  = SUM(dEmpty)    galon kosong menunggu ditukar ke agen
///   beredar = SUM(dDeposit)  wadah di tangan pelanggan (KEWAJIBAN Anda)
class GalonLedger extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();

  /// 'kulakan' | 'jual_tukar' | 'jual_baru' | 'deposit_kembali' | 'penyesuaian'
  TextColumn get type => text()();

  IntColumn get dFull => integer().withDefault(const Constant(0))();
  IntColumn get dEmpty => integer().withDefault(const Constant(0))();
  IntColumn get dDeposit => integer().withDefault(const Constant(0))();

  IntColumn get customerId => integer().references(Customers, #id).nullable()();
  TextColumn get refType => text().nullable()();
  IntColumn get refId => integer().nullable()();
  TextColumn get note => text().nullable()();
}

// ===========================================================================
// METADATA SYNC (bukan ledger — boleh di-UPDATE)
// ===========================================================================

/// Penanda batas atas sinkronisasi per tabel. Karena tiap tabel data
/// bersifat append-only + baris immutable, sinkronisasi push-only cukup
/// mengirim baris dengan id > lastId, lalu majukan lastId. Tak perlu flag
/// per-baris atau mutasi baris ledger.
class SyncCursors extends Table {
  TextColumn get entity => text()(); // nama tabel yang disinkronkan
  IntColumn get lastId => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {entity};
}
