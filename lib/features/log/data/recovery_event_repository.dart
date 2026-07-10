import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/local_data_safety.dart';
import '../domain/recovery_event_entry.dart';

class RecoveryEventRepository {
  static const String _storageKey = 'recovery_event_logs';
  static const List<String> storedFields = <String>['timestamp', 'type', 'intensity', 'reason', 'trigger', 'context', 'note'];

  Future<List<RecoveryEventEntry>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    final entries = LocalDataSafety.decodeMappedList<RecoveryEventEntry>(
      raw,
      (map) => RecoveryEventEntry.fromMap(map),
    );

    return entries..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> saveEntry(RecoveryEventEntry entry) async {
    final existing = await getEntries();
    final updated = <RecoveryEventEntry>[entry, ...existing];
    await _saveEntries(updated);
  }

  Future<void> updateEntry({
    required DateTime originalTimestamp,
    required RecoveryEventEntry entry,
  }) async {
    final existing = await getEntries();
    final originalKey = originalTimestamp.toIso8601String();

    var replaced = false;
    final updated = existing.map((item) {
      if (item.timestampKey == originalKey) {
        replaced = true;
        return entry;
      }
      return item;
    }).toList();

    if (!replaced) {
      updated.insert(0, entry);
    }

    await _saveEntries(updated);
  }

  Future<void> deleteEntry(RecoveryEventEntry entry) async {
    await deleteEntryByTimestamp(entry.timestamp);
  }

  Future<void> deleteEntryByTimestamp(DateTime timestamp) async {
    final existing = await getEntries();
    final key = timestamp.toIso8601String();
    final updated = existing.where((item) => item.timestampKey != key).toList();
    await _saveEntries(updated);
  }

  Future<void> _saveEntries(List<RecoveryEventEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final sorted = entries.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final encoded = jsonEncode(sorted.map((item) => item.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
