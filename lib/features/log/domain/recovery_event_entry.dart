enum RecoveryEventType {
  urge,
  relapse,
  victory,
}

extension RecoveryEventTypeX on RecoveryEventType {
  String get label {
    switch (this) {
      case RecoveryEventType.urge:
        return 'Urge';
      case RecoveryEventType.relapse:
        return 'Relapse';
      case RecoveryEventType.victory:
        return 'Victory';
    }
  }
}

class RecoveryEventEntry {
  final DateTime timestamp;
  final RecoveryEventType type;
  final int intensity;
  final String reason;
  final String trigger;
  final String context;
  final String note;

  const RecoveryEventEntry({
    required this.timestamp,
    required this.type,
    required this.intensity,
    this.reason = '',
    this.trigger = '',
    required this.context,
    required this.note,
  });

  String get timestampKey => timestamp.toIso8601String();

  String get displayReason {
    final cleaned = reason.trim();
    return cleaned.isEmpty ? 'No reason added.' : cleaned;
  }

  String get displayTrigger {
    final cleaned = trigger.trim().isNotEmpty ? trigger.trim() : context.trim();
    return cleaned.isEmpty ? 'No trigger added.' : cleaned;
  }

  RecoveryEventEntry copyWith({
    DateTime? timestamp,
    RecoveryEventType? type,
    int? intensity,
    String? reason,
    String? trigger,
    String? context,
    String? note,
  }) {
    return RecoveryEventEntry(
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      intensity: intensity ?? this.intensity,
      reason: reason ?? this.reason,
      trigger: trigger ?? this.trigger,
      context: context ?? this.context,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'intensity': intensity,
      'reason': reason,
      'trigger': trigger,
      'context': context,
      'note': note,
    };
  }

  factory RecoveryEventEntry.fromMap(Map<String, dynamic> map) {
    final typeName = map['type'] as String?;
    final parsedType = RecoveryEventType.values.firstWhere(
      (item) => item.name == typeName,
      orElse: () => RecoveryEventType.urge,
    );

    return RecoveryEventEntry(
      timestamp: DateTime.tryParse((map['timestamp'] as String?) ?? '') ??
          DateTime.now(),
      type: parsedType,
      intensity: (map['intensity'] as num?)?.toInt() ?? 5,
      reason: (map['reason'] as String?) ?? '',
      trigger: (map['trigger'] as String?) ?? (map['context'] as String?) ?? '',
      context: (map['context'] as String?) ?? '',
      note: (map['note'] as String?) ?? '',
    );
  }
}
