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
}
