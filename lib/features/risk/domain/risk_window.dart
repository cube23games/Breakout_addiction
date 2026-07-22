import '../../../core/storage/local_data_safety.dart';

class RiskWindow {
  const RiskWindow({
    required this.id,
    required this.label,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.isEnabled,
    this.earlyWarningSigns = const <String>[],
    this.triggers = const <String>[],
    this.preparationAction = '',
    this.supportAction = '',
  });
  final String id;
  final String label;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final bool isEnabled;
  final List<String> earlyWarningSigns;
  final List<String> triggers;
  final String preparationAction;
  final String supportAction;

  RiskWindow copyWith({
    String? id, String? label, int? startHour, int? startMinute,
    int? endHour, int? endMinute, bool? isEnabled,
    List<String>? earlyWarningSigns, List<String>? triggers,
    String? preparationAction, String? supportAction,
  }) => RiskWindow(
    id: id ?? this.id,
    label: label ?? this.label,
    startHour: startHour ?? this.startHour,
    startMinute: startMinute ?? this.startMinute,
    endHour: endHour ?? this.endHour,
    endMinute: endMinute ?? this.endMinute,
    isEnabled: isEnabled ?? this.isEnabled,
    earlyWarningSigns: earlyWarningSigns ?? this.earlyWarningSigns,
    triggers: triggers ?? this.triggers,
    preparationAction: preparationAction ?? this.preparationAction,
    supportAction: supportAction ?? this.supportAction,
  );

  Map<String,dynamic> toMap() => <String,dynamic>{
    'id': id, 'label': label, 'startHour': startHour, 'startMinute': startMinute,
    'endHour': endHour, 'endMinute': endMinute, 'isEnabled': isEnabled,
    'earlyWarningSigns': earlyWarningSigns, 'triggers': triggers,
    'preparationAction': preparationAction, 'supportAction': supportAction,
  };

  factory RiskWindow.fromMap(Map<String,dynamic> map) => RiskWindow(
    id: (map['id'] as String?) ?? '',
    label: (map['label'] as String?) ?? 'Risk Window',
    startHour: (map['startHour'] as num?)?.toInt() ?? 22,
    startMinute: (map['startMinute'] as num?)?.toInt() ?? 0,
    endHour: (map['endHour'] as num?)?.toInt() ?? 23,
    endMinute: (map['endMinute'] as num?)?.toInt() ?? 0,
    isEnabled: (map['isEnabled'] as bool?) ?? true,
    earlyWarningSigns: LocalDataSafety.stringList(map['earlyWarningSigns']),
    triggers: LocalDataSafety.stringList(map['triggers']),
    preparationAction: (map['preparationAction'] as String?) ?? '',
    supportAction: (map['supportAction'] as String?) ?? '',
  );

  int get _startMinutes => startHour * 60 + startMinute;
  int get _endMinutes => endHour * 60 + endMinute;
  bool get crossesMidnight => _endMinutes < _startMinutes;
  bool get hasSameStartAndEnd => _endMinutes == _startMinutes;
  String formattedRange({required bool use24HourFormat}) => '${_formatTime(startHour,startMinute,use24HourFormat)} - ${_formatTime(endHour,endMinute,use24HourFormat)}';
  String get timeRange => formattedRange(use24HourFormat: true);
  static String _formatTime(int hour,int minute,bool use24HourFormat) {
    final m=minute.toString().padLeft(2,'0');
    if (use24HourFormat) return '${hour.toString().padLeft(2,'0')}:$m';
    final period=hour>=12?'PM':'AM';
    final h=hour%12==0?12:hour%12;
    return '$h:$m $period';
  }
}
