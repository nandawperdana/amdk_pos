import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'database.g.dart'; // run: dart run build_runner build

@DriftDatabase(
  tables: [
    Products,
    Suppliers,
    Customers,
    Purchases,
    PurchaseItems,
    Sales,
    SaleItems,
    StockMovements,
    CashEntries,
    GallonLedger,
    CashierClosings,
    SyncCursors,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'amdk_pos'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createIndexes();
          await _seedProducts();
        },
        beforeOpen: (details) async {
          // SQLite disables FK enforcement by default; turn it on so the
          // .references() constraints actually hold (and bad writes roll back).
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Secondary indexes on the hot filter columns. Ledgers only grow, so every
  /// derivation/report would otherwise be a full table scan.
  Future<void> _createIndexes() async {
    const stmts = [
      'CREATE INDEX IF NOT EXISTS ix_stock_product ON stock_movements(product_id)',
      'CREATE INDEX IF NOT EXISTS ix_cash_account ON cash_entries(account)',
      'CREATE INDEX IF NOT EXISTS ix_cash_date ON cash_entries(date)',
      'CREATE INDEX IF NOT EXISTS ix_cash_ref ON cash_entries(category, ref_type, ref_id)',
      'CREATE INDEX IF NOT EXISTS ix_sales_date ON sales(date)',
      'CREATE INDEX IF NOT EXISTS ix_sales_customer ON sales(customer_id, payment_status)',
      'CREATE INDEX IF NOT EXISTS ix_purchases_supplier ON purchases(supplier_id, payment_status)',
      'CREATE INDEX IF NOT EXISTS ix_saleitems_sale ON sale_items(sale_id)',
      'CREATE INDEX IF NOT EXISTS ix_purchaseitems_purchase ON purchase_items(purchase_id)',
    ];
    for (final s in stmts) {
      await customStatement(s);
    }
  }

  /// Seed initial master products (only when the DB is first created).
  /// Prices are Garut market estimates per base unit — the owner edits them
  /// later via the master-product screen.
  Future<void> _seedProducts() async {
    ProductsCompanion p({
      required String name,
      String brand = '',
      required String category,
      String? packUnit,
      int packSize = 1,
      required double buy,
      required double sell,
      bool isGallon = false,
      double containerPrice = 0,
    }) =>
        ProductsCompanion.insert(
          name: name,
          brand: Value(brand),
          category: Value(category),
          packUnit: Value(packUnit),
          packSize: Value(packSize),
          buyPrice: Value(buy),
          sellPrice: Value(sell),
          isGallon: Value(isGallon),
          depositPrice: Value(containerPrice),
        );

    await batch((b) => b.insertAll(products, [
          // Gallons (water sellPrice = isi ulang; containerPrice added on
          // top when selling a brand-new gallon, one price, no deposit)
          p(name: 'Galon Aqua 19L', brand: 'Aqua', category: 'gallon',
              buy: 17000, sell: 20000, isGallon: true, containerPrice: 40000),
          // Le Minerale 15L: brand sekali pakai, TIDAK bisa isi ulang —
          // produk biasa, satu harga (bukan gallon: tanpa container/GallonLedger).
          p(name: 'Le Minerale 15L', brand: 'Le Minerale', category: 'bottle',
              buy: 18000, sell: 22000),
          p(name: 'Galon Cleo 19L', brand: 'Cleo', category: 'gallon',
              buy: 16000, sell: 19000, isGallon: true, containerPrice: 40000),
          // Cups (sold per pcs, bought per box)
          p(name: 'Aqua Gelas 240ml', brand: 'Aqua', category: 'cup',
              packUnit: 'dus', packSize: 48, buy: 550, sell: 1000),
          p(name: 'Cleo Gelas 250ml', brand: 'Cleo', category: 'cup',
              packUnit: 'dus', packSize: 48, buy: 500, sell: 1000),
          // Bottles
          p(name: 'Aqua Botol 600ml', brand: 'Aqua', category: 'bottle',
              packUnit: 'dus', packSize: 24, buy: 2500, sell: 4000),
          p(name: 'Le Minerale Botol 600ml', brand: 'Le Minerale',
              category: 'bottle', packUnit: 'dus', packSize: 24,
              buy: 2300, sell: 3500),
          p(name: 'Aqua Botol 1500ml', brand: 'Aqua', category: 'bottle',
              packUnit: 'dus', packSize: 12, buy: 4500, sell: 6000),
        ]));
  }

  // -------------------------------------------------------------------------
  // DERIVED FROM LEDGER — never store these numbers in any column.
  // -------------------------------------------------------------------------

  /// Running stock of a product = SUM(qtyBase) on the stock card.
  Future<int> stockOf(int productId) async {
    final total = stockMovements.qtyBase.sum();
    final query = selectOnly(stockMovements)
      ..addColumns([total])
      ..where(stockMovements.productId.equals(productId));
    final row = await query.getSingleOrNull();
    return row?.read(total) ?? 0;
  }

  /// Cash balance of an account = SUM(in) - SUM(out). Summed in SQLite, not by
  /// materializing every row in Dart.
  /// ponytail: still scans the account from genesis. If it gets slow, carry
  /// forward from the last CashierClosings and only sum entries after it.
  Future<double> cashBalance({String account = 'cash'}) async {
    final row = await customSelect(
      "SELECT COALESCE(SUM(CASE direction WHEN 'in' THEN amount ELSE -amount END), 0) AS bal "
      'FROM cash_entries WHERE account = ?',
      variables: [Variable.withString(account)],
      readsFrom: {cashEntries},
    ).getSingle();
    return row.read<double>('bal');
  }

  /// Gallon reconciliation: full & empty. Summed in SQLite.
  /// (d_deposit stays in the schema as a dormant, never-written column — no
  /// migration needed — but nothing reads it anymore: containers sold new
  /// leave the fleet for good, one price, no deposit/refund.)
  Future<GallonBalance> gallonBalance() async {
    final row = await customSelect(
      'SELECT COALESCE(SUM(d_full), 0) AS f, COALESCE(SUM(d_empty), 0) AS e '
      'FROM gallon_ledger',
      readsFrom: {gallonLedger},
    ).getSingle();
    return GallonBalance(
      full: row.read<int>('f'),
      empty: row.read<int>('e'),
    );
  }
}

class GallonBalance {
  final int full; // filled gallons ready to sell
  final int empty; // empty gallons (to swap at the agent)
  const GallonBalance({required this.full, required this.empty});
}
