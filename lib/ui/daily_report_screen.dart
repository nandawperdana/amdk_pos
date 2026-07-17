import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/services/reports_service.dart';
import '../main.dart';
import 'pos_screen.dart' show rupiah;

final _selectedDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final _reportProvider = FutureProvider.autoDispose<DailyReport>((ref) {
  final day = ref.watch(_selectedDayProvider);
  return ref.watch(reportsServiceProvider).dailyReport(day);
});

final _dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');

/// Cash category value → friendly Indonesian label for the owner.
const _categoryLabel = {
  'sale': 'Penjualan',
  'purchase': 'Pembelian/kulakan',
  'gallon_deposit': 'Deposit galon',
  'adjustment': 'Penyesuaian kas',
  'expense': 'Biaya',
  'capital': 'Modal',
  'drawing': 'Prive',
};

class DailyReportScreen extends ConsumerWidget {
  const DailyReportScreen({super.key});

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final current = ref.read(_selectedDayProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      ref.read(_selectedDayProvider.notifier).state =
          DateTime(picked.year, picked.month, picked.day);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(_selectedDayProvider);
    final report = ref.watch(_reportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Harian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Pilih tanggal',
            onPressed: () => _pickDate(context, ref),
          ),
        ],
      ),
      body: report.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (r) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Text(_dateFormat.format(day),
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 16),
            _summaryCards(context, r.summary),
            const SizedBox(height: 16),
            _section(context, 'Penjualan per produk'),
            if (r.byProduct.isEmpty)
              const _EmptyRow('Belum ada penjualan hari ini')
            else
              ...r.byProduct.map((p) => Card(
                    child: ListTile(
                      title: Text(p.name),
                      subtitle: Text('${p.qty} pcs · laba '
                          '${rupiah.format(p.profit)}'),
                      trailing: Text(rupiah.format(p.revenue),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  )),
            const SizedBox(height: 16),
            _section(context, 'Arus kas per kategori'),
            if (r.byCategory.isEmpty)
              const _EmptyRow('Belum ada arus kas hari ini')
            else
              ...r.byCategory.map((c) => Card(
                    child: ListTile(
                      title: Text(_categoryLabel[c.category] ?? c.category),
                      subtitle: Text(
                          'masuk ${rupiah.format(c.inflow)} · '
                          'keluar ${rupiah.format(c.outflow)}'),
                      trailing: Text(
                        '${c.net >= 0 ? '+' : ''}${rupiah.format(c.net)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: c.net >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _summaryCards(BuildContext context, DailySummary s) {
    Widget tile(String label, String value, {Color? color}) => Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(value,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: color)),
                ],
              ),
            ),
          ),
        );
    return Column(
      children: [
        Row(children: [
          tile('Omzet', rupiah.format(s.revenue)),
          tile('Laba kotor', rupiah.format(s.grossProfit),
              color: Colors.green),
        ]),
        Row(children: [
          tile('Kas masuk', rupiah.format(s.cashIn)),
          tile('Kas keluar', rupiah.format(s.cashOut)),
        ]),
      ],
    );
  }

  Widget _section(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _EmptyRow extends StatelessWidget {
  final String text;
  const _EmptyRow(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(text,
            style: TextStyle(color: Theme.of(context).colorScheme.outline)),
      );
}
