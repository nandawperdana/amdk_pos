import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers.dart';
import 'ui/owner_pin_gate_screen.dart';
import 'ui/owner_screen.dart';
import 'ui/pos_screen.dart';
import 'ui/role_picker_screen.dart';

// Re-export so existing `import '../main.dart'` sites keep seeing providers.
export 'providers.dart';

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
    final ownerUnlocked = ref.watch(ownerUnlockedProvider);
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
        AppRole.owner =>
          ownerUnlocked ? const OwnerScreen() : const OwnerPinGateScreen(),
      },
    );
  }
}
