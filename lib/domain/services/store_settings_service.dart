import 'package:shared_preferences/shared_preferences.dart';

/// Local store-name setting — per-device, like [PinService], NOT synced to
/// Supabase. Shown in the drawer header, role-picker splash, and daily
/// report header.
class StoreSettingsService {
  final SharedPreferences prefs;
  StoreSettingsService(this.prefs);

  static const _key = 'store_name';
  static const _defaultName = 'Tirta POS';

  String get name => prefs.getString(_key) ?? _defaultName;

  Future<void> setName(String name) => prefs.setString(_key, name);
}
