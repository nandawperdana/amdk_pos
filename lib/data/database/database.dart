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
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedProducts();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(cashierClosings);
          if (from < 3) await m.createTable(syncCursors);
          if (from < 4) {
            await m.addColumn(products, products.depositPrice);
            // Backfill existing gallon products with the old default deposit.
            await (update(products)..where((p) => p.isGallon.equals(true)))
                .write(const ProductsCompanion(depositPrice: Value(40000)));
          }
        },
      );

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
      double deposit = 0,
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
          depositPrice: Value(deposit),
        );

    await batch((b) => b.insertAll(products, [
          // Gallons (water; the container goes through GallonLedger)
          p(name: 'Galon Aqua 19L', brand: 'Aqua', category: 'gallon',
              buy: 17000, sell: 20000, isGallon: true, deposit: 40000),
          p(name: 'Galon Le Minerale 15L', brand: 'Le Minerale',
              category: 'gallon', buy: 15000, sell: 18000, isGallon: true,
              deposit: 40000),
          p(name: 'Galon Cleo 19L', brand: 'Cleo', category: 'gallon',
              buy: 16000, sell: 19000, isGallon: true, deposit: 40000),
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

  /// Cash balance of an account = SUM(in) - SUM(out).
  Future<double> cashBalance({String account = 'cash'}) async {
    final rows = await (select(cashEntries)
          ..where((t) => t.account.equals(account)))
        .get();
    var balance = 0.0;
    for (final e in rows) {
      balance += e.direction == 'in' ? e.amount : -e.amount;
    }
    return balance;
  }

  /// Gallon reconciliation: full, empty, and out on deposit.
  Future<GallonBalance> gallonBalance() async {
    final rows = await select(gallonLedger).get();
    var full = 0, empty = 0, deposit = 0;
    for (final r in rows) {
      full += r.dFull;
      empty += r.dEmpty;
      deposit += r.dDeposit;
    }
    return GallonBalance(full: full, empty: empty, depositOut: deposit);
  }
}

class GallonBalance {
  final int full; // filled gallons ready to sell
  final int empty; // empty gallons (to swap at the agent)
  final int depositOut; // containers out with customers (liability)
  const GallonBalance({
    required this.full,
    required this.empty,
    required this.depositOut,
  });
}
