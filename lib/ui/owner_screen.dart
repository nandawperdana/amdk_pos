import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'app_drawer.dart';
import 'pos_screen.dart' show rupiah;

/// Today's summary — reads the LOCAL db, which on the owner's own separate
/// phone is a pulled-down mirror of the cashier's data (see [OwnerScreen]),
/// so this works offline once a pull has happened at least once.
final ownerSummaryProvider = FutureProvider.autoDispose((ref) async {
  final db = ref.watch(dbProvider);
  final reports = ref.watch(reportsServiceProvider);
  final summary = await reports.dailySummary(DateTime.now());
  final gallon = await db.gallonBalance();
  final cash = await db.cashBalance();
  return (summary: summary, gallon: gallon, cash: cash);
});

/// The owner's device never writes transactional data itself (no POS/
/// kulakan there) — it only PULLS from Supabase into its own local mirror,
/// then reads reports off that local copy exactly like the cashier does.
/// Offline-capable: once pulled at least once, reports work with no network.
class OwnerScreen extends ConsumerStatefulWidget {
  const OwnerScreen({super.key});

  @override
  ConsumerState<OwnerScreen> createState() => _OwnerScreenState();
}

class _OwnerScreenState extends ConsumerState<OwnerScreen> {
  bool _pulling = false;

  @override
  void initState() {
    super.initState();
    // Once per app open, pull if a day has passed since the last pull (same
    // cadence/bookkeeping as the cashier's auto-push — separate devices,
    // separate SharedPreferences, no collision).
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoPull());
  }

  Future<void> _maybeAutoPull() async {
    final sync = ref.read(syncServiceProvider);
    if (!sync.enabled || !sync.dueForAutoSync) return;
    await _pull(silent: true);
  }

  Future<void> _pull({bool silent = false}) async {
    final sync = ref.read(syncServiceProvider);
    if (!sync.enabled) {
      ref.invalidate(ownerSummaryProvider);
      return;
    }
    setState(() => _pulling = true);
    try {
      final n = await sync.pullUpdates();
      ref.invalidate(ownerSummaryProvider);
      if (mounted && (!silent || n > 0)) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tarik data: $n baris diperbarui')));
      }
    } catch (e) {
      if (mounted && !silent) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal tarik data: $e')));
      }
    } finally {
      if (mounted) setState(() => _pulling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(ownerSummaryProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner — Hari Ini'),
        actions: [
          IconButton(
            tooltip: 'Tarik data terbaru dari cloud',
            icon: _pulling
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh),
            onPressed: _pulling ? null : () => _pull(),
          ),
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

/// Cloud push-sync button — cashier only (the device that holds the
/// source-of-truth data and is the only one that should ever push).
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
