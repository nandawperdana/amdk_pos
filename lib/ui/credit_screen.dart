import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/services/credit_service.dart';
import '../main.dart';
import 'pos_screen.dart' show rupiah;

final _receivablesProvider = FutureProvider.autoDispose(
    (ref) => ref.watch(creditServiceProvider).customersWithReceivable());
final _payablesProvider = FutureProvider.autoDispose(
    (ref) => ref.watch(creditServiceProvider).suppliersWithDebt());

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
    final amount = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
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
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () =>
                Navigator.pop(ctx, double.tryParse(controller.text)),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (amount == null || amount <= 0) return;

    final credit = ref.read(creditServiceProvider);
    if (isReceivable) {
      await credit.recordReceivablePayment(customerId: p.id, amount: amount);
    } else {
      await credit.recordDebtPayment(supplierId: p.id, amount: amount);
    }
    ref.invalidate(provider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${p.name}: bayar ${rupiah.format(amount)} tercatat')));
    }
  }
}
