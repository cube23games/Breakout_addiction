class RiskWindow {
  final String id;
  final String label;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final bool isEnabled;

  const RiskWindow({
    required this.id,
    required this.label,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.isEnabled,
  });

  RiskWindow copyWith({
    String? id,
    String? label,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    bool? isEnabled,
  }) {
    return RiskWindow(
      id: id ?? this.id,
      label: label ?? this.label,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
      'isEnabled': isEnabled,
    };
  }

  factory RiskWindow.fromMap(Map<String, dynamic> map) {
    return RiskWindow(
      id: (map['id'] as String?) ?? '',
      label: (map['label'] as String?) ?? 'Risk Window',
      startHour:
          (map['startHour'] as num?)?.toInt() ?? 22,
      startMinute:
          (map['startMinute'] as num?)?.toInt() ?? 0,
      endHour:
          (map['endHour'] as num?)?.toInt() ?? 23,
      endMinute:
          (map['endMinute'] as num?)?.toInt() ?? 0,
      isEnabled: (map['isEnabled'] as bool?) ?? true,
    );
  }

  int get _startMinutes => (startHour * 60) + startMinute;
  int get _endMinutes => (endHour * 60) + endMinute;

  bool get crossesMidnight => _endMinutes < _startMinutes;
  bool get hasSameStartAndEnd =>
      _endMinutes == _startMinutes;

  String formattedRange({
    required bool use24HourFormat,
  }) {
    final start = _formatTime(
      startHour,
      startMinute,
      use24HourFormat,
    );
    final end = _formatTime(
      endHour,
      endMinute,
      use24HourFormat,
    );
    return '$start - $end';
  }

  String get timeRange {
    return formattedRange(use24HourFormat: true);
  }

  static String _formatTime(
    int hour,
    int minute,
    bool use24HourFormat,
  ) {
    final minuteLabel =
        minute.toString().padLeft(2, '0');

    if (use24HourFormat) {
      return '${hour.toString().padLeft(2, '0')}:$minuteLabel';
    }

    final period = hour >= 12 ? 'PM' : 'AM';
    final hourOfPeriod = hour % 12 == 0 ? 12 : hour % 12;
    return '$hourOfPeriod:$minuteLabel $period';
  }
}
