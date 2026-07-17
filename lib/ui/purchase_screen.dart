import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/database.dart';
import '../domain/services/purchase_service.dart';
import '../main.dart';
import 'pos_screen.dart' show activeProductsProvider, rupiah;

class PurchaseCartLine {
  final Product product;
  int qty;
  double price; // buy price per base unit
  bool swapEmpty; // gallon only: restock filled with an empty swap

  PurchaseCartLine(this.product)
      : qty = 1,
        price = product.buyPrice,
        swapEmpty = product.isGallon;

  double get subtotal => qty * price;
}

class PurchaseScreen extends ConsumerStatefulWidget {
  const PurchaseScreen({super.key});

  @override
  ConsumerState<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends ConsumerState<PurchaseScreen> {
  final List<PurchaseCartLine> _cart = [];
  String _paymentStatus = 'paid'; // 'paid' | 'debt'
  bool _saving = false;

  double get _total => _cart.fold(0, (s, l) => s + l.subtotal);

  void _addProduct(Product p) {
    final existing = _cart.where((l) => l.product.id == p.id);
    setState(() {
      if (existing.isNotEmpty) {
        existing.first.qty++;
      } else {
        _cart.add(PurchaseCartLine(p));
      }
    });
  }

  Future<void> _editPrice(PurchaseCartLine l) async {
    final controller = TextEditingController(text: l.price.toStringAsFixed(0));
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Harga beli — ${l.product.name}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(prefixText: 'Rp '),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          FilledButton(
            onPressed: () =>
                Navigator.pop(ctx, double.tryParse(controller.text)),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (result != null) setState(() => l.price = result);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final purchases = ref.read(purchaseServiceProvider);
      final gallon = ref.read(gallonServiceProvider);

      // Water (all lines) via PurchaseService…
      await purchases.recordPurchase(
        lines: [
          for (final l in _cart)
            PurchaseLine(
                productId: l.product.id, qtyBase: l.qty, price: l.price),
        ],
        paymentStatus: _paymentStatus,
      );

      // …filled gallon containers (if swapping empties) via GallonService.
      for (final l in _cart) {
        if (l.product.isGallon && l.swapEmpty) {
          await gallon.recordRestockExchange(qty: l.qty);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Kulakan tersimpan — ${rupiah.format(_total)}')));
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(activeProductsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Kulakan / Pembelian')),
      body: Column(
        children: [
          Expanded(
            child: products.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Gagal memuat produk: $e')),
              data: (list) => GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.4,
                ),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final p = list[i];
                  return Material(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _addProduct(p),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(p.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('beli ${rupiah.format(p.buyPrice)}',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_cart.isNotEmpty) _buildCart(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            height: 64,
            child: FilledButton(
              onPressed: _cart.isEmpty || _saving ? null : _save,
              child: Text(
                _cart.isEmpty
                    ? 'Belum ada barang'
                    : 'SIMPAN KULAKAN  ${rupiah.format(_total)}',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCart() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 320),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Paid / debt.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                const Text('Pembayaran:'),
                const SizedBox(width: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'paid', label: Text('Lunas')),
                    ButtonSegment(value: 'debt', label: Text('Utang')),
                  ],
                  selected: {_paymentStatus},
                  onSelectionChanged: (s) =>
                      setState(() => _paymentStatus = s.first),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _cart.length,
              itemBuilder: (_, i) {
                final l = _cart[i];
                return ListTile(
                  dense: true,
                  title: Text(l.product.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () => _editPrice(l),
                            child: Text('@ ${rupiah.format(l.price)} ✎',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary)),
                          ),
                          const SizedBox(width: 8),
                          Text('= ${rupiah.format(l.subtotal)}'),
                        ],
                      ),
                      if (l.product.isGallon)
                        _SwapChip(
                          value: l.swapEmpty,
                          onChanged: (v) => setState(() => l.swapEmpty = v),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => setState(() {
                          l.qty > 1 ? l.qty-- : _cart.removeAt(i);
                        }),
                      ),
                      Text('${l.qty}', style: const TextStyle(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setState(() => l.qty++),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SwapChip extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwapChip({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Chip(
        label: Text(value ? 'tukar kosong' : 'tanpa tukar',
            style: const TextStyle(fontSize: 11)),
        visualDensity: VisualDensity.compact,
        backgroundColor: value
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
      ),
    );
  }
}
