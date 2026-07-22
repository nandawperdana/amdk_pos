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

/// Live stock per product = SUM(StockMovements.qtyBase), grouped. Products
/// with no movement row are simply absent (treated as stock 0 = habis).
final stockMapProvider = StreamProvider<Map<int, int>>((ref) {
  final db = ref.watch(dbProvider);
  final sum = db.stockMovements.qtyBase.sum();
  final q = db.selectOnly(db.stockMovements)
    ..addColumns([db.stockMovements.productId, sum])
    ..groupBy([db.stockMovements.productId]);
  return q.watch().map((rows) => {
        for (final r in rows) r.read(db.stockMovements.productId)!: r.read(sum) ?? 0,
      });
});

/// Payment options: stored value + Indonesian display label.
const _paymentOptions = [
  (value: 'cash', label: 'Tunai'),
  (value: 'qris', label: 'QRIS'),
  (value: 'transfer', label: 'Transfer'),
];

class CartLine {
  final Product product;
  int qty; // base units (pcs)
  final GallonSaleMode gallonMode; // none for non-gallon
  bool asPack; // sold by the pack (dus) → use packSellPrice

  CartLine(this.product,
      {this.qty = 1,
      this.gallonMode = GallonSaleMode.none,
      this.asPack = false});

  int get _packs => product.packSize > 0 ? qty ~/ product.packSize : 0;

  /// Exact line total. newCustomer gallon = one price (water + container). A
  /// pack line with a pack price set charges whole-dus price; otherwise falls
  /// back to per-pcs × qty (also covers packSellPrice unset).
  double get subtotal {
    if (gallonMode == GallonSaleMode.newCustomer) {
      return (product.sellPrice + product.depositPrice) * qty;
    }
    if (asPack && product.packSellPrice > 0) {
      return _packs * product.packSellPrice;
    }
    return product.sellPrice * qty;
  }

  /// Effective per-base price stored on the SaleItem row (informational; the
  /// exact money lives in [subtotal]).
  double get unitPrice => qty == 0 ? 0 : subtotal / qty;

  /// Pass the exact pack total to the service only when it differs from
  /// qtyBase × unitPrice would reconstruct — i.e. for pack lines.
  double? get exactSubtotal =>
      (asPack && product.packSellPrice > 0) ? subtotal : null;
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

  @override
  void initState() {
    super.initState();
    // Cashier device holds the source-of-truth data — check once per app
    // open whether a day has passed since the last push, and if so sync
    // quietly in the background (no daemon/WorkManager needed).
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoSync());
  }

  Future<void> _maybeAutoSync() async {
    final sync = ref.read(syncServiceProvider);
    if (!sync.enabled || !sync.dueForAutoSync) return;
    try {
      final up = await sync.pushPending(master: false); // push ledger
      await sync.pullUpdates(ledger: false); // pull master/prices
      if (mounted && up > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Auto-sync: $up baris terkirim ke cloud')));
      }
    } catch (_) {
      // Silent — a background sync hiccup shouldn't block the cashier; the
      // manual Sync button in the AppBar still works if noticed missing.
    }
  }

  // ---------------------------------------------------------------------
  // Add to cart
  // ---------------------------------------------------------------------

  // Stock on hand minus whatever is already sitting in the cart for this
  // product (across all lines/gallon modes) — the true room left to sell.
  int _stockOf(Product p) =>
      (ref.read(stockMapProvider).valueOrNull ?? const {})[p.id] ?? 0;

  int _remaining(Product p) =>
      _stockOf(p) -
      _cart
          .where((l) => l.product.id == p.id)
          .fold(0, (s, l) => s + l.qty);

  /// Same as [_remaining], but pretending [line] isn't in the cart yet — for
  /// editing an existing line's qty (it shouldn't count against itself).
  int _remainingExcluding(CartLine line) =>
      _stockOf(line.product) -
      _cart
          .where((l) => l.product.id == line.product.id && l != line)
          .fold(0, (s, l) => s + l.qty);

  void _addProduct(Product p) async {
    final remaining = _remaining(p);
    if (remaining <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Stok ${p.name} habis')));
      return;
    }

    if (p.isGallon) {
      final line = await _askGallonMode(p);
      if (line == null) return;
      setState(() => _cart.add(line));
      return;
    }

    // Sold per dus/pack (bottol/gelas) → ask quantity + unit instead of the
    // fast +1 tap, so one sale can add a whole dus/lusin in one go.
    if (p.packUnit != null) {
      final r = await pickQuantity(context,
          productName: p.name,
          packUnit: p.packUnit,
          packSize: p.packSize,
          maxQty: remaining);
      if (r == null || !mounted) return;
      _mergeIntoCart(p, r.qtyBase, r.asPack);
      return;
    }

    // Fast path: no pack, tap = +1. Same product → bump qty, don't create a
    // new line.
    _mergeIntoCart(p, 1, false);
  }

  // Merge into a line with the SAME product, gallon mode, AND pack flag —
  // pcs and dus lines price differently, so they stay separate lines.
  void _mergeIntoCart(Product p, int qty, bool asPack) {
    final existing = _cart.where((l) =>
        l.product.id == p.id &&
        l.gallonMode == GallonSaleMode.none &&
        l.asPack == asPack);
    setState(() {
      if (existing.isNotEmpty) {
        existing.first.qty += qty;
      } else {
        _cart.add(CartLine(p, qty: qty, asPack: asPack));
      }
    });
  }

  Future<void> _editQty(CartLine l, int i) async {
    final r = await pickQuantity(context,
        productName: l.product.name,
        packUnit: l.product.packUnit,
        packSize: l.product.packSize,
        initialQty: l.qty,
        maxQty: _remainingExcluding(l));
    if (r == null || !mounted) return;
    setState(() {
      l.qty = r.qtyBase;
      l.asPack = r.asPack;
    });
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
              subtotal: l.exactSubtotal,
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
    final stockAsync = ref.watch(stockMapProvider);
    final stockMap = stockAsync.valueOrNull ?? const {};
    final stockLoaded = stockAsync.hasValue;

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
                  childAspectRatio: 1.25,
                ),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final p = list[i];
                  final stock = stockMap[p.id] ?? 0;
                  // Out of stock → not sellable. Don't block during the
                  // initial async load (avoids a flash of "Habis").
                  final soldOut = stockLoaded && stock <= 0;
                  return _ProductButton(
                    product: p,
                    stock: stock,
                    soldOut: soldOut,
                    onTap: soldOut ? null : () => _addProduct(p),
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
          final packNote = l.asPack && l.product.packSize > 1
              ? '${l.qty ~/ l.product.packSize} ${l.product.packUnit} · '
              : '';
          return ListTile(
            dense: true,
            title: Text('${l.product.name}$label'),
            subtitle: Text('$packNote${rupiah.format(l.subtotal)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => setState(() {
                    // Dus lines step a whole pack so qty stays a multiple.
                    final step = l.asPack ? l.product.packSize : 1;
                    l.qty > step ? l.qty -= step : _cart.removeAt(i);
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
                  onPressed: () {
                    final step = l.asPack ? l.product.packSize : 1;
                    if (_remaining(l.product) < step) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('Stok ${l.product.name} tidak cukup')));
                      return;
                    }
                    setState(() => l.qty += step);
                  },
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
  final int stock;
  final bool soldOut;
  final VoidCallback? onTap; // null = disabled (out of stock)
  const _ProductButton({
    required this.product,
    required this.stock,
    required this.soldOut,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base =
        product.isGallon ? scheme.primaryContainer : scheme.secondaryContainer;
    return Opacity(
      opacity: soldOut ? 0.45 : 1,
      child: Material(
        color: base,
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
                const SizedBox(height: 2),
                Text(
                  soldOut ? 'Habis' : 'stok $stock',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: soldOut ? scheme.error : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
