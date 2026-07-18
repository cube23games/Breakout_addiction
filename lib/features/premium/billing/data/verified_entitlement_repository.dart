import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/verified_entitlement.dart';

class VerifiedEntitlementRepository {
  static const String _storageKey = 'verified_subscription_entitlement_v1';

  final FlutterSecureStorage _storage;

  VerifiedEntitlementRepository({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  Future<VerifiedEntitlement?> read() async {
    final raw = await _storage.read(key: _storageKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return VerifiedEntitlement.fromMap(decoded);
      }
      if (decoded is Map) {
        return VerifiedEntitlement.fromMap(
          Map<String, dynamic>.from(decoded),
        );
      }
    } catch (_) {
      await clear();
    }

    return null;
  }

  Future<void> save(VerifiedEntitlement entitlement) {
    return _storage.write(
      key: _storageKey,
      value: jsonEncode(entitlement.toMap()),
    );
  }

  Future<void> clear() {
    return _storage.delete(key: _storageKey);
  }
}
