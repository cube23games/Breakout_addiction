import 'dart:convert';

class LocalDataSafety {
  const LocalDataSafety._();

  static List<dynamic> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) {
      return <dynamic>[];
    }

    try {
      final decoded = jsonDecode(raw);
      return decoded is List ? decoded : <dynamic>[];
    } catch (_) {
      return <dynamic>[];
    }
  }

  static Map<String, dynamic> decodeMap(String? raw) {
    if (raw == null || raw.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return <String, dynamic>{};
    }

    return <String, dynamic>{};
  }

  static List<T> decodeMappedList<T>(
    String? raw,
    T? Function(Map<String, dynamic> map) mapper,
  ) {
    final decoded = decodeList(raw);
    final items = <T>[];

    for (final item in decoded) {
      if (item is! Map) {
        continue;
      }

      try {
        final mapped = mapper(Map<String, dynamic>.from(item));
        if (mapped != null) {
          items.add(mapped);
        }
      } catch (_) {
        continue;
      }
    }

    return items;
  }

  static T enumByName<T extends Enum>(
    Iterable<T> values,
    String? name,
    T fallback,
  ) {
    if (name == null || name.isEmpty) {
      return fallback;
    }

    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }

    return fallback;
  }

  static DateTime dateTime(Object? raw, DateTime fallback) {
    if (raw is DateTime) {
      return raw;
    }

    if (raw is String) {
      return DateTime.tryParse(raw) ?? fallback;
    }

    return fallback;
  }

  static int intValue(Object? raw, int fallback) {
    if (raw is num) {
      return raw.toInt();
    }

    if (raw is String) {
      return int.tryParse(raw) ?? fallback;
    }

    return fallback;
  }

  static List<String> stringList(Object? raw) {
    if (raw is! List) {
      return <String>[];
    }

    return raw.map((item) => item.toString()).toList();
  }
}
