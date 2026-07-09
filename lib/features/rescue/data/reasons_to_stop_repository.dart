import 'package:shared_preferences/shared_preferences.dart';

class ReasonsToStopRepository {
  static const String _storageKey = 'reasons_to_stop';
  static const String otherReason = 'Other';

  static const List<String> _defaultReasons = <String>[
    'Self-respect',
    'Mental clarity',
    'Relationships',
    'Peace',
    otherReason,
  ];

  Future<List<String>> getReasons() async {
    final prefs = await SharedPreferences.getInstance();
    final reasons = prefs.getStringList(_storageKey);
    if (reasons == null || reasons.isEmpty) {
      return _defaultReasons;
    }
    return _withOther(reasons);
  }

  Future<void> saveReasons(List<String> reasons) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _withOther(reasons));
  }

  List<String> _withOther(List<String> reasons) {
    final cleaned = <String>[];

    for (final item in reasons) {
      final value = item.trim();
      if (value.isEmpty) continue;
      if (cleaned.any((existing) => existing.toLowerCase() == value.toLowerCase())) {
        continue;
      }
      cleaned.add(value);
    }

    if (!cleaned.any((item) => item.toLowerCase() == otherReason.toLowerCase())) {
      cleaned.add(otherReason);
    }

    return cleaned;
  }
}
