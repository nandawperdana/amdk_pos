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
