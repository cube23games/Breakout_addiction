import 'package:shared_preferences/shared_preferences.dart';

class PremiumProgressRepository {
  static const String _prefix = 'premium_progress_v1_';

  Future<Set<int>> completedSteps(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('$_prefix$itemId') ?? <String>[];
    return raw
        .map(int.tryParse)
        .whereType<int>()
        .where((value) => value >= 0)
        .toSet();
  }

  Future<void> setStep({
    required String itemId,
    required int index,
    required bool completed,
  }) async {
    final values = await completedSteps(itemId);
    if (completed) {
      values.add(index);
    } else {
      values.remove(index);
    }
    final sorted = values.toList()..sort();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      '$_prefix$itemId',
      sorted.map((value) => value.toString()).toList(),
    );
  }

  Future<void> reset(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$itemId');
  }
}
