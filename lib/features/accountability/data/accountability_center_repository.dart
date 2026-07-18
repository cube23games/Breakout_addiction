import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/local_data_safety.dart';
import '../domain/accountability_check_in_plan.dart';

class AccountabilityCenterRepository {
  static const String _storageKey = 'premium_accountability_check_in_v1';

  Future<AccountabilityCheckInPlan> getPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final map = LocalDataSafety.decodeMap(prefs.getString(_storageKey));
    if (map.isEmpty) {
      return AccountabilityCheckInPlan.defaults();
    }
    try {
      return AccountabilityCheckInPlan.fromMap(map);
    } catch (_) {
      return AccountabilityCheckInPlan.defaults();
    }
  }

  Future<void> savePlan(AccountabilityCheckInPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(plan.toMap()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
