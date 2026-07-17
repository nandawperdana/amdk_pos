import 'package:amdk_pos/data/database/database.dart';
import 'package:amdk_pos/data/sync/sync_service.dart';
import 'package:amdk_pos/domain/services/cashier_service.dart';
import 'package:amdk_pos/domain/services/gallon_service.dart';
import 'package:amdk_pos/domain/services/product_service.dart';
import 'package:amdk_pos/domain/services/purchase_service.dart';
import 'package:amdk_pos/domain/services/reports_service.dart';
import 'package:amdk_pos/domain/services/sales_service.dart';
import 'package:amdk_pos/domain/services/stock_take_service.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('seed products are inserted when the DB is created', () async {
    final products = await db.select(db.products).get();
    expect(products, isNotEmpty);
    expect(products.where((p) => p.isGallon), isNotEmpty);
    expect(products.every((p) => p.sellPrice > p.buyPrice), isTrue);
  });

  test('recordSale: stock out, cash in, revenue correct', () async {
    final sales = SalesService(db);
    final p = await (db.select(db.products)
          ..where((t) => t.isGallon.equals(false))
          ..limit(1))
        .getSingle();

    await sales.recordSale(lines: [
      SaleLine(productId: p.id, qtyBase: 3, price: p.sellPrice),
    ]);

    expect(await db.stockOf(p.id), -3); // no purchase yet → negative
    expect(await db.cashBalance(), p.sellPrice * 3);

    final summary = await ReportsService(db).dailySummary(DateTime.now());
    expect(summary.revenue, p.sellPrice * 3);
    expect(summary.grossProfit, (p.sellPrice - p.buyPrice) * 3);
  });

  test('gallon: new sale + deposit, then exchange, container balance consistent',
      () async {
    final gallon = GallonService(db);

    // Restock 10 filled gallons (empty swap — empty goes negative, expected
    // for opening stock; the opening adjustment follows in the stock UI).
    await gallon.recordRestockExchange(qty: 10);

    // New customer: 2 gallons + deposit.
    await gallon.recordNewGallonSale(qty: 2, depositPerGallon: 40000);
    var b = await db.gallonBalance();
    expect(b.full, 8);
    expect(b.depositOut, 2); // containers out = liability

    // Deposit enters cash BUT is not revenue.
    expect(await db.cashBalance(), 80000);
    final summary = await ReportsService(db).dailySummary(DateTime.now());
    expect(summary.revenue, 0);

    // Subscriber: exchange 1 gallon.
    await gallon.recordExchange(qty: 1);
    b = await db.gallonBalance();
    expect(b.full, 7);
    expect(b.empty, -10 + 1); // -10 from restock swap + 1 from the customer
    expect(b.depositOut, 2);
  });

  test('cashier closing: difference recorded as adjustment, not overwrite',
      () async {
    final sales = SalesService(db);
    final cashier = CashierService(db);
    final p = await (db.select(db.products)..limit(1)).getSingle();

    await sales.recordSale(
        lines: [SaleLine(productId: p.id, qtyBase: 1, price: p.sellPrice)]);
    final systemBalance = await db.cashBalance();

    expect(await cashier.openingBalance(), 0); // no closing yet

    // Physical less than system (e.g. a miscounted change).
    const shortage = 500.0;
    await cashier.recordClosing(physicalCount: systemBalance - shortage);

    // Difference recorded as a new cash row, not by editing an old one.
    expect(await db.cashBalance(), systemBalance - shortage);
    final entries = await db.select(db.cashEntries).get();
    expect(entries.where((e) => e.category == 'adjustment'), hasLength(1));

    // The next closing starts from the previous closing's physical count.
    expect(await cashier.openingBalance(), systemBalance - shortage);
  });

  test('purchase paid: stock in, cash out', () async {
    final purchase = PurchaseService(db);
    final p = await (db.select(db.products)..limit(1)).getSingle();

    await purchase.recordPurchase(
        lines: [PurchaseLine(productId: p.id, qtyBase: 10, price: p.buyPrice)]);

    expect(await db.stockOf(p.id), 10);
    expect(await db.cashBalance(), -p.buyPrice * 10); // money out
  });

  test('purchase on debt: stock in, cash UNCHANGED', () async {
    final purchase = PurchaseService(db);
    final p = await (db.select(db.products)..limit(1)).getSingle();

    await purchase.recordPurchase(
      lines: [PurchaseLine(productId: p.id, qtyBase: 5, price: p.buyPrice)],
      paymentStatus: 'debt',
    );

    expect(await db.stockOf(p.id), 5);
    expect(await db.cashBalance(), 0); // not paid, cash unchanged
  });

  test('gallon restock + empty swap: water stock up, container moves', () async {
    final purchase = PurchaseService(db);
    final gallon = GallonService(db);
    final g = await (db.select(db.products)..where((t) => t.isGallon.equals(true))
          ..limit(1))
        .getSingle();

    await purchase.recordPurchase(
        lines: [PurchaseLine(productId: g.id, qtyBase: 20, price: g.buyPrice)]);
    await gallon.recordRestockExchange(qty: 20);

    expect(await db.stockOf(g.id), 20); // water ready to sell
    final b = await db.gallonBalance();
    expect(b.full, 20); // filled containers
    expect(b.empty, -20); // empties swapped at the agent
  });

  test('daily report: per-product & per-cash-category breakdown', () async {
    final sales = SalesService(db);
    final reports = ReportsService(db);
    final cup = await (db.select(db.products)
          ..where((t) => t.category.equals('cup'))
          ..limit(1))
        .getSingle();
    final bottle = await (db.select(db.products)
          ..where((t) => t.category.equals('bottle'))
          ..limit(1))
        .getSingle();

    // Two transactions: cup ×5, bottle ×2, then cup ×3 (must aggregate).
    await sales.recordSale(
        lines: [SaleLine(productId: cup.id, qtyBase: 5, price: cup.sellPrice)]);
    await sales.recordSale(lines: [
      SaleLine(productId: bottle.id, qtyBase: 2, price: bottle.sellPrice),
      SaleLine(productId: cup.id, qtyBase: 3, price: cup.sellPrice),
    ]);

    final r = await reports.dailyReport(DateTime.now());

    // Per product: cup aggregates to 8 pcs.
    final cupRow = r.byProduct.firstWhere((p) => p.name == cup.name);
    expect(cupRow.qty, 8);
    expect(cupRow.revenue, cup.sellPrice * 8);
    expect(cupRow.profit, (cup.sellPrice - cup.buyPrice) * 8);
    // Sorted by revenue desc.
    expect(r.byProduct.first.revenue >= r.byProduct.last.revenue, isTrue);

    // Cash: all sales land in category 'sale'.
    final sale = r.byCategory.firstWhere((c) => c.category == 'sale');
    expect(sale.inflow, cup.sellPrice * 8 + bottle.sellPrice * 2);
    expect(sale.outflow, 0);
  });

  test('master product: add, edit, deactivate drops from active list', () async {
    final svc = ProductService(db);

    Future<List<Product>> active() =>
        (db.select(db.products)..where((t) => t.active.equals(true))).get();
    final before = (await active()).length;

    // Add a new gallon → isGallon derived from category.
    await svc.save(const ProductsCompanion(
      name: Value('Galon RO 19L'),
      category: Value('gallon'),
      isGallon: Value(true),
      buyPrice: Value(14000),
      sellPrice: Value(17000),
    ));
    var rows = await active();
    expect(rows.length, before + 1);
    final added = rows.firstWhere((p) => p.name == 'Galon RO 19L');
    expect(added.isGallon, isTrue);

    // Edit the sell price.
    await svc.save(const ProductsCompanion(sellPrice: Value(18000)),
        id: added.id);
    final edited = await (db.select(db.products)
          ..where((t) => t.id.equals(added.id)))
        .getSingle();
    expect(edited.sellPrice, 18000);
    expect(edited.name, 'Galon RO 19L'); // other fields untouched

    // Deactivate → drops from active list, row still exists.
    await svc.setActive(added.id, false);
    expect((await active()).where((p) => p.id == added.id), isEmpty);
    expect(
        await (db.select(db.products)..where((t) => t.id.equals(added.id)))
            .getSingleOrNull(),
        isNotNull);
  });

  test('stock take: difference recorded, no-op when equal', () async {
    final stockTake = StockTakeService(db);
    final p = await (db.select(db.products)..limit(1)).getSingle();

    // System 0 → physical 12: write difference +12.
    await stockTake.adjustStock(p.id, 12);
    expect(await db.stockOf(p.id), 12);

    // Same physical (12): no-op, no new row.
    final rowsBefore = (await db.select(db.stockMovements).get()).length;
    await stockTake.adjustStock(p.id, 12);
    expect((await db.select(db.stockMovements).get()).length, rowsBefore);

    // Physical down to 10: difference -2.
    await stockTake.adjustStock(p.id, 10);
    expect(await db.stockOf(p.id), 10);
  });

  test('stock take gallon: correct negative empty to the real count', () async {
    final gallon = GallonService(db);
    final stockTake = StockTakeService(db);

    // Restock swap makes empty negative (opening stock not recorded).
    await gallon.recordRestockExchange(qty: 10); // full +10, empty -10
    var b = await db.gallonBalance();
    expect(b.empty, -10);

    // Stock take: real physical full 10, empty 5, depositOut 0.
    await stockTake.adjustGallon(full: 10, empty: 5, depositOut: 0);
    b = await db.gallonBalance();
    expect(b.full, 10);
    expect(b.empty, 5); // -10 corrected by +15 to 5
    expect(b.depositOut, 0);
  });

  test('sync: pendingRows respects the per-table cursor', () async {
    final sync = SyncService(db, deviceId: 'dev-test');

    // Seed = 8 products, cursor 0 → all pending.
    var pending = await sync.pendingRows(db.products);
    expect(pending.length, 8);
    expect(pending.first['id'], 1);
    expect(pending.first.containsKey('name'), isTrue);

    // Advance cursor to 5 → only ids 6,7,8 pending.
    await db.into(db.syncCursors).insertOnConflictUpdate(
        SyncCursorsCompanion.insert(entity: 'products', lastId: const Value(5)));
    pending = await sync.pendingRows(db.products);
    expect(pending.map((r) => r['id']), [6, 7, 8]);
  });

  test('sync: pushPending is a no-op without a client (offline)', () async {
    final sync = SyncService(db, deviceId: 'dev-test'); // client null
    expect(sync.enabled, isFalse);
    expect(await sync.pushPending(), 0);
  });
}
