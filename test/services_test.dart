import 'package:amdk_pos/data/database/database.dart';
import 'package:amdk_pos/data/sync/sync_service.dart';
import 'package:amdk_pos/domain/services/cashier_service.dart';
import 'package:amdk_pos/domain/services/credit_service.dart';
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
    // Gallons carry a per-product container price; non-gallons don't.
    expect(products.where((p) => p.isGallon).every((p) => p.depositPrice > 0),
        isTrue);
    expect(products.where((p) => !p.isGallon).every((p) => p.depositPrice == 0),
        isTrue);
  });

  test('recordSale: stock out, cash in, revenue correct', () async {
    final sales = SalesService(db, GallonService(db));
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

  test('gallon: new sale (one price, no deposit), then exchange, container '
      'balance consistent', () async {
    final gallon = GallonService(db);

    // Restock 10 filled gallons (empty swap — empty goes negative, expected
    // for opening stock; the opening adjustment follows in the stock UI).
    await gallon.recordRestockExchange(qty: 10);

    // New customer: 2 brand-new gallons — container leaves the fleet for
    // good, no dEmpty/dDeposit written.
    await gallon.recordNewGallonSale(qty: 2);
    var b = await db.gallonBalance();
    expect(b.full, 8);

    // Subscriber: exchange 1 gallon (isi ulang, bawa kosong).
    await gallon.recordExchange(qty: 1);
    b = await db.gallonBalance();
    expect(b.full, 7);
    expect(b.empty, -10 + 1); // -10 from restock swap + 1 from the customer
  });

  test('cashier closing: difference recorded as adjustment, not overwrite',
      () async {
    final sales = SalesService(db, GallonService(db));
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
    final purchase = PurchaseService(db, GallonService(db));
    final p = await (db.select(db.products)..limit(1)).getSingle();

    await purchase.recordPurchase(
        lines: [PurchaseLine(productId: p.id, qtyBase: 10, price: p.buyPrice)]);

    expect(await db.stockOf(p.id), 10);
    expect(await db.cashBalance(), -p.buyPrice * 10); // money out
  });

  test('purchase on debt: stock in, cash UNCHANGED', () async {
    final purchase = PurchaseService(db, GallonService(db));
    final p = await (db.select(db.products)..limit(1)).getSingle();

    await purchase.recordPurchase(
      lines: [PurchaseLine(productId: p.id, qtyBase: 5, price: p.buyPrice)],
      paymentStatus: 'debt',
    );

    expect(await db.stockOf(p.id), 5);
    expect(await db.cashBalance(), 0); // not paid, cash unchanged
  });

  test('gallon restock + empty swap: water stock up, container moves', () async {
    final purchase = PurchaseService(db, GallonService(db));
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
    final sales = SalesService(db, GallonService(db));
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

    // Stock take: real physical full 10, empty 5.
    await stockTake.adjustGallon(full: 10, empty: 5);
    b = await db.gallonBalance();
    expect(b.full, 10);
    expect(b.empty, 5); // -10 corrected by +15 to 5
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

  test('credit sale: no cash in, revenue still counts, receivable tracked',
      () async {
    final sales = SalesService(db, GallonService(db));
    final credit = CreditService(db);
    final customerId =
        await db.into(db.customers).insert(CustomersCompanion.insert(name: 'Warung Bu Ani'));
    final p = await (db.select(db.products)..limit(1)).getSingle();

    await sales.recordSale(
      lines: [SaleLine(productId: p.id, qtyBase: 4, price: p.sellPrice)],
      customerId: customerId,
      paymentStatus: 'receivable',
    );

    // No cash collected yet…
    expect(await db.cashBalance(), 0);
    // …but revenue is booked and stock went out.
    final summary = await ReportsService(db).dailySummary(DateTime.now());
    expect(summary.revenue, p.sellPrice * 4);
    expect(await db.stockOf(p.id), -4);
    // Receivable = the sale total.
    expect(await credit.receivableBalance(customerId), p.sellPrice * 4);
  });

  test('receivable payment: cash in, balance drops, not double-counted revenue',
      () async {
    final sales = SalesService(db, GallonService(db));
    final credit = CreditService(db);
    final customerId =
        await db.into(db.customers).insert(CustomersCompanion.insert(name: 'Warung Bu Ani'));
    final p = await (db.select(db.products)..limit(1)).getSingle();
    final total = p.sellPrice * 4;

    await sales.recordSale(
      lines: [SaleLine(productId: p.id, qtyBase: 4, price: p.sellPrice)],
      customerId: customerId,
      paymentStatus: 'receivable',
    );

    // Partial payment.
    await credit.recordReceivablePayment(customerId: customerId, amount: 5000);
    expect(await db.cashBalance(), 5000);
    expect(await credit.receivableBalance(customerId), total - 5000);
    expect((await credit.customersWithReceivable()).single.balance, total - 5000);

    // Pay the rest → balance zero, drops off the list.
    await credit.recordReceivablePayment(
        customerId: customerId, amount: total - 5000);
    expect(await credit.receivableBalance(customerId), 0);
    expect(await credit.customersWithReceivable(), isEmpty);

    // Payments are cash, NOT extra revenue (revenue booked once at sale).
    final summary = await ReportsService(db).dailySummary(DateTime.now());
    expect(summary.revenue, total);
    expect(await db.cashBalance(), total);
  });

  test('supplier debt: purchase on debt then pay, balance drops', () async {
    final purchase = PurchaseService(db, GallonService(db));
    final credit = CreditService(db);
    final supplierId =
        await db.into(db.suppliers).insert(SuppliersCompanion.insert(name: 'Agen Cleo'));
    final p = await (db.select(db.products)..limit(1)).getSingle();
    final total = p.buyPrice * 10;

    await purchase.recordPurchase(
      lines: [PurchaseLine(productId: p.id, qtyBase: 10, price: p.buyPrice)],
      paymentStatus: 'debt',
      supplierId: supplierId,
    );

    expect(await db.stockOf(p.id), 10); // stock in regardless
    expect(await db.cashBalance(), 0); // no cash out yet
    expect(await credit.debtBalance(supplierId), total);

    await credit.recordDebtPayment(supplierId: supplierId, amount: total);
    expect(await db.cashBalance(), -total); // cash out on payment
    expect(await credit.debtBalance(supplierId), 0);
    expect(await credit.suppliersWithDebt(), isEmpty);
  });

  test('recordSale gallon newCustomer: one price (water + container), '
      'no deposit, container leaves the fleet', () async {
    final sales = SalesService(db, GallonService(db));
    final customerId = await db
        .into(db.customers)
        .insert(CustomersCompanion.insert(name: 'Pak Budi'));
    final g = await (db.select(db.products)
          ..where((t) => t.isGallon.equals(true))
          ..limit(1))
        .getSingle();
    final onePrice = g.sellPrice + g.depositPrice;

    // One recordSale call: water + container in a single priced line.
    await sales.recordSale(
      lines: [
        SaleLine(
          productId: g.id,
          qtyBase: 2,
          price: onePrice,
          gallonMode: GallonSaleMode.newCustomer,
        ),
      ],
      customerId: customerId,
    );

    // Water out, container leaves for good (full -2, no empty/deposit),
    // cash = the one combined price. All revenue, no liability.
    expect(await db.stockOf(g.id), -2);
    final b = await db.gallonBalance();
    expect(b.full, -2);
    expect(b.empty, 0);
    expect(await db.cashBalance(), onePrice * 2);
    final summary = await ReportsService(db).dailySummary(DateTime.now());
    expect(summary.revenue, onePrice * 2);

    // Ledger row is attributed to the customer (informational, not liability).
    final ledger = await (db.select(db.gallonLedger)
          ..where((t) => t.type.equals('sale_new')))
        .getSingle();
    expect(ledger.customerId, customerId);
  });

  test('recordSale rolls back atomically if the gallon step fails', () async {
    // The whole sale (water + container) is one transaction: if the gallon
    // step throws, the already-written header/stock/cash must roll back too.
    final sales = SalesService(db, _ThrowingGallon(db));
    final customerId = await db
        .into(db.customers)
        .insert(CustomersCompanion.insert(name: 'Pak Budi'));
    final g = await (db.select(db.products)
          ..where((t) => t.isGallon.equals(true))
          ..limit(1))
        .getSingle();

    await expectLater(
      sales.recordSale(
        lines: [
          SaleLine(
            productId: g.id,
            qtyBase: 1,
            price: g.sellPrice + g.depositPrice,
            gallonMode: GallonSaleMode.newCustomer,
          ),
        ],
        customerId: customerId,
      ),
      throwsA(anything),
    );

    // Nothing committed: no sale, no stock move, no cash.
    expect(await db.select(db.sales).get(), isEmpty);
    expect(await db.stockOf(g.id), 0);
    expect(await db.cashBalance(), 0);
    expect((await db.gallonBalance()).full, 0);
  });

  test('periodReport aggregates across days; dailyReport stays single-day',
      () async {
    final reports = ReportsService(db);
    final p = await (db.select(db.products)..limit(1)).getSingle();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Historical row (yesterday) written directly — the service always
    // stamps "now", so backdated data is set up straight on the ledger.
    final ySaleId = await db.into(db.sales).insert(SalesCompanion.insert(
        date: Value(yesterday), totalAmount: Value(p.sellPrice * 2)));
    await db.into(db.saleItems).insert(SaleItemsCompanion.insert(
        saleId: ySaleId,
        productId: p.id,
        qtyBase: 2,
        price: p.sellPrice,
        subtotal: p.sellPrice * 2));
    await db.into(db.cashEntries).insert(CashEntriesCompanion.insert(
        date: Value(yesterday),
        direction: 'in',
        amount: p.sellPrice * 2,
        category: 'sale'));

    // Today via the real service.
    final sales = SalesService(db, GallonService(db));
    await sales.recordSale(
        lines: [SaleLine(productId: p.id, qtyBase: 3, price: p.sellPrice)]);

    // dailyReport(today) only sees today's 3.
    final onlyToday = await reports.dailyReport(today);
    expect(onlyToday.summary.revenue, p.sellPrice * 3);

    // periodReport spanning both days sees 2 + 3 = 5.
    final period = await reports.periodReport(
        yesterday, today.add(const Duration(days: 1)));
    expect(period.summary.revenue, p.sellPrice * 5);
    expect(period.byProduct.single.qty, 5);
    expect(period.summary.cashIn, p.sellPrice * 5);
  });
}

/// Gallon service that fails the new-sale step, to test transaction rollback.
class _ThrowingGallon extends GallonService {
  _ThrowingGallon(super.db);
  @override
  Future<void> recordNewGallonSale({
    required int qty,
    int? customerId,
    int? saleId,
  }) async {
    throw Exception('gallon step failed');
  }
}
