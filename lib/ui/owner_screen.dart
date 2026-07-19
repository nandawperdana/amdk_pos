import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'app_drawer.dart';
import 'pos_screen.dart' show rupiah;

/// Today's summary. Phase 2: read from the cloud (Supabase) — for now still
/// from the local DB, enough to verify the flow on a single phone.
final ownerSummaryProvider = FutureProvider.autoDispose((ref) async {
  final db = ref.watch(dbProvider);
  final reports = ref.watch(reportsServiceProvider);
  final summary = await reports.dailySummary(DateTime.now());
  final gallon = await db.gallonBalance();
  final cash = await db.cashBalance();
  return (summary: summary, gallon: gallon, cash: cash);
});

class OwnerScreen extends ConsumerWidget {
  const OwnerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(ownerSummaryProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner — Hari Ini'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
            onPressed: () => ref.invalidate(ownerSummaryProvider),
          ),
          if (ref.watch(syncServiceProvider).enabled) const SyncButton(),
        ],
      ),
      drawer: const AppDrawer(),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (d) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _tile('Omzet', rupiah.format(d.summary.revenue)),
            _tile('Laba kotor', rupiah.format(d.summary.grossProfit)),
            _tile('Kas masuk', rupiah.format(d.summary.cashIn)),
            _tile('Kas keluar', rupiah.format(d.summary.cashOut)),
            _tile('Saldo kas', rupiah.format(d.cash)),
            const Divider(),
            _tile('Galon isi', '${d.gallon.full}'),
            _tile('Galon kosong', '${d.gallon.empty}'),
          ],
        ),
      ),
    );
  }

  Widget _tile(String label, String value) => Card(
        child: ListTile(
          title: Text(label),
          trailing: Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ),
      );
}

/// Cloud push-sync button. Shown only when Supabase credentials exist.
/// Available on both roles (the cashier device holds the source-of-truth data).
class SyncButton extends ConsumerStatefulWidget {
  const SyncButton({super.key});

  @override
  ConsumerState<SyncButton> createState() => _SyncButtonState();
}

class _SyncButtonState extends ConsumerState<SyncButton> {
  bool _busy = false;

  Future<void> _sync() async {
    setState(() => _busy = true);
    try {
      final n = await ref.read(syncServiceProvider).pushPending();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sync: $n baris terkirim ke cloud')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sync gagal: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Sync ke cloud',
      icon: _busy
          ? const SizedBox(
              width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.cloud_upload_outlined),
      onPressed: _busy ? null : _sync,
    );
  }
}
