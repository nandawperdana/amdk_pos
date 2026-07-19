import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local PIN gate for the Owner role — a lightweight deterrent so staff don't
/// casually switch into Owner and see money/reports. NOT a security boundary
/// against a technical attacker with device access (no encryption at rest,
/// no rate limiting).
/// ponytail: no forgot-PIN reset flow — owner clears app data / reinstalls if
/// forgotten. Fine for a single-store, single-owner app; revisit if that
/// stops being true.
class PinService {
  final SharedPreferences prefs;
  PinService(this.prefs);

  static const _key = 'owner_pin_hash';

  bool get isSet => prefs.getString(_key) != null;

  String _hash(String pin) => sha256.convert(utf8.encode(pin)).toString();

  Future<void> setPin(String pin) => prefs.setString(_key, _hash(pin));

  bool verify(String pin) => prefs.getString(_key) == _hash(pin);
}
