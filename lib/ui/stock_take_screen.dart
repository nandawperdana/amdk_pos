import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/database.dart';
import '../main.dart';

/// Stock-take data: active products + current system stock + gallon balance.
final stockTakeDataProvider = FutureProvider.autoDispose((ref) async {
  final db = ref.watch(dbProvider);
  final products = await (db.select(db.products)
        ..where((p) => p.active.equals(true))
        ..orderBy([
          (p) => OrderingTerm.asc(p.category),
          (p) => OrderingTerm.asc(p.name),
        ]))
      .get();
  final stocks = <int, int>{};
  for (final p in products) {
    stocks[p.id] = await db.stockOf(p.id);
  }
  final gallon = await db.gallonBalance();
  return (products: products, stocks: stocks, gallon: gallon);
});

class StockTakeScreen extends ConsumerWidget {
  const StockTakeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(stockTakeDataProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Opname / Penyesuaian Stok')),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (d) => _StockTakeForm(
            products: d.products, stocks: d.stocks, gallon: d.gallon),
      ),
    );
  }
}

class _StockTakeForm extends ConsumerStatefulWidget {
  final List<Product> products;
  final Map<int, int> stocks;
  final GallonBalance gallon;
  const _StockTakeForm(
      {required this.products, required this.stocks, required this.gallon});

  @override
  ConsumerState<_StockTakeForm> createState() => _StockTakeFormState();
}

class _StockTakeFormState extends ConsumerState<_StockTakeForm> {
  late final Map<int, TextEditingController> _stock;
  late final TextEditingController _full, _empty, _depositOut;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _stock = {
      for (final p in widget.products)
        p.id: TextEditingController(text: '${widget.stocks[p.id] ?? 0}'),
    };
    _full = TextEditingController(text: '${widget.gallon.full}');
    _empty = TextEditingController(text: '${widget.gallon.empty}');
    _depositOut = TextEditingController(text: '${widget.gallon.depositOut}');
  }

  @override
  void dispose() {
    for (final c in _stock.values) {
      c.dispose();
    }
    _full.dispose();
    _empty.dispose();
    _depositOut.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final svc = ref.read(stockTakeServiceProvider);
      for (final p in widget.products) {
        final v = int.tryParse(_stock[p.id]!.text);
        if (v != null) await svc.adjustStock(p.id, v);
      }
      await svc.adjustGallon(
        full: int.tryParse(_full.text) ?? widget.gallon.full,
        empty: int.tryParse(_empty.text) ?? widget.gallon.empty,
        depositOut: int.tryParse(_depositOut.text) ?? widget.gallon.depositOut,
      );
      ref.invalidate(stockTakeDataProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opname tersimpan (selisih dicatat)')));
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _GallonCard(full: _full, empty: _empty, depositOut: _depositOut),
              const SizedBox(height: 8),
              Text('Stok produk (isi hitungan fisik)',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              for (final p in widget.products)
                _StockRow(
                  name: p.name,
                  current: widget.stocks[p.id] ?? 0,
                  controller: _stock[p.id]!,
                ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: const Text('SIMPAN OPNAME', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StockRow extends StatelessWidget {
  final String name;
  final int current;
  final TextEditingController controller;
  const _StockRow(
      {required this.name, required this.current, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name),
                Text('sistem: $current',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'fisik'),
            ),
          ),
        ],
      ),
    );
  }
}

class _GallonCard extends StatelessWidget {
  final TextEditingController full, empty, depositOut;
  const _GallonCard(
      {required this.full, required this.empty, required this.depositOut});

  @override
  Widget build(BuildContext context) {
    Widget field(String label, TextEditingController c) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextField(
              controller: c,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              decoration: InputDecoration(labelText: label),
            ),
          ),
        );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Wadah galon (hitungan fisik)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(children: [
              field('isi', full),
              field('kosong', empty),
              field('beredar', depositOut),
            ]),
          ],
        ),
      ),
    );
  }
}
