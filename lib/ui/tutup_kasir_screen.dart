import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import 'pos_screen.dart' show rupiah;

const _account = 'kas';

final _openingBalanceProvider = FutureProvider.autoDispose(
    (ref) => ref.watch(cashierServiceProvider).openingBalance(account: _account));

final _systemBalanceProvider = FutureProvider.autoDispose(
    (ref) => ref.watch(dbProvider).cashBalance(account: _account));

class TutupKasirScreen extends ConsumerStatefulWidget {
  const TutupKasirScreen({super.key});

  @override
  ConsumerState<TutupKasirScreen> createState() => _TutupKasirScreenState();
}

class _TutupKasirScreenState extends ConsumerState<TutupKasirScreen> {
  final _controller = TextEditingController();
  bool _saving = false;

  double get _physicalCount => double.tryParse(_controller.text) ?? 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirm(double systemBalance) async {
    final diff = _physicalCount - systemBalance;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tutup kasir?'),
        content: Text(
          diff == 0
              ? 'Hitungan fisik pas dengan sistem. Lanjut tutup kasir?'
              : 'Ada selisih ${rupiah.format(diff.abs())} '
                  '(${diff > 0 ? 'lebih' : 'kurang'}). Selisih akan dicatat '
                  'sebagai penyesuaian kas. Lanjut?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Tutup Kasir')),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(cashierServiceProvider)
          .recordClosing(physicalCount: _physicalCount, account: _account);
      ref.invalidate(_openingBalanceProvider);
      ref.invalidate(_systemBalanceProvider);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Kasir ditutup.')));
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final opening = ref.watch(_openingBalanceProvider);
    final system = ref.watch(_systemBalanceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tutup Kasir')),
      body: opening.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (openingBalance) => system.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Gagal memuat: $e')),
          data: (systemBalance) {
            final diff = _physicalCount - systemBalance;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _row('Kas awal (sejak tutup terakhir)',
                    rupiah.format(openingBalance)),
                _row('Kas sistem sekarang', rupiah.format(systemBalance)),
                const SizedBox(height: 24),
                Text('Hitungan fisik di laci',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 28),
                  decoration: const InputDecoration(
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                _row(
                  'Selisih',
                  '${diff > 0 ? '+' : ''}${rupiah.format(diff)}',
                  color: diff == 0
                      ? null
                      : (diff > 0 ? Colors.green : Colors.red),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: _controller.text.isEmpty || _saving
                        ? null
                        : () => _confirm(systemBalance),
                    child: const Text('TUTUP KASIR',
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _row(String label, String value, {Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      );
}
