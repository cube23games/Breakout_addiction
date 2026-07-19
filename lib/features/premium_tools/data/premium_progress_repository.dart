import 'package:shared_preferences/shared_preferences.dart';

class PremiumProgressRepository {
  static const String _prefix = 'premium_progress_v1_';
  static const String _lastDayPrefix = 'premium_progress_last_day_v1_';

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

  Future<int> contiguousCompletedCount(
    String itemId, {
    required int maxCount,
  }) async {
    final values = await completedSteps(itemId);
    var count = 0;
    while (count < maxCount && values.contains(count)) {
      count += 1;
    }

    final expected = <int>{
      for (var index = 0; index < count; index++) index,
    };
    if (values.length != expected.length || !values.containsAll(expected)) {
      await setSequentialCount(
        itemId: itemId,
        completedCount: count,
        maxCount: maxCount,
      );
    }
    return count;
  }

  Future<void> setSequentialCount({
    required String itemId,
    required int completedCount,
    required int maxCount,
  }) async {
    final safeCount = completedCount.clamp(0, maxCount);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      '$_prefix$itemId',
      <String>[
        for (var index = 0; index < safeCount; index++) index.toString(),
      ],
    );
  }

  Future<bool> completedToday(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_lastDayPrefix$itemId') ==
        _dayStamp(DateTime.now());
  }

  Future<bool> completeNextDay({
    required String itemId,
    required int maxCount,
  }) async {
    if (await completedToday(itemId)) {
      return false;
    }

    final count = await contiguousCompletedCount(
      itemId,
      maxCount: maxCount,
    );
    if (count >= maxCount) {
      return false;
    }

    await setSequentialCount(
      itemId: itemId,
      completedCount: count + 1,
      maxCount: maxCount,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_lastDayPrefix$itemId',
      _dayStamp(DateTime.now()),
    );
    return true;
  }

  Future<void> reset(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$itemId');
    await prefs.remove('$_lastDayPrefix$itemId');
  }

  String _dayStamp(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
