import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/database.dart';
import '../main.dart';
import 'pos_screen.dart' show rupiah;

/// Category value (stored) + Indonesian display label.
const _categories = [
  (value: 'gallon', label: 'Galon'),
  (value: 'bottle', label: 'Botol'),
  (value: 'cup', label: 'Gelas'),
  (value: 'other', label: 'Lainnya'),
];

String _categoryLabel(String value) =>
    _categories.firstWhere((c) => c.value == value, orElse: () => (value: value, label: value)).label;

/// Master produk dibagi per peran: kasir cuma bisa enable/disable barang
/// (nyalakan/matikan Switch), tanpa buka form tambah/edit. Owner full akses.
class MasterProductScreen extends ConsumerWidget {
  const MasterProductScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(allProductsProvider);
    final isOwner = ref.watch(roleProvider) == AppRole.owner;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Produk'),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.upload_file_outlined),
              tooltip: 'Import CSV',
              onPressed: () => _openImportDialog(context, ref),
            ),
        ],
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Produk'),
              onPressed: () => _openForm(context),
            )
          : null,
      body: products.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (list) => ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final p = list[i];
            return ListTile(
              enabled: p.active,
              leading: p.isGallon
                  ? const Icon(Icons.water_drop)
                  : const Icon(Icons.local_drink_outlined),
              title: Text(p.name,
                  style: TextStyle(
                      decoration:
                          p.active ? null : TextDecoration.lineThrough)),
              subtitle: Text(isOwner
                  ? '${_categoryLabel(p.category)} · jual ${rupiah.format(p.sellPrice)} · '
                      'beli ${rupiah.format(p.buyPrice)}'
                  : _categoryLabel(p.category)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isOwner)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _openForm(context, p),
                    ),
                  Switch(
                    value: p.active,
                    onChanged: (v) => ref
                        .read(productServiceProvider)
                        .setActive(p.id, v),
                  ),
                ],
              ),
              onTap: isOwner ? () => _openForm(context, p) : null,
            );
          },
        ),
      ),
    );
  }

  Future<void> _openImportDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final csv = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Import CSV'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            maxLines: 12,
            decoration: const InputDecoration(
              hintText: 'name,brand,category,baseUnit,packUnit,packSize,'
                  'buyPrice,sellPrice,packBuyPrice,packSellPrice,isGallon,'
                  'depositPrice,active\n...tempel CSV di sini...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (csv == null || csv.trim().isEmpty || !context.mounted) return;

    final (inserted, updated, errors) =
        await ref.read(productImportServiceProvider).importCsv(csv);
    if (!context.mounted) return;
    final parts = [
      '$inserted produk masuk',
      if (updated.isNotEmpty) '${updated.length} diperbarui',
      if (errors.isNotEmpty) '${errors.length} gagal',
    ];
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(parts.join(', '))));
    if (errors.isNotEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Baris gagal'),
          content: SingleChildScrollView(child: Text(errors.join('\n'))),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup')),
          ],
        ),
      );
    }
  }

  void _openForm(BuildContext context, [Product? product]) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => _ProductFormScreen(product: product)));
  }
}

class _ProductFormScreen extends ConsumerStatefulWidget {
  final Product? product; // null = add
  const _ProductFormScreen({this.product});

  @override
  ConsumerState<_ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<_ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _brand;
  late final TextEditingController _buy;
  late final TextEditingController _sell;
  late final TextEditingController _packUnit;
  late final TextEditingController _packSize;
  late final TextEditingController _packBuy;
  late final TextEditingController _packSell;
  late final TextEditingController _deposit;
  late String _category;

  Product? get _p => widget.product;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: _p?.name ?? '');
    _brand = TextEditingController(text: _p?.brand ?? '');
    _buy = TextEditingController(text: _p?.buyPrice.toStringAsFixed(0) ?? '');
    _sell = TextEditingController(text: _p?.sellPrice.toStringAsFixed(0) ?? '');
    _packUnit = TextEditingController(text: _p?.packUnit ?? '');
    _packSize = TextEditingController(text: '${_p?.packSize ?? 1}');
    _packBuy = TextEditingController(
        text: (_p?.packBuyPrice ?? 0) == 0
            ? ''
            : _p!.packBuyPrice.toStringAsFixed(0));
    _packSell = TextEditingController(
        text: (_p?.packSellPrice ?? 0) == 0
            ? ''
            : _p!.packSellPrice.toStringAsFixed(0));
    _deposit = TextEditingController(text: _p?.depositPrice.toStringAsFixed(0) ?? '');
    _category = _p?.category ?? 'other';
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _brand,
      _buy,
      _sell,
      _packUnit,
      _packSize,
      _packBuy,
      _packSell,
      _deposit
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final packUnit = _packUnit.text.trim();
    final values = ProductsCompanion(
      name: Value(_name.text.trim()),
      brand: Value(_brand.text.trim()),
      category: Value(_category),
      // Gallon = 'gallon' category → has a CONTAINER (GallonLedger).
      // Bound together to stay consistent.
      isGallon: Value(_category == 'gallon'),
      buyPrice: Value(double.tryParse(_buy.text) ?? 0),
      sellPrice: Value(double.tryParse(_sell.text) ?? 0),
      // Deposit only applies to gallons; 0 otherwise.
      depositPrice: Value(
          _category == 'gallon' ? (double.tryParse(_deposit.text) ?? 0) : 0),
      packUnit: Value(packUnit.isEmpty ? null : packUnit),
      packSize: Value(int.tryParse(_packSize.text) ?? 1),
      // Dus prices only meaningful with a pack unit; store 0 otherwise.
      packBuyPrice: Value(
          packUnit.isEmpty ? 0 : (double.tryParse(_packBuy.text) ?? 0)),
      packSellPrice: Value(
          packUnit.isEmpty ? 0 : (double.tryParse(_packSell.text) ?? 0)),
    );
    await ref.read(productServiceProvider).save(values, id: _p?.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_p == null ? 'Tambah Produk' : 'Edit Produk')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nama'),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _brand,
              decoration: const InputDecoration(labelText: 'Merk (opsional)'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: [
                for (final c in _categories)
                  DropdownMenuItem(value: c.value, child: Text(c.label)),
              ],
              onChanged: (v) => setState(() => _category = v!),
            ),
            if (_category == 'gallon') ...[
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                    'Produk galon: wadah isi/kosong dilacak di buku galon, '
                    'terpisah dari stok air. Harga jual di atas = harga isi '
                    'ulang (pelanggan bawa galon kosong).',
                    style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deposit,
                decoration: const InputDecoration(
                    labelText: 'Harga wadah (untuk galon baru)',
                    helperText: 'Ditambah ke harga jual saat galon baru '
                        '(wadah + isi) dijual putus, tanpa deposit',
                    prefixText: 'Rp '),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _buy,
                    decoration: const InputDecoration(
                        labelText: 'Harga beli', prefixText: 'Rp '),
                    keyboardType: TextInputType.number,
                    validator: _validNumber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _sell,
                    decoration: const InputDecoration(
                        labelText: 'Harga jual', prefixText: 'Rp '),
                    keyboardType: TextInputType.number,
                    validator: _validNumber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _packUnit,
                    decoration: const InputDecoration(
                        labelText: 'Satuan besar (mis. dus, opsional)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _packSize,
                    decoration:
                        const InputDecoration(labelText: 'Isi per satuan besar'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _packBuy,
                    decoration: const InputDecoration(
                        labelText: 'Harga beli/dus (opsional)',
                        prefixText: 'Rp '),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _packSell,
                    decoration: const InputDecoration(
                        labelText: 'Harga jual/dus (opsional)',
                        prefixText: 'Rp '),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                  'Kosongkan jika harga dus = harga satuan × isi. Diisi = harga '
                  'khusus per dus (bisa lebih murah per pcs).',
                  style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: _save,
                child: const Text('SIMPAN', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validNumber(String? v) {
    if (v == null || v.trim().isEmpty) return 'Wajib diisi';
    final n = double.tryParse(v);
    if (n == null || n < 0) return 'Angka tidak valid';
    return null;
  }
}
