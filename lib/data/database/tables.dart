import 'package:drift/drift.dart';

// ===========================================================================
// MASTER DATA
// ===========================================================================

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get brand => text().withDefault(const Constant(''))();

  /// 'gallon' | 'bottle' | 'cup' | 'other'
  TextColumn get category => text().withDefault(const Constant('other'))();

  /// Base unit for all stock math, e.g. 'pcs'.
  TextColumn get baseUnit => text().withDefault(const Constant('pcs'))();

  /// Optional pack unit, e.g. 'box'. packSize = base units per pack.
  TextColumn get packUnit => text().nullable()();
  IntColumn get packSize => integer().withDefault(const Constant(1))();

  RealColumn get buyPrice => real().withDefault(const Constant(0))(); // per base unit
  RealColumn get sellPrice => real().withDefault(const Constant(0))(); // per base unit

  /// true = gallon product (has a circulating CONTAINER / deposit).
  /// The water still flows through normal product stock; the container
  /// flows through GallonLedger.
  BoolColumn get isGallon => boolean().withDefault(const Constant(false))();

  /// Container price per unit, set per gallon product (0 for non-gallon).
  /// Added to sellPrice when selling a brand-new gallon (water + container,
  /// one price, no deposit/refund).
  RealColumn get depositPrice => real().withDefault(const Constant(0))();

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

  /// 'general' | 'subscriber' | 'reseller'
  TextColumn get type => text().withDefault(const Constant('general'))();
  TextColumn get phone => text().nullable()();
}

// ===========================================================================
// TRANSACTIONS (header + items)
// ===========================================================================

class Purchases extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get supplierId => integer().references(Suppliers, #id).nullable()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  RealColumn get totalAmount => real().withDefault(const Constant(0))();

  /// 'paid' | 'debt'
  TextColumn get paymentStatus => text().withDefault(const Constant('paid'))();
  TextColumn get note => text().nullable()();
}

class PurchaseItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get purchaseId => integer().references(Purchases, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get qtyBase => integer()(); // in base units
  RealColumn get price => real()(); // per base unit
  RealColumn get subtotal => real()();
}

class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get customerId => integer().references(Customers, #id).nullable()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  RealColumn get totalAmount => real().withDefault(const Constant(0))();

  /// 'cash' | 'qris' | 'transfer'
  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))();

  /// 'paid' | 'receivable'
  TextColumn get paymentStatus => text().withDefault(const Constant('paid'))();
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
// LEDGER — APPEND-ONLY. Never UPDATE/DELETE rows here.
// Stock & balances are DERIVED from SUM(rows), never stored as a number.
// ===========================================================================

/// Stock card. Running product stock = SUM(qtyBase).
class StockMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id)();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();

  /// 'purchase' | 'sale' | 'adjustment' | 'return'
  TextColumn get type => text()();

  /// Signed: + in, - out (in base units).
  IntColumn get qtyBase => integer()();

  TextColumn get refType => text().nullable()(); // 'sale' | 'purchase' | ...
  IntColumn get refId => integer().nullable()();
  TextColumn get note => text().nullable()();
}

/// Cash book. Account balance = SUM(in) - SUM(out).
class CashEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();

  /// 'in' | 'out'
  TextColumn get direction => text()();
  RealColumn get amount => real()();

  /// 'sale' | 'purchase' | 'expense' | 'capital' | 'drawing'
  /// | 'adjustment' (cashier-closing difference, see CashierClosings)
  TextColumn get category => text()();

  /// 'cash' | 'bank' | 'qris'
  TextColumn get account => text().withDefault(const Constant('cash'))();

  TextColumn get refType => text().nullable()();
  IntColumn get refId => integer().nullable()();
  TextColumn get note => text().nullable()();
}

/// Cashier closing — append-only snapshot, not an edit of old rows.
/// If the physical count differs from the system balance, the difference is
/// recorded as a CashEntries row with category 'adjustment' (refType
/// 'closing'), so the next running balance follows the actual cash in the till.
class CashierClosings extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get closedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get account => text().withDefault(const Constant('cash'))();

  RealColumn get systemBalance => real()(); // cash balance per ledger
  RealColumn get physicalCount => real()(); // cashier's physical count
  RealColumn get difference => real()(); // physicalCount - systemBalance

  TextColumn get note => text().nullable()();
}

/// Gallon ledger — tracks the CONTAINER (not the water).
/// Two balances derived from SUM of the delta columns:
///   full   = SUM(dFull)   filled gallons ready to sell
///   empty  = SUM(dEmpty)  empty gallons waiting to swap at the agent
/// A new container sold ('sale_new') leaves the fleet for good — one price
/// (water + container), no deposit, no return. dDeposit stays in the schema
/// as a dormant column (no migration needed) but nothing writes it anymore.
class GallonLedger extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();

  /// 'restock' | 'sale_exchange' | 'sale_new' | 'adjustment'
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
// SYNC METADATA (not a ledger — may be UPDATED)
// ===========================================================================

/// Per-table sync high-water mark. Because every data table is append-only
/// with immutable rows, push-only sync just sends rows with id > lastId, then
/// advances lastId. No per-row flag, no mutation of ledger rows.
class SyncCursors extends Table {
  TextColumn get entity => text()(); // synced table name
  IntColumn get lastId => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {entity};
}
