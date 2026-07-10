import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/storage/local_data_safety.dart';
import '../domain/app_entry_record.dart';
import '../domain/widget_entry_action.dart';

class AppEntryRepository {
  static const String _pendingKey = 'pending_app_entry';
  static const String _lastKey = 'last_app_entry';

  AppEntryRecord _recordForAction(WidgetEntryAction action) {
    switch (action) {
      case WidgetEntryAction.openHome:
        return AppEntryRecord(
          sourceKey: 'widget_home',
          routeName: RouteNames.home,
          title: 'Widget Home Entry',
          subtitle: 'Opened Breakout from the home widget.',
          timestamp: DateTime.now(),
        );
      case WidgetEntryAction.openRescue:
        return AppEntryRecord(
          sourceKey: 'widget_rescue',
          routeName: RouteNames.rescue,
          title: 'Widget Rescue Entry',
          subtitle: 'Jumped straight into Rescue from the home widget.',
          timestamp: DateTime.now(),
        );
      case WidgetEntryAction.openMoodLog:
        return AppEntryRecord(
          sourceKey: 'widget_mood',
          routeName: RouteNames.moodLog,
          title: 'Widget Check-In Entry',
          subtitle: 'Started a quick mood check-in from the home widget.',
          timestamp: DateTime.now(),
        );
    }
  }

  Future<void> stageWidgetEntry(WidgetEntryAction action) async {
    final prefs = await SharedPreferences.getInstance();
    final record = _recordForAction(action);
    await prefs.setString(_pendingKey, jsonEncode(record.toMap()));
  }

  Future<AppEntryRecord?> consumePendingEntry() async {
    final prefs = await SharedPreferences.getInstance();
    final decoded = LocalDataSafety.decodeMap(prefs.getString(_pendingKey));

    if (decoded.isEmpty) {
      await prefs.remove(_pendingKey);
      return null;
    }

    try {
      final record = AppEntryRecord.fromMap(decoded);
      await prefs.remove(_pendingKey);
      await prefs.setString(_lastKey, jsonEncode(record.toMap()));
      return record;
    } catch (_) {
      await prefs.remove(_pendingKey);
      return null;
    }
  }

  Future<AppEntryRecord?> getLastEntry() async {
    final prefs = await SharedPreferences.getInstance();
    final decoded = LocalDataSafety.decodeMap(prefs.getString(_lastKey));

    if (decoded.isEmpty) {
      return null;
    }

    try {
      return AppEntryRecord.fromMap(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearLastEntry() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastKey);
  }
}
