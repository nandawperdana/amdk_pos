import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/database.dart';
import '../main.dart';

/// Data opname: produk aktif + stok sistem sekarang + saldo galon.
final opnameDataProvider = FutureProvider.autoDispose((ref) async {
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
  final galon = await db.galonBalance();
  return (products: products, stocks: stocks, galon: galon);
});

class OpnameScreen extends ConsumerWidget {
  const OpnameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(opnameDataProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Opname / Penyesuaian Stok')),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (d) => _OpnameForm(
            products: d.products, stocks: d.stocks, galon: d.galon),
      ),
    );
  }
}

class _OpnameForm extends ConsumerStatefulWidget {
  final List<Product> products;
  final Map<int, int> stocks;
  final GalonBalance galon;
  const _OpnameForm(
      {required this.products, required this.stocks, required this.galon});

  @override
  ConsumerState<_OpnameForm> createState() => _OpnameFormState();
}

class _OpnameFormState extends ConsumerState<_OpnameForm> {
  late final Map<int, TextEditingController> _stok;
  late final TextEditingController _isi, _kosong, _beredar;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _stok = {
      for (final p in widget.products)
        p.id: TextEditingController(text: '${widget.stocks[p.id] ?? 0}'),
    };
    _isi = TextEditingController(text: '${widget.galon.full}');
    _kosong = TextEditingController(text: '${widget.galon.empty}');
    _beredar = TextEditingController(text: '${widget.galon.depositOut}');
  }

  @override
  void dispose() {
    for (final c in _stok.values) {
      c.dispose();
    }
    _isi.dispose();
    _kosong.dispose();
    _beredar.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final svc = ref.read(opnameServiceProvider);
      for (final p in widget.products) {
        final v = int.tryParse(_stok[p.id]!.text);
        if (v != null) await svc.adjustStock(p.id, v);
      }
      await svc.adjustGalon(
        isi: int.tryParse(_isi.text) ?? widget.galon.full,
        kosong: int.tryParse(_kosong.text) ?? widget.galon.empty,
        beredar: int.tryParse(_beredar.text) ?? widget.galon.depositOut,
      );
      ref.invalidate(opnameDataProvider);
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
              _GalonCard(isi: _isi, kosong: _kosong, beredar: _beredar),
              const SizedBox(height: 8),
              Text('Stok produk (isi hitungan fisik)',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              for (final p in widget.products)
                _StockRow(
                  name: p.name,
                  current: widget.stocks[p.id] ?? 0,
                  controller: _stok[p.id]!,
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

class _GalonCard extends StatelessWidget {
  final TextEditingController isi, kosong, beredar;
  const _GalonCard(
      {required this.isi, required this.kosong, required this.beredar});

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
              field('isi', isi),
              field('kosong', kosong),
              field('beredar', beredar),
            ]),
          ],
        ),
      ),
    );
  }
}
