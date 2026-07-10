import '../../../core/storage/local_data_safety.dart';
import '../../cycle/domain/cycle_stage.dart';

class CycleStageLogEntry {
  final DateTime timestamp;
  final CycleStage stage;
  final int intensity;
  final String note;

  const CycleStageLogEntry({
    required this.timestamp,
    required this.stage,
    required this.intensity,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'stage': stage.name,
      'intensity': intensity,
      'note': note,
    };
  }

  factory CycleStageLogEntry.fromMap(Map<String, dynamic> map) {
    return CycleStageLogEntry(
      timestamp: LocalDataSafety.dateTime(
        map['timestamp'],
        DateTime.now(),
      ),
      stage: LocalDataSafety.enumByName(
        CycleStage.values,
        map['stage'] as String?,
        CycleStage.triggers,
      ),
      intensity: LocalDataSafety.intValue(map['intensity'], 5),
      note: (map['note'] as String?) ?? '',
    );
  }
}
