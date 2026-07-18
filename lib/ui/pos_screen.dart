import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/database/database.dart';
import '../domain/services/gallon_service.dart';
import '../domain/services/sales_service.dart';
import '../main.dart';
import 'cashier_closing_screen.dart';
import 'credit_screen.dart';
import 'master_product_screen.dart';
import 'owner_screen.dart' show SyncButton;
import 'party_picker.dart';
import 'purchase_screen.dart';
import 'stock_take_screen.dart';

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
  final double deposit; // per gallon, only for newCustomer mode

  CartLine(this.product,
      {this.qty = 1,
      this.gallonMode = GallonSaleMode.none,
      this.deposit = 0});

  double get subtotal => product.sellPrice * qty;
  double get depositTotal =>
      gallonMode == GallonSaleMode.newCustomer ? deposit * qty : 0;
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
  double get _depositTotal => _cart.fold(0, (s, l) => s + l.depositTotal);

  // ---------------------------------------------------------------------
  // Add to cart
  // ---------------------------------------------------------------------

  void _addProduct(Product p) async {
    if (p.isGallon) {
      final line = await _askGallonMode(p);
      if (line == null) return;
      setState(() => _cart.add(line));
    } else {
      // Same product → bump qty, don't create a new line.
      final existing = _cart.where(
          (l) => l.product.id == p.id && l.gallonMode == GallonSaleMode.none);
      setState(() {
        if (existing.isNotEmpty) {
          existing.first.qty++;
        } else {
          _cart.add(CartLine(p));
        }
      });
    }
  }

  /// A gallon must pick a mode: exchange (brings an empty) or new (+ deposit).
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
                  label: const Text('TUKAR — pelanggan bawa galon kosong'),
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
                      'BARU — + deposit ${rupiah.format(p.depositPrice)}'),
                  onPressed: () => Navigator.pop(
                      ctx,
                      CartLine(p,
                          gallonMode: GallonSaleMode.newCustomer,
                          deposit: p.depositPrice)),
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
              Text('Total ${rupiah.format(_total + _depositTotal)}',
                  style: Theme.of(ctx).textTheme.headlineSmall),
              if (_depositTotal > 0)
                Text(
                    '(${rupiah.format(_total)} penjualan + '
                    '${rupiah.format(_depositTotal)} deposit galon)',
                    style: Theme.of(ctx).textTheme.bodyMedium),
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
              // Credit (bon): whole sale becomes a customer's tab. Gallon
              // deposit is still collected in cash.
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

    // Credit needs a customer.
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
      // customerId flows through so the deposit liability is attributable.
      await sales.recordSale(
        lines: [
          for (final l in _cart)
            SaleLine(
              productId: l.product.id,
              qtyBase: l.qty,
              price: l.product.sellPrice,
              gallonMode: l.gallonMode,
              deposit: l.deposit,
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
                '${_depositTotal > 0 ? ' (+ deposit ${rupiah.format(_depositTotal)} tunai)' : ''}'
            : 'Tersimpan — ${rupiah.format(_total + _depositTotal)}';
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
  // Deposit return (customer brings a container back, gets the deposit)
  // ---------------------------------------------------------------------

  Future<void> _returnDeposit() async {
    final gallons = (ref.read(activeProductsProvider).valueOrNull ?? [])
        .where((p) => p.isGallon)
        .toList();
    if (gallons.isEmpty) return;

    final customer = await pickParty(context, ref, isCustomer: true);
    if (customer == null || !mounted) return;

    var product = gallons.first;
    final qtyCtrl = TextEditingController(text: '1');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text('Tarik deposit — ${customer.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Product>(
                initialValue: product,
                decoration: const InputDecoration(labelText: 'Galon'),
                items: [
                  for (final g in gallons)
                    DropdownMenuItem(
                        value: g,
                        child: Text(
                            '${g.name} (${rupiah.format(g.depositPrice)})')),
                ],
                onChanged: (v) => setLocal(() => product = v!),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Jumlah galon'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Refund')),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;

    final qty = int.tryParse(qtyCtrl.text) ?? 0;
    if (qty <= 0) return;
    try {
      await ref.read(gallonServiceProvider).recordDepositReturn(
            qty: qty,
            depositPerGallon: product.depositPrice,
            customerId: customer.id,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Deposit ${customer.name}: refund ${rupiah.format(product.depositPrice * qty)}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
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
          IconButton(
            icon: const Icon(Icons.add_shopping_cart_outlined),
            tooltip: 'Kulakan',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PurchaseScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.point_of_sale_outlined),
            tooltip: 'Tutup Kasir',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CashierClosingScreen())),
          ),
          PopupMenuButton<VoidCallback>(
            onSelected: (fn) => fn(),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MasterProductScreen())),
                child: const ListTile(
                    leading: Icon(Icons.inventory_2_outlined),
                    title: Text('Master Produk')),
              ),
              PopupMenuItem(
                value: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const StockTakeScreen())),
                child: const ListTile(
                    leading: Icon(Icons.fact_check_outlined),
                    title: Text('Opname Stok')),
              ),
              PopupMenuItem(
                value: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CreditScreen())),
                child: const ListTile(
                    leading: Icon(Icons.account_balance_wallet_outlined),
                    title: Text('Piutang & Utang')),
              ),
              PopupMenuItem(
                value: _returnDeposit,
                child: const ListTile(
                    leading: Icon(Icons.assignment_return_outlined),
                    title: Text('Tarik deposit galon')),
              ),
              PopupMenuItem(
                value: () => ref.read(roleProvider.notifier).select(null),
                child: const ListTile(
                    leading: Icon(Icons.switch_account),
                    title: Text('Ganti Peran')),
              ),
            ],
          ),
        ],
      ),
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
                    : 'BAYAR  ${rupiah.format(_total + _depositTotal)}',
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
            GallonSaleMode.newCustomer => ' (baru+deposit)',
            GallonSaleMode.none => '',
          };
          return ListTile(
            dense: true,
            title: Text('${l.product.name}$label'),
            subtitle: Text(rupiah.format(l.subtotal + l.depositTotal)),
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
