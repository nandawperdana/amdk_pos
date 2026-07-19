import 'dart:math';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/database/database.dart';
import 'data/sync/sync_service.dart';
import 'domain/services/cashier_service.dart';
import 'domain/services/credit_service.dart';
import 'domain/services/gallon_service.dart';
import 'domain/services/party_service.dart';
import 'domain/services/pin_service.dart';
import 'domain/services/product_service.dart';
import 'domain/services/purchase_service.dart';
import 'domain/services/reports_service.dart';
import 'domain/services/sales_service.dart';
import 'domain/services/stock_take_service.dart';

// --- Composition root: DI, services, role, sync ------------------------------

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final gallonServiceProvider =
    Provider((ref) => GallonService(ref.watch(dbProvider)));
// Sale/purchase orchestrate the gallon container in the SAME transaction.
final salesServiceProvider = Provider(
    (ref) => SalesService(ref.watch(dbProvider), ref.watch(gallonServiceProvider)));
final purchaseServiceProvider = Provider((ref) =>
    PurchaseService(ref.watch(dbProvider), ref.watch(gallonServiceProvider)));
final reportsServiceProvider =
    Provider((ref) => ReportsService(ref.watch(dbProvider)));
final cashierServiceProvider =
    Provider((ref) => CashierService(ref.watch(dbProvider)));
final productServiceProvider =
    Provider((ref) => ProductService(ref.watch(dbProvider)));
final stockTakeServiceProvider =
    Provider((ref) => StockTakeService(ref.watch(dbProvider)));
final creditServiceProvider =
    Provider((ref) => CreditService(ref.watch(dbProvider)));
final partyServiceProvider =
    Provider((ref) => PartyService(ref.watch(dbProvider)));
final pinServiceProvider =
    Provider((ref) => PinService(ref.watch(prefsProvider)));

/// Live customer & supplier lists (for pickers), by name.
final customersProvider = StreamProvider<List<Customer>>((ref) {
  final db = ref.watch(dbProvider);
  return (db.select(db.customers)..orderBy([(c) => OrderingTerm.asc(c.name)]))
      .watch();
});
final suppliersProvider = StreamProvider<List<Supplier>>((ref) {
  final db = ref.watch(dbProvider);
  return (db.select(db.suppliers)..orderBy([(s) => OrderingTerm.asc(s.name)]))
      .watch();
});

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

/// Supabase client — overridden in main() when credentials exist, else null
/// (sync disabled, app still runs offline).
final syncClientProvider = Provider<SupabaseClient?>((ref) => null);

final syncServiceProvider = Provider((ref) => SyncService(
      ref.watch(dbProvider),
      deviceId: _deviceId(ref.watch(prefsProvider)),
      client: ref.watch(syncClientProvider),
      prefs: ref.watch(prefsProvider),
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

/// Whether the Owner PIN has been verified THIS app session (in-memory only
/// — resets on cold start and whenever the role is switched away, so Owner
/// always needs the PIN again on the next entry).
final ownerUnlockedProvider = StateProvider<bool>((ref) => false);
