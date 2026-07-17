import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'database.g.dart'; // jalankan: dart run build_runner build

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
    GalonLedger,
    CashierClosings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'amdk_pos'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedProducts();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(cashierClosings);
        },
      );

  /// Seed master produk awal (hanya saat DB pertama dibuat).
  /// Harga = perkiraan pasar Garut per satuan dasar — owner tinggal
  /// mengedit lewat layar master produk nanti.
  Future<void> _seedProducts() async {
    ProductsCompanion p({
      required String name,
      String brand = '',
      required String category,
      String? packUnit,
      int packSize = 1,
      required double buy,
      required double sell,
      bool isGalon = false,
    }) =>
        ProductsCompanion.insert(
          name: name,
          brand: Value(brand),
          category: Value(category),
          packUnit: Value(packUnit),
          packSize: Value(packSize),
          buyPrice: Value(buy),
          sellPrice: Value(sell),
          isGalon: Value(isGalon),
        );

    await batch((b) => b.insertAll(products, [
          // Galon (air; wadahnya lewat GalonLedger)
          p(name: 'Galon Aqua 19L', brand: 'Aqua', category: 'galon',
              buy: 17000, sell: 20000, isGalon: true),
          p(name: 'Galon Le Minerale 15L', brand: 'Le Minerale',
              category: 'galon', buy: 15000, sell: 18000, isGalon: true),
          p(name: 'Galon Cleo 19L', brand: 'Cleo', category: 'galon',
              buy: 16000, sell: 19000, isGalon: true),
          // Gelas (jual per pcs, kulakan per dus)
          p(name: 'Aqua Gelas 240ml', brand: 'Aqua', category: 'gelas',
              packUnit: 'dus', packSize: 48, buy: 550, sell: 1000),
          p(name: 'Cleo Gelas 250ml', brand: 'Cleo', category: 'gelas',
              packUnit: 'dus', packSize: 48, buy: 500, sell: 1000),
          // Botol
          p(name: 'Aqua Botol 600ml', brand: 'Aqua', category: 'botol',
              packUnit: 'dus', packSize: 24, buy: 2500, sell: 4000),
          p(name: 'Le Minerale Botol 600ml', brand: 'Le Minerale',
              category: 'botol', packUnit: 'dus', packSize: 24,
              buy: 2300, sell: 3500),
          p(name: 'Aqua Botol 1500ml', brand: 'Aqua', category: 'botol',
              packUnit: 'dus', packSize: 12, buy: 4500, sell: 6000),
        ]));
  }

  // -------------------------------------------------------------------------
  // TURUNAN DARI LEDGER — jangan simpan angka ini di kolom mana pun.
  // -------------------------------------------------------------------------

  /// Stok berjalan sebuah produk = SUM(qtyBase) pada kartu stok.
  Future<int> stockOf(int productId) async {
    final total = stockMovements.qtyBase.sum();
    final query = selectOnly(stockMovements)
      ..addColumns([total])
      ..where(stockMovements.productId.equals(productId));
    final row = await query.getSingleOrNull();
    return row?.read(total) ?? 0;
  }

  /// Saldo kas sebuah akun = SUM(masuk) - SUM(keluar).
  Future<double> cashBalance({String account = 'kas'}) async {
    final rows = await (select(cashEntries)
          ..where((t) => t.account.equals(account)))
        .get();
    var balance = 0.0;
    for (final e in rows) {
      balance += e.direction == 'masuk' ? e.amount : -e.amount;
    }
    return balance;
  }

  /// Rekonsiliasi galon: isi, kosong, dan yang beredar (deposit).
  Future<GalonBalance> galonBalance() async {
    final rows = await select(galonLedger).get();
    var full = 0, empty = 0, deposit = 0;
    for (final r in rows) {
      full += r.dFull;
      empty += r.dEmpty;
      deposit += r.dDeposit;
    }
    return GalonBalance(full: full, empty: empty, depositOut: deposit);
  }
}

class GalonBalance {
  final int full; // galon isi siap jual
  final int empty; // galon kosong (mau ditukar ke agen)
  final int depositOut; // wadah beredar di pelanggan (kewajiban)
  const GalonBalance({
    required this.full,
    required this.empty,
    required this.depositOut,
  });
}
