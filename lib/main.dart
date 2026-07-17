import 'dart:math';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/database/database.dart';
import 'data/sync/sync_service.dart';
import 'domain/services/cashier_service.dart';
import 'domain/services/gallon_service.dart';
import 'domain/services/product_service.dart';
import 'domain/services/purchase_service.dart';
import 'domain/services/reports_service.dart';
import 'domain/services/sales_service.dart';
import 'domain/services/stock_take_service.dart';
import 'ui/daily_report_screen.dart';
import 'ui/pos_screen.dart';

// --- Providers (Riverpod) ---------------------------------------------------

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final salesServiceProvider =
    Provider((ref) => SalesService(ref.watch(dbProvider)));
final gallonServiceProvider =
    Provider((ref) => GallonService(ref.watch(dbProvider)));
final reportsServiceProvider =
    Provider((ref) => ReportsService(ref.watch(dbProvider)));
final cashierServiceProvider =
    Provider((ref) => CashierService(ref.watch(dbProvider)));
final purchaseServiceProvider =
    Provider((ref) => PurchaseService(ref.watch(dbProvider)));
final productServiceProvider =
    Provider((ref) => ProductService(ref.watch(dbProvider)));
final stockTakeServiceProvider =
    Provider((ref) => StockTakeService(ref.watch(dbProvider)));

/// Supabase client — overridden in main() when credentials exist, else null
/// (sync disabled, app still runs offline).
final syncClientProvider = Provider<SupabaseClient?>((ref) => null);

final syncServiceProvider = Provider((ref) => SyncService(
      ref.watch(dbProvider),
      deviceId: _deviceId(ref.watch(prefsProvider)),
      client: ref.watch(syncClientProvider),
    ));

/// Stable per-install device id (for the Postgres mirror PK). Created once.
String _deviceId(SharedPreferences prefs) {
  var id = prefs.getString('device_id');
  if (id == null) {
    id = 'dev-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(0x7fffffff)}';
    prefs.setString('device_id', id);
  }
  return id;
}

/// All products (active + inactive), live — for the master-product screen.
/// Active first, then by category & name.
final allProductsProvider = StreamProvider<List<Product>>((ref) {
  final db = ref.watch(dbProvider);
  return (db.select(db.products)
        ..orderBy([
          (p) => OrderingTerm.desc(p.active),
          (p) => OrderingTerm.asc(p.category),
          (p) => OrderingTerm.asc(p.name),
        ]))
      .watch();
});

// --- Role --------------------------------------------------------------------

/// One app, two roles: cashier (full POS, writes locally) and owner (reads
/// reports). Chosen on launch, then persisted (shared_preferences).
enum AppRole { cashier, owner }

/// Filled in main() via override — SharedPreferences read synchronously.
final prefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in main()');
});

const _roleKey = 'role';

class RoleNotifier extends Notifier<AppRole?> {
  @override
  AppRole? build() {
    return switch (ref.watch(prefsProvider).getString(_roleKey)) {
      'cashier' => AppRole.cashier,
      'owner' => AppRole.owner,
      _ => null,
    };
  }

  /// Pick a role (persist) or go back to the role picker (null → clear).
  void select(AppRole? role) {
    final prefs = ref.read(prefsProvider);
    if (role == null) {
      prefs.remove(_roleKey);
    } else {
      prefs.setString(_roleKey, role.name);
    }
    state = role;
  }
}

final roleProvider = NotifierProvider<RoleNotifier, AppRole?>(RoleNotifier.new);

// --- App --------------------------------------------------------------------

/// Supabase credentials via --dart-define (DO NOT commit secrets).
/// Empty → sync disabled, app runs offline as usual.
///   fvm flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID'); // Rp & Indonesian date formatting
  final prefs = await SharedPreferences.getInstance();

  SupabaseClient? syncClient;
  if (_supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(url: _supabaseUrl, publishableKey: _supabaseAnonKey);
    syncClient = Supabase.instance.client;
  }

  runApp(ProviderScope(
    overrides: [
      prefsProvider.overrideWithValue(prefs),
      syncClientProvider.overrideWithValue(syncClient),
    ],
    child: const AmdkPosApp(),
  ));
}

class AmdkPosApp extends ConsumerWidget {
  const AmdkPosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(roleProvider);
    return MaterialApp(
      title: 'AMDK POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      locale: const Locale('id', 'ID'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID'), Locale('en')],
      home: switch (role) {
        null => const RolePickerScreen(),
        AppRole.cashier => const PosScreen(),
        AppRole.owner => const OwnerScreen(),
      },
    );
  }
}

// --- Role picker --------------------------------------------------------------

class RolePickerScreen extends ConsumerWidget {
  const RolePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('AMDK POS',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 32),
              SizedBox(
                height: 72,
                child: FilledButton.icon(
                  icon: const Icon(Icons.point_of_sale),
                  label: const Text('KASIR', style: TextStyle(fontSize: 22)),
                  onPressed: () =>
                      ref.read(roleProvider.notifier).select(AppRole.cashier),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 72,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('OWNER', style: TextStyle(fontSize: 22)),
                  onPressed: () =>
                      ref.read(roleProvider.notifier).select(AppRole.owner),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Mode owner ---------------------------------------------------------------

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
        title: const Text('Owner — Laporan Hari Ini'),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_note),
            tooltip: 'Laporan Harian',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const DailyReportScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(ownerSummaryProvider),
          ),
          if (ref.watch(syncServiceProvider).enabled)
            const _SyncButton(),
          IconButton(
            icon: const Icon(Icons.switch_account),
            tooltip: 'Ganti Peran',
            onPressed: () => ref.read(roleProvider.notifier).select(null),
          ),
        ],
      ),
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
            _tile('Galon beredar (kewajiban)', '${d.gallon.depositOut}'),
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
class _SyncButton extends ConsumerStatefulWidget {
  const _SyncButton();

  @override
  ConsumerState<_SyncButton> createState() => _SyncButtonState();
}

class _SyncButtonState extends ConsumerState<_SyncButton> {
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
