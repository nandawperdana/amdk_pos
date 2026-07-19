import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/database/database.dart';
import '../domain/services/gallon_service.dart';
import '../domain/services/sales_service.dart';
import '../main.dart';
import 'app_drawer.dart';
import 'owner_screen.dart' show SyncButton;
import 'party_picker.dart';
import 'qty_picker.dart';

final rupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

/// Active products, live from the DB.
final activeProductsProvider = StreamProvider<List<Product>>((ref) {
  final db = ref.watch(dbProvider);
  return (db.select(db.products)
        ..where((p) => p.active.equals(true))
        ..orderBy([(p) => OrderingTerm.asc(p.category), (p) => OrderingTerm.asc(p.name)]))
      .watch();
});

/// Payment options: stored value + Indonesian display label.
const _paymentOptions = [
  (value: 'cash', label: 'Tunai'),
  (value: 'qris', label: 'QRIS'),
  (value: 'transfer', label: 'Transfer'),
];

class CartLine {
  final Product product;
  int qty;
  final GallonSaleMode gallonMode; // none for non-gallon

  CartLine(this.product, {this.qty = 1, this.gallonMode = GallonSaleMode.none});

  /// Per-unit price for this line. A newCustomer gallon is ONE price
  /// (water + container, no deposit) — everything else is just sellPrice.
  double get unitPrice => gallonMode == GallonSaleMode.newCustomer
      ? product.sellPrice + product.depositPrice
      : product.sellPrice;

  double get subtotal => unitPrice * qty;
}

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final List<CartLine> _cart = [];
  bool _saving = false;

  double get _total => _cart.fold(0, (s, l) => s + l.subtotal);

  // ---------------------------------------------------------------------
  // Add to cart
  // ---------------------------------------------------------------------

  void _addProduct(Product p) async {
    if (p.isGallon) {
      final line = await _askGallonMode(p);
      if (line == null) return;
      setState(() => _cart.add(line));
      return;
    }

    // Sold per dus/pack (bottol/gelas) → ask quantity + unit instead of the
    // fast +1 tap, so one sale can add a whole dus/lusin in one go.
    if (p.packUnit != null) {
      final qty = await pickQuantity(context,
          productName: p.name, packUnit: p.packUnit, packSize: p.packSize);
      if (qty == null || !mounted) return;
      _mergeIntoCart(p, qty);
      return;
    }

    // Fast path: no pack, tap = +1. Same product → bump qty, don't create a
    // new line.
    _mergeIntoCart(p, 1);
  }

  void _mergeIntoCart(Product p, int qty) {
    final existing = _cart.where(
        (l) => l.product.id == p.id && l.gallonMode == GallonSaleMode.none);
    setState(() {
      if (existing.isNotEmpty) {
        existing.first.qty += qty;
      } else {
        _cart.add(CartLine(p, qty: qty));
      }
    });
  }

  Future<void> _editQty(CartLine l, int i) async {
    final qty = await pickQuantity(context,
        productName: l.product.name,
        packUnit: l.product.packUnit,
        packSize: l.product.packSize,
        initialQty: l.qty);
    if (qty == null || !mounted) return;
    setState(() => l.qty = qty);
  }

  /// A gallon must pick a mode: exchange (isi ulang, bawa kosong) or new
  /// (galon + wadah, satu harga, tanpa deposit).
  Future<CartLine?> _askGallonMode(Product p) {
    return showModalBottomSheet<CartLine>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(p.name, style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  icon: const Icon(Icons.swap_horiz),
                  label: Text(
                      'ISI ULANG — bawa galon kosong (${rupiah.format(p.sellPrice)})'),
                  onPressed: () => Navigator.pop(
                      ctx, CartLine(p, gallonMode: GallonSaleMode.exchange)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: Text(
                      'GALON BARU — ${rupiah.format(p.sellPrice + p.depositPrice)} (galon + wadah)'),
                  onPressed: () => Navigator.pop(
                      ctx, CartLine(p, gallonMode: GallonSaleMode.newCustomer)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Checkout
  // ---------------------------------------------------------------------

  Future<void> _checkout() async {
    final method = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Total ${rupiah.format(_total)}',
                  style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: 16),
              for (final m in _paymentOptions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    height: 56,
                    child: FilledButton.tonal(
                      onPressed: () => Navigator.pop(ctx, m.value),
                      child: Text(m.label),
                    ),
                  ),
                ),
              // Credit (bon): whole sale becomes a customer's tab.
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Piutang (bon)'),
                  onPressed: () => Navigator.pop(ctx, 'credit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (method == null || !mounted) return;

    // Credit needs a customer (their tab).
    Party? customer;
    if (method == 'credit') {
      customer = await pickParty(context, ref, isCustomer: true);
      if (customer == null || !mounted) return; // cancelled → abort save
    }

    setState(() => _saving = true);
    try {
      final sales = ref.read(salesServiceProvider);
      // 'cash' → cash account; 'qris' → qris account; 'transfer' → bank account.
      final account = switch (method) {
        'qris' => 'qris',
        'transfer' => 'bank',
        _ => 'cash',
      };

      // Water + gallon container written ATOMICALLY in one transaction.
      await sales.recordSale(
        lines: [
          for (final l in _cart)
            SaleLine(
              productId: l.product.id,
              qtyBase: l.qty,
              price: l.unitPrice,
              gallonMode: l.gallonMode,
            ),
        ],
        paymentMethod: method == 'credit' ? 'cash' : method,
        paymentStatus: method == 'credit' ? 'receivable' : 'paid',
        customerId: customer?.id,
        account: account,
      );

      if (mounted) {
        final msg = method == 'credit'
            ? 'Piutang ${customer!.name} — ${rupiah.format(_total)}'
            : 'Tersimpan — ${rupiah.format(_total)}';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
        setState(_cart.clear);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(activeProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir'),
        actions: [
          // Cashier device holds the source-of-truth data → sync lives here too.
          if (ref.watch(syncServiceProvider).enabled) const SyncButton(),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: products.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Gagal memuat produk: $e')),
              data: (list) => GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  // Phone-first: big buttons (~min 150dp), auto extra columns
                  // on wide screens/tablets.
                  maxCrossAxisExtent: 180,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.4,
                ),
                itemCount: list.length,
                itemBuilder: (_, i) => _ProductButton(
                    product: list[i], onTap: () => _addProduct(list[i])),
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
              onPressed: _cart.isEmpty || _saving ? null : _checkout,
              child: Text(
                _cart.isEmpty
                    ? 'Keranjang kosong'
                    : 'BAYAR  ${rupiah.format(_total)}',
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
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _cart.length,
        itemBuilder: (_, i) {
          final l = _cart[i];
          final label = switch (l.gallonMode) {
            GallonSaleMode.exchange => ' (tukar)',
            GallonSaleMode.newCustomer => ' (galon baru)',
            GallonSaleMode.none => '',
          };
          return ListTile(
            dense: true,
            title: Text('${l.product.name}$label'),
            subtitle: Text(rupiah.format(l.subtotal)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => setState(() {
                    l.qty > 1 ? l.qty-- : _cart.removeAt(i);
                  }),
                ),
                InkWell(
                  onTap: () => _editQty(l, i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text('${l.qty}',
                        style: const TextStyle(fontSize: 18)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => l.qty++),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProductButton extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  const _ProductButton({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: product.isGallon ? scheme.primaryContainer : scheme.secondaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(product.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(rupiah.format(product.sellPrice),
                  style: TextStyle(color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
