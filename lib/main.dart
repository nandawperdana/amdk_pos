import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/database/database.dart';
import 'domain/services/cashier_service.dart';
import 'domain/services/galon_service.dart';
import 'domain/services/opname_service.dart';
import 'domain/services/product_service.dart';
import 'domain/services/purchase_service.dart';
import 'domain/services/reports_service.dart';
import 'domain/services/sales_service.dart';
import 'ui/laporan_harian_screen.dart';
import 'ui/pos_screen.dart';

// --- Providers (Riverpod) ---------------------------------------------------

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final salesServiceProvider =
    Provider((ref) => SalesService(ref.watch(dbProvider)));
final galonServiceProvider =
    Provider((ref) => GalonService(ref.watch(dbProvider)));
final reportsServiceProvider =
    Provider((ref) => ReportsService(ref.watch(dbProvider)));
final cashierServiceProvider =
    Provider((ref) => CashierService(ref.watch(dbProvider)));
final purchaseServiceProvider =
    Provider((ref) => PurchaseService(ref.watch(dbProvider)));
final productServiceProvider =
    Provider((ref) => ProductService(ref.watch(dbProvider)));
final opnameServiceProvider =
    Provider((ref) => OpnameService(ref.watch(dbProvider)));

/// Semua produk (aktif + nonaktif), live — untuk layar master produk.
/// Aktif dulu, lalu per kategori & nama.
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

// --- Peran ------------------------------------------------------------------

/// Satu app dua peran: kasir (POS penuh, tulis lokal) dan owner (baca laporan).
/// Dipilih saat buka app, lalu dipersist (shared_preferences).
enum AppRole { kasir, owner }

/// Diisi di main() lewat override — SharedPreferences dibaca sinkron.
final prefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override di main()');
});

const _roleKey = 'role';

class RoleNotifier extends Notifier<AppRole?> {
  @override
  AppRole? build() {
    return switch (ref.watch(prefsProvider).getString(_roleKey)) {
      'kasir' => AppRole.kasir,
      'owner' => AppRole.owner,
      _ => null,
    };
  }

  /// Pilih peran (persist) atau kembali ke pemilih peran (null → hapus).
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID'); // format Rp & tanggal Indonesia
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [prefsProvider.overrideWithValue(prefs)],
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
        AppRole.kasir => const PosScreen(),
        AppRole.owner => const OwnerScreen(),
      },
    );
  }
}

// --- Pilih peran --------------------------------------------------------------

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
                      ref.read(roleProvider.notifier).select(AppRole.kasir),
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

/// Ringkasan hari ini. Fase 2: baca dari cloud (Supabase) — sekarang masih
/// dari DB lokal, cukup untuk verifikasi alur di satu HP.
final ownerSummaryProvider = FutureProvider.autoDispose((ref) async {
  final db = ref.watch(dbProvider);
  final reports = ref.watch(reportsServiceProvider);
  final summary = await reports.dailySummary(DateTime.now());
  final galon = await db.galonBalance();
  final kas = await db.cashBalance();
  return (summary: summary, galon: galon, kas: kas);
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
                MaterialPageRoute(builder: (_) => const LaporanHarianScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(ownerSummaryProvider),
          ),
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
            _tile('Omzet', rupiah.format(d.summary.omzet)),
            _tile('Laba kotor', rupiah.format(d.summary.labaKotor)),
            _tile('Kas masuk', rupiah.format(d.summary.kasMasuk)),
            _tile('Kas keluar', rupiah.format(d.summary.kasKeluar)),
            _tile('Saldo kas', rupiah.format(d.kas)),
            const Divider(),
            _tile('Galon isi', '${d.galon.full}'),
            _tile('Galon kosong', '${d.galon.empty}'),
            _tile('Galon beredar (kewajiban)', '${d.galon.depositOut}'),
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
