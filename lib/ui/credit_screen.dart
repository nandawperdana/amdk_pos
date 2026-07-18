import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/services/credit_service.dart';
import '../main.dart';
import 'pos_screen.dart' show rupiah;

final _receivablesProvider = FutureProvider.autoDispose(
    (ref) => ref.watch(creditServiceProvider).customersWithReceivable());
final _payablesProvider = FutureProvider.autoDispose(
    (ref) => ref.watch(creditServiceProvider).suppliersWithDebt());

/// Settlement account options: stored value + Indonesian display label.
const _accountOptions = [
  (value: 'cash', label: 'Tunai'),
  (value: 'qris', label: 'QRIS'),
  (value: 'transfer', label: 'Transfer'),
];

class CreditScreen extends ConsumerWidget {
  const CreditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Piutang & Utang'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Piutang (masuk)'),
            Tab(text: 'Utang (keluar)'),
          ]),
        ),
        body: TabBarView(children: [
          _PartyList(
            provider: _receivablesProvider,
            emptyText: 'Tak ada piutang. Semua lunas.',
            isReceivable: true,
          ),
          _PartyList(
            provider: _payablesProvider,
            emptyText: 'Tak ada utang. Semua lunas.',
            isReceivable: false,
          ),
        ]),
      ),
    );
  }
}

class _PartyList extends ConsumerWidget {
  final AutoDisposeFutureProvider<List<PartyBalance>> provider;
  final String emptyText;
  final bool isReceivable;
  const _PartyList(
      {required this.provider,
      required this.emptyText,
      required this.isReceivable});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(provider);
    return data.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Gagal memuat: $e')),
      data: (list) {
        if (list.isEmpty) {
          return Center(
              child: Text(emptyText,
                  style: TextStyle(color: Theme.of(context).colorScheme.outline)));
        }
        final total = list.fold<double>(0, (s, p) => s + p.balance);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total ${isReceivable ? 'piutang' : 'utang'}',
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(rupiah.format(total),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final p = list[i];
                  return ListTile(
                    title: Text(p.name),
                    trailing: Text(rupiah.format(p.balance),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    onTap: () => _pay(context, ref, p),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pay(
      BuildContext context, WidgetRef ref, PartyBalance p) async {
    final controller =
        TextEditingController(text: p.balance.toStringAsFixed(0));
    String account = 'cash';
    final result = await showDialog<({double amount, String account})>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(isReceivable
              ? 'Terima bayaran — ${p.name}'
              : 'Bayar utang — ${p.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sisa ${rupiah.format(p.balance)}'),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    prefixText: 'Rp ', labelText: 'Jumlah bayar'),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: [
                  for (final o in _accountOptions)
                    ButtonSegment(value: o.value, label: Text(o.label)),
                ],
                selected: {account},
                onSelectionChanged: (s) => setLocal(() => account = s.first),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal')),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(controller.text);
                if (amount == null || amount <= 0) return;
                Navigator.pop(ctx, (amount: amount, account: account));
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;

    final credit = ref.read(creditServiceProvider);
    if (isReceivable) {
      await credit.recordReceivablePayment(
          customerId: p.id, amount: result.amount, account: result.account);
    } else {
      await credit.recordDebtPayment(
          supplierId: p.id, amount: result.amount, account: result.account);
    }
    ref.invalidate(provider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '${p.name}: bayar ${rupiah.format(result.amount)} tercatat')));
    }
  }
}
