import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/accountability_settings.dart';

class AccountabilitySettingsRepository {
  static const String _settingsKey = 'accountability_settings';
  static const String _partnerPasscodeKey = 'accountability_partner_passcode';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<AccountabilitySettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);

    if (raw == null || raw.isEmpty) {
      return AccountabilitySettings.defaults;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return AccountabilitySettings.fromMap(decoded);
      }
      if (decoded is Map) {
        return AccountabilitySettings.fromMap(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      return AccountabilitySettings.defaults;
    }

    return AccountabilitySettings.defaults;
  }

  Future<void> saveSettings(AccountabilitySettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toMap()));
  }

  Future<bool> hasPartnerPasscode() async {
    final saved = await _secureStorage.read(key: _partnerPasscodeKey);
    return saved != null && saved.isNotEmpty;
  }

  Future<void> savePartnerPasscode(String passcode) async {
    final cleaned = passcode.trim();

    if (cleaned.isEmpty) {
      await clearPartnerPasscode();
      return;
    }

    await _secureStorage.write(
      key: _partnerPasscodeKey,
      value: cleaned,
    );
  }

  Future<bool> verifyPartnerPasscode(String passcode) async {
    final saved = await _secureStorage.read(key: _partnerPasscodeKey);
    return saved != null && saved == passcode.trim();
  }

  Future<void> clearPartnerPasscode() async {
    await _secureStorage.delete(key: _partnerPasscodeKey);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_settingsKey);
    await clearPartnerPasscode();
  }
}
