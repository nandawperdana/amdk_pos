import 'package:amdk_pos/data/database/database.dart';
import 'package:amdk_pos/domain/services/cashier_service.dart';
import 'package:amdk_pos/domain/services/galon_service.dart';
import 'package:amdk_pos/domain/services/opname_service.dart';
import 'package:amdk_pos/domain/services/product_service.dart';
import 'package:amdk_pos/domain/services/purchase_service.dart';
import 'package:amdk_pos/domain/services/reports_service.dart';
import 'package:amdk_pos/domain/services/sales_service.dart';
import 'package:amdk_pos/data/sync/sync_service.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('seed produk terisi saat DB dibuat', () async {
    final products = await db.select(db.products).get();
    expect(products, isNotEmpty);
    expect(products.where((p) => p.isGalon), isNotEmpty);
    expect(products.every((p) => p.sellPrice > p.buyPrice), isTrue);
  });

  test('recordSale: stok keluar, kas masuk, omzet benar', () async {
    final sales = SalesService(db);
    final p = await (db.select(db.products)
          ..where((t) => t.isGalon.equals(false))
          ..limit(1))
        .getSingle();

    await sales.recordSale(lines: [
      SaleLine(productId: p.id, qtyBase: 3, price: p.sellPrice),
    ]);

    expect(await db.stockOf(p.id), -3); // belum ada kulakan → minus
    expect(await db.cashBalance(), p.sellPrice * 3);

    final summary = await ReportsService(db).dailySummary(DateTime.now());
    expect(summary.omzet, p.sellPrice * 3);
    expect(summary.labaKotor, (p.sellPrice - p.buyPrice) * 3);
  });

  test('galon: jual baru + deposit, lalu tukar, saldo wadah konsisten', () async {
    final galon = GalonService(db);

    // Kulakan 10 galon isi (tukar kosong — saldo kosong jadi minus, wajar
    // untuk stok awal; penyesuaian stok awal menyusul di UI stok).
    await galon.recordRestockExchange(qty: 10);

    // Pelanggan baru: 2 galon + deposit.
    await galon.recordNewGalonSale(qty: 2, depositPerGalon: 40000);
    var b = await db.galonBalance();
    expect(b.full, 8);
    expect(b.depositOut, 2); // wadah beredar = kewajiban

    // Deposit masuk kas TAPI bukan omzet.
    expect(await db.cashBalance(), 80000);
    final summary = await ReportsService(db).dailySummary(DateTime.now());
    expect(summary.omzet, 0);

    // Langganan: tukar 1 galon.
    await galon.recordExchange(qty: 1);
    b = await db.galonBalance();
    expect(b.full, 7);
    expect(b.empty, -10 + 1); // -10 dari kulakan tukar + 1 dari pelanggan
    expect(b.depositOut, 2);
  });

  test('tutup kasir: selisih dicatat sebagai penyesuaian, bukan overwrite', () async {
    final sales = SalesService(db);
    final cashier = CashierService(db);
    final p = await (db.select(db.products)..limit(1)).getSingle();

    await sales.recordSale(
        lines: [SaleLine(productId: p.id, qtyBase: 1, price: p.sellPrice)]);
    final systemBalance = await db.cashBalance();

    expect(await cashier.openingBalance(), 0); // belum pernah tutup

    // Fisik kurang dari sistem (misal ada uang kembalian salah hitung).
    const shortage = 500.0;
    await cashier.recordClosing(physicalCount: systemBalance - shortage);

    // Selisih tercatat sebagai baris kas baru, bukan mengubah baris lama.
    expect(await db.cashBalance(), systemBalance - shortage);
    final entries = await db.select(db.cashEntries).get();
    expect(entries.where((e) => e.category == 'penyesuaian'), hasLength(1));

    // Closing berikutnya mulai dari hitungan fisik closing sebelumnya.
    expect(await cashier.openingBalance(), systemBalance - shortage);
  });

  test('kulakan lunas: stok masuk, kas keluar', () async {
    final purchase = PurchaseService(db);
    final p = await (db.select(db.products)..limit(1)).getSingle();

    await purchase.recordPurchase(
        lines: [PurchaseLine(productId: p.id, qtyBase: 10, price: p.buyPrice)]);

    expect(await db.stockOf(p.id), 10);
    expect(await db.cashBalance(), -p.buyPrice * 10); // uang keluar
  });

  test('kulakan utang: stok masuk, kas TIDAK berubah', () async {
    final purchase = PurchaseService(db);
    final p = await (db.select(db.products)..limit(1)).getSingle();

    await purchase.recordPurchase(
      lines: [PurchaseLine(productId: p.id, qtyBase: 5, price: p.buyPrice)],
      paymentStatus: 'utang',
    );

    expect(await db.stockOf(p.id), 5);
    expect(await db.cashBalance(), 0); // belum bayar, kas tetap
  });

  test('kulakan galon isi + tukar kosong: air stok naik, wadah bergerak', () async {
    final purchase = PurchaseService(db);
    final galon = GalonService(db);
    final g = await (db.select(db.products)..where((t) => t.isGalon.equals(true))
          ..limit(1))
        .getSingle();

    await purchase.recordPurchase(
        lines: [PurchaseLine(productId: g.id, qtyBase: 20, price: g.buyPrice)]);
    await galon.recordRestockExchange(qty: 20);

    expect(await db.stockOf(g.id), 20); // air siap jual
    final b = await db.galonBalance();
    expect(b.full, 20); // wadah isi
    expect(b.empty, -20); // kosong ditukar ke agen
  });

  test('laporan harian: rincian per produk & per kategori kas', () async {
    final sales = SalesService(db);
    final reports = ReportsService(db);
    final gelas = await (db.select(db.products)
          ..where((t) => t.category.equals('gelas'))
          ..limit(1))
        .getSingle();
    final botol = await (db.select(db.products)
          ..where((t) => t.category.equals('botol'))
          ..limit(1))
        .getSingle();

    // Dua transaksi: gelas ×5, botol ×2, lalu gelas ×3 lagi (harus diagregasi).
    await sales.recordSale(
        lines: [SaleLine(productId: gelas.id, qtyBase: 5, price: gelas.sellPrice)]);
    await sales.recordSale(lines: [
      SaleLine(productId: botol.id, qtyBase: 2, price: botol.sellPrice),
      SaleLine(productId: gelas.id, qtyBase: 3, price: gelas.sellPrice),
    ]);

    final r = await reports.dailyReport(DateTime.now());

    // Per produk: gelas teragregasi jadi 8 pcs.
    final gelasRow = r.byProduct.firstWhere((p) => p.name == gelas.name);
    expect(gelasRow.qty, 8);
    expect(gelasRow.revenue, gelas.sellPrice * 8);
    expect(gelasRow.profit, (gelas.sellPrice - gelas.buyPrice) * 8);
    // Urut omzet desc.
    expect(r.byProduct.first.revenue >= r.byProduct.last.revenue, isTrue);

    // Kas: semua penjualan masuk kategori 'penjualan'.
    final jual = r.byCategory.firstWhere((c) => c.category == 'penjualan');
    expect(jual.masuk, gelas.sellPrice * 8 + botol.sellPrice * 2);
    expect(jual.keluar, 0);
  });

  test('master produk: tambah, edit, nonaktif hilang dari daftar aktif', () async {
    final svc = ProductService(db);

    Future<List<Product>> active() =>
        (db.select(db.products)..where((t) => t.active.equals(true))).get();
    final before = (await active()).length;

    // Tambah galon baru → isGalon otomatis dari kategori.
    await svc.save(const ProductsCompanion(
      name: Value('Galon RO 19L'),
      category: Value('galon'),
      isGalon: Value(true),
      buyPrice: Value(14000),
      sellPrice: Value(17000),
    ));
    var rows = await active();
    expect(rows.length, before + 1);
    final baru = rows.firstWhere((p) => p.name == 'Galon RO 19L');
    expect(baru.isGalon, isTrue);

    // Edit harga jual.
    await svc.save(const ProductsCompanion(sellPrice: Value(18000)),
        id: baru.id);
    final edited = await (db.select(db.products)
          ..where((t) => t.id.equals(baru.id)))
        .getSingle();
    expect(edited.sellPrice, 18000);
    expect(edited.name, 'Galon RO 19L'); // field lain tak tersentuh

    // Nonaktifkan → hilang dari daftar aktif, baris tetap ada.
    await svc.setActive(baru.id, false);
    expect((await active()).where((p) => p.id == baru.id), isEmpty);
    expect(
        await (db.select(db.products)..where((t) => t.id.equals(baru.id)))
            .getSingleOrNull(),
        isNotNull);
  });

  test('opname stok: selisih dicatat, no-op kalau sama', () async {
    final opname = OpnameService(db);
    final p = await (db.select(db.products)..limit(1)).getSingle();

    // Sistem 0 → fisik 12: tulis selisih +12.
    await opname.adjustStock(p.id, 12);
    expect(await db.stockOf(p.id), 12);

    // Fisik sama (12): no-op, tak ada baris baru.
    final rowsBefore = (await db.select(db.stockMovements).get()).length;
    await opname.adjustStock(p.id, 12);
    expect((await db.select(db.stockMovements).get()).length, rowsBefore);

    // Fisik turun ke 10: selisih -2.
    await opname.adjustStock(p.id, 10);
    expect(await db.stockOf(p.id), 10);
  });

  test('opname galon: koreksi kosong minus ke fisik nyata', () async {
    final galon = GalonService(db);
    final opname = OpnameService(db);

    // Kulakan tukar bikin kosong minus (stok awal belum dicatat).
    await galon.recordRestockExchange(qty: 10); // isi +10, kosong -10
    var b = await db.galonBalance();
    expect(b.empty, -10);

    // Opname: fisik nyata isi 10, kosong 5, beredar 0.
    await opname.adjustGalon(isi: 10, kosong: 5, beredar: 0);
    b = await db.galonBalance();
    expect(b.full, 10);
    expect(b.empty, 5); // -10 dikoreksi +15 jadi 5
    expect(b.depositOut, 0);
  });

  test('sync: pendingRows hormati cursor per tabel', () async {
    final sync = SyncService(db, deviceId: 'dev-test');

    // Seed = 8 produk, cursor 0 → semua tertunda.
    var pending = await sync.pendingRows(db.products);
    expect(pending.length, 8);
    expect(pending.first['id'], 1);
    expect(pending.first.containsKey('name'), isTrue);

    // Majukan cursor ke 5 → hanya id 6,7,8 tertunda.
    await db.into(db.syncCursors).insertOnConflictUpdate(
        SyncCursorsCompanion.insert(entity: 'products', lastId: const Value(5)));
    pending = await sync.pendingRows(db.products);
    expect(pending.map((r) => r['id']), [6, 7, 8]);
  });

  test('sync: pushPending no-op tanpa client (offline)', () async {
    final sync = SyncService(db, deviceId: 'dev-test'); // client null
    expect(sync.enabled, isFalse);
    expect(await sync.pushPending(), 0);
  });
}
