import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/local_data_safety.dart';
import '../domain/recovery_plan.dart';

class RecoveryPlanRepository {
  static const String _storageKey = 'support_recovery_plan';

  Future<RecoveryPlan> getPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final decoded = LocalDataSafety.decodeMap(prefs.getString(_storageKey));

    if (decoded.isEmpty) {
      return RecoveryPlan.defaults();
    }

    try {
      return RecoveryPlan.fromMap(decoded);
    } catch (_) {
      return RecoveryPlan.defaults();
    }
  }

  Future<void> savePlan(RecoveryPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(plan.toMap()));
  }
}
