import 'package:drift/drift.dart';

import '../../data/database/database.dart';

class DailySummary {
  final double omzet;
  final double labaKotor; // omzet - HPP
  final double kasMasuk;
  final double kasKeluar;
  const DailySummary({
    required this.omzet,
    required this.labaKotor,
    required this.kasMasuk,
    required this.kasKeluar,
  });
}

/// Penjualan satu produk dalam sehari.
class ProductSales {
  final String name;
  final int qty;
  final double revenue;
  final double profit; // revenue - HPP
  const ProductSales({
    required this.name,
    required this.qty,
    required this.revenue,
    required this.profit,
  });
}

/// Arus kas per kategori dalam sehari (mis. 'penjualan', 'pembelian',
/// 'deposit_galon', 'penyesuaian').
class CashByCategory {
  final String category;
  final double masuk;
  final double keluar;
  const CashByCategory({
    required this.category,
    required this.masuk,
    required this.keluar,
  });
  double get net => masuk - keluar;
}

/// Laporan harian lengkap: ringkasan + rincian per produk & per kategori kas.
class DailyReport {
  final DailySummary summary;
  final List<ProductSales> byProduct; // urut omzet desc
  final List<CashByCategory> byCategory;
  const DailyReport({
    required this.summary,
    required this.byProduct,
    required this.byCategory,
  });
}

class ReportsService {
  final AppDatabase db;
  ReportsService(this.db);

  /// Ringkasan harian. HPP = buyPrice produk × qty terjual.
  /// Catatan: query produk di loop (N+1) sengaja dibiarkan sederhana untuk
  /// scaffold — optimalkan dengan JOIN saat volume transaksi membesar.
  Future<DailySummary> dailySummary(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    final sales = await (db.select(db.sales)
          ..where((s) =>
              s.date.isBiggerOrEqualValue(start) &
              s.date.isSmallerThanValue(end)))
        .get();
    final saleIds = sales.map((s) => s.id).toList();

    double omzet = 0, hpp = 0;
    if (saleIds.isNotEmpty) {
      final items = await (db.select(db.saleItems)
            ..where((i) => i.saleId.isIn(saleIds)))
          .get();
      for (final it in items) {
        omzet += it.subtotal;
        final p = await (db.select(db.products)
              ..where((p) => p.id.equals(it.productId)))
            .getSingleOrNull();
        hpp += (p?.buyPrice ?? 0) * it.qtyBase;
      }
    }

    final cash = await (db.select(db.cashEntries)
          ..where((c) =>
              c.date.isBiggerOrEqualValue(start) &
              c.date.isSmallerThanValue(end)))
        .get();
    double masuk = 0, keluar = 0;
    for (final c in cash) {
      if (c.direction == 'masuk') {
        masuk += c.amount;
      } else {
        keluar += c.amount;
      }
    }

    return DailySummary(
      omzet: omzet,
      labaKotor: omzet - hpp,
      kasMasuk: masuk,
      kasKeluar: keluar,
    );
  }

  /// Laporan harian lengkap dengan rincian per produk & per kategori kas.
  /// N+1 lookup produk dibiarkan sederhana (sama seperti dailySummary) —
  /// optimalkan dengan JOIN saat volume membesar.
  Future<DailyReport> dailyReport(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    final sales = await (db.select(db.sales)
          ..where((s) =>
              s.date.isBiggerOrEqualValue(start) &
              s.date.isSmallerThanValue(end)))
        .get();
    final saleIds = sales.map((s) => s.id).toList();

    // Agregasi per produk.
    final agg = <int, ({String name, int qty, double revenue, double profit})>{};
    double omzet = 0, hpp = 0;
    if (saleIds.isNotEmpty) {
      final items = await (db.select(db.saleItems)
            ..where((i) => i.saleId.isIn(saleIds)))
          .get();
      for (final it in items) {
        final p = await (db.select(db.products)
              ..where((p) => p.id.equals(it.productId)))
            .getSingleOrNull();
        final itemHpp = (p?.buyPrice ?? 0) * it.qtyBase;
        omzet += it.subtotal;
        hpp += itemHpp;
        final prev = agg[it.productId];
        agg[it.productId] = (
          name: p?.name ?? 'Produk #${it.productId}',
          qty: (prev?.qty ?? 0) + it.qtyBase,
          revenue: (prev?.revenue ?? 0) + it.subtotal,
          profit: (prev?.profit ?? 0) + (it.subtotal - itemHpp),
        );
      }
    }
    final byProduct = agg.values
        .map((e) => ProductSales(
            name: e.name, qty: e.qty, revenue: e.revenue, profit: e.profit))
        .toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    // Kas per kategori.
    final cash = await (db.select(db.cashEntries)
          ..where((c) =>
              c.date.isBiggerOrEqualValue(start) &
              c.date.isSmallerThanValue(end)))
        .get();
    final catAgg = <String, ({double masuk, double keluar})>{};
    double masuk = 0, keluar = 0;
    for (final c in cash) {
      final prev = catAgg[c.category] ?? (masuk: 0.0, keluar: 0.0);
      if (c.direction == 'masuk') {
        masuk += c.amount;
        catAgg[c.category] = (masuk: prev.masuk + c.amount, keluar: prev.keluar);
      } else {
        keluar += c.amount;
        catAgg[c.category] = (masuk: prev.masuk, keluar: prev.keluar + c.amount);
      }
    }
    final byCategory = catAgg.entries
        .map((e) => CashByCategory(
            category: e.key, masuk: e.value.masuk, keluar: e.value.keluar))
        .toList()
      ..sort((a, b) => b.net.abs().compareTo(a.net.abs()));

    return DailyReport(
      summary: DailySummary(
        omzet: omzet,
        labaKotor: omzet - hpp,
        kasMasuk: masuk,
        kasKeluar: keluar,
      ),
      byProduct: byProduct,
      byCategory: byCategory,
    );
  }
}
