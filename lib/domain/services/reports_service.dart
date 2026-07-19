import 'package:drift/drift.dart';

import '../../data/database/database.dart';

class DailySummary {
  final double revenue;
  final double grossProfit; // revenue - COGS
  final double cashIn;
  final double cashOut;
  const DailySummary({
    required this.revenue,
    required this.grossProfit,
    required this.cashIn,
    required this.cashOut,
  });
}

/// Sales of a single product within a day.
class ProductSales {
  final String name;
  final int qty;
  final double revenue;
  final double profit; // revenue - COGS
  const ProductSales({
    required this.name,
    required this.qty,
    required this.revenue,
    required this.profit,
  });
}

/// Cash flow per category within a day (e.g. 'sale', 'purchase', 'adjustment').
class CashByCategory {
  final String category;
  final double inflow;
  final double outflow;
  const CashByCategory({
    required this.category,
    required this.inflow,
    required this.outflow,
  });
  double get net => inflow - outflow;
}

/// Full daily report: summary + per-product & per-cash-category breakdown.
class DailyReport {
  final DailySummary summary;
  final List<ProductSales> byProduct; // sorted by revenue desc
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

  /// Single-day summary — convenience wrapper over [periodSummary].
  Future<DailySummary> dailySummary(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    return periodSummary(start, start.add(const Duration(days: 1)));
  }

  /// Single-day report — convenience wrapper over [periodReport].
  Future<DailyReport> dailyReport(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    return periodReport(start, start.add(const Duration(days: 1)));
  }

  /// Summary over [start, end) — any range, a day or a month.
  /// COGS = product buyPrice × qty sold.
  /// Note: the per-product lookup in a loop (N+1) is left simple for the
  /// scaffold — optimize with a JOIN once transaction volume grows.
  Future<DailySummary> periodSummary(DateTime start, DateTime end) async {
    final sales = await (db.select(db.sales)
          ..where((s) =>
              s.date.isBiggerOrEqualValue(start) &
              s.date.isSmallerThanValue(end)))
        .get();
    final saleIds = sales.map((s) => s.id).toList();

    double revenue = 0, cogs = 0;
    if (saleIds.isNotEmpty) {
      final items = await (db.select(db.saleItems)
            ..where((i) => i.saleId.isIn(saleIds)))
          .get();
      for (final it in items) {
        revenue += it.subtotal;
        final p = await (db.select(db.products)
              ..where((p) => p.id.equals(it.productId)))
            .getSingleOrNull();
        cogs += (p?.buyPrice ?? 0) * it.qtyBase;
      }
    }

    final cash = await (db.select(db.cashEntries)
          ..where((c) =>
              c.date.isBiggerOrEqualValue(start) &
              c.date.isSmallerThanValue(end)))
        .get();
    double inflow = 0, outflow = 0;
    for (final c in cash) {
      if (c.direction == 'in') {
        inflow += c.amount;
      } else {
        outflow += c.amount;
      }
    }

    return DailySummary(
      revenue: revenue,
      grossProfit: revenue - cogs,
      cashIn: inflow,
      cashOut: outflow,
    );
  }

  /// Full report over [start, end) with per-product & per-cash-category
  /// breakdown. The N+1 product lookup is left simple (same as
  /// periodSummary) — optimize with a JOIN once volume grows.
  Future<DailyReport> periodReport(DateTime start, DateTime end) async {
    final sales = await (db.select(db.sales)
          ..where((s) =>
              s.date.isBiggerOrEqualValue(start) &
              s.date.isSmallerThanValue(end)))
        .get();
    final saleIds = sales.map((s) => s.id).toList();

    // Aggregate per product.
    final agg = <int, ({String name, int qty, double revenue, double profit})>{};
    double revenue = 0, cogs = 0;
    if (saleIds.isNotEmpty) {
      final items = await (db.select(db.saleItems)
            ..where((i) => i.saleId.isIn(saleIds)))
          .get();
      for (final it in items) {
        final p = await (db.select(db.products)
              ..where((p) => p.id.equals(it.productId)))
            .getSingleOrNull();
        final itemCogs = (p?.buyPrice ?? 0) * it.qtyBase;
        revenue += it.subtotal;
        cogs += itemCogs;
        final prev = agg[it.productId];
        agg[it.productId] = (
          name: p?.name ?? 'Produk #${it.productId}',
          qty: (prev?.qty ?? 0) + it.qtyBase,
          revenue: (prev?.revenue ?? 0) + it.subtotal,
          profit: (prev?.profit ?? 0) + (it.subtotal - itemCogs),
        );
      }
    }
    final byProduct = agg.values
        .map((e) => ProductSales(
            name: e.name, qty: e.qty, revenue: e.revenue, profit: e.profit))
        .toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    // Cash per category.
    final cash = await (db.select(db.cashEntries)
          ..where((c) =>
              c.date.isBiggerOrEqualValue(start) &
              c.date.isSmallerThanValue(end)))
        .get();
    final catAgg = <String, ({double inflow, double outflow})>{};
    double inflow = 0, outflow = 0;
    for (final c in cash) {
      final prev = catAgg[c.category] ?? (inflow: 0.0, outflow: 0.0);
      if (c.direction == 'in') {
        inflow += c.amount;
        catAgg[c.category] =
            (inflow: prev.inflow + c.amount, outflow: prev.outflow);
      } else {
        outflow += c.amount;
        catAgg[c.category] =
            (inflow: prev.inflow, outflow: prev.outflow + c.amount);
      }
    }
    final byCategory = catAgg.entries
        .map((e) => CashByCategory(
            category: e.key, inflow: e.value.inflow, outflow: e.value.outflow))
        .toList()
      ..sort((a, b) => b.net.abs().compareTo(a.net.abs()));

    return DailyReport(
      summary: DailySummary(
        revenue: revenue,
        grossProfit: revenue - cogs,
        cashIn: inflow,
        cashOut: outflow,
      ),
      byProduct: byProduct,
      byCategory: byCategory,
    );
  }
}
