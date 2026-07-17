import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/database/database.dart';
import '../domain/services/sales_service.dart';
import '../main.dart';
import 'tutup_kasir_screen.dart';

/// Nilai deposit galon default. Masih keputusan terbuka (seragam vs per merk)
/// — untuk sekarang konstanta, bisa diubah kasir per transaksi.
const double defaultGalonDeposit = 40000;

final rupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

/// Produk aktif, live dari DB.
final activeProductsProvider = StreamProvider<List<Product>>((ref) {
  final db = ref.watch(dbProvider);
  return (db.select(db.products)
        ..where((p) => p.active.equals(true))
        ..orderBy([(p) => OrderingTerm.asc(p.category), (p) => OrderingTerm.asc(p.name)]))
      .watch();
});

/// Cara penjualan galon: pelanggan tukar galon kosong, atau pelanggan baru
/// yang bayar deposit wadah.
enum GalonMode { tukar, baru }

class CartLine {
  final Product product;
  int qty;
  final GalonMode? galonMode; // null untuk non-galon
  final double deposit; // per galon, hanya untuk mode baru

  CartLine(this.product, {this.qty = 1, this.galonMode, this.deposit = 0});

  double get subtotal => product.sellPrice * qty;
  double get depositTotal => galonMode == GalonMode.baru ? deposit * qty : 0;
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
  // Tambah ke keranjang
  // ---------------------------------------------------------------------

  void _addProduct(Product p) async {
    if (p.isGalon) {
      final line = await _askGalonMode(p);
      if (line == null) return;
      setState(() => _cart.add(line));
    } else {
      // Produk sama → tambah qty, jangan bikin baris baru.
      final existing = _cart.where((l) => l.product.id == p.id && l.galonMode == null);
      setState(() {
        if (existing.isNotEmpty) {
          existing.first.qty++;
        } else {
          _cart.add(CartLine(p));
        }
      });
    }
  }

  /// Galon wajib pilih mode: tukar (bawa kosong) atau baru (+ deposit).
  Future<CartLine?> _askGalonMode(Product p) {
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
                      ctx, CartLine(p, galonMode: GalonMode.tukar)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: Text(
                      'BARU — + deposit ${rupiah.format(defaultGalonDeposit)}'),
                  onPressed: () => Navigator.pop(
                      ctx,
                      CartLine(p,
                          galonMode: GalonMode.baru,
                          deposit: defaultGalonDeposit)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Bayar
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
              for (final m in ['tunai', 'qris', 'transfer'])
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    height: 56,
                    child: FilledButton.tonal(
                      onPressed: () => Navigator.pop(ctx, m),
                      child: Text(m.toUpperCase()),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (method == null || !mounted) return;

    setState(() => _saving = true);
    try {
      final sales = ref.read(salesServiceProvider);
      final galon = ref.read(galonServiceProvider);
      // 'tunai' → akun kas; 'qris' → akun qris; 'transfer' → akun bank.
      final account = switch (method) {
        'qris' => 'qris',
        'transfer' => 'bank',
        _ => 'kas',
      };

      // Air (semua baris) lewat SalesService…
      final saleId = await sales.recordSale(
        lines: [
          for (final l in _cart)
            SaleLine(
                productId: l.product.id,
                qtyBase: l.qty,
                price: l.product.sellPrice),
        ],
        paymentMethod: method,
        account: account,
      );

      // …wadah galon lewat GalonService (dua barang, dua ledger).
      for (final l in _cart) {
        switch (l.galonMode) {
          case GalonMode.tukar:
            await galon.recordExchange(qty: l.qty, saleId: saleId);
          case GalonMode.baru:
            await galon.recordNewGalonSale(
                qty: l.qty,
                depositPerGalon: l.deposit,
                saleId: saleId,
                account: account);
          case null:
            break;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Tersimpan — ${rupiah.format(_total + _depositTotal)} ($method)')));
        setState(_cart.clear);
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
          IconButton(
            icon: const Icon(Icons.point_of_sale_outlined),
            tooltip: 'Tutup Kasir',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TutupKasirScreen())),
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
                  // Phone-first: tombol besar (~min 150dp), otomatis nambah
                  // kolom di layar lebar/tablet.
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
          final label = switch (l.galonMode) {
            GalonMode.tukar => ' (tukar)',
            GalonMode.baru => ' (baru+deposit)',
            null => '',
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
      color: product.isGalon ? scheme.primaryContainer : scheme.secondaryContainer,
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
