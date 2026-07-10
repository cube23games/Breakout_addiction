import '../../../core/storage/local_data_safety.dart';

class MoodEntry {
  final DateTime timestamp;
  final String moodLabel;
  final int stress;
  final int loneliness;
  final int boredom;
  final int energy;
  final String note;

  const MoodEntry({
    required this.timestamp,
    required this.moodLabel,
    required this.stress,
    required this.loneliness,
    required this.boredom,
    required this.energy,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'moodLabel': moodLabel,
      'stress': stress,
      'loneliness': loneliness,
      'boredom': boredom,
      'energy': energy,
      'note': note,
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      timestamp: LocalDataSafety.dateTime(
        map['timestamp'],
        DateTime.now(),
      ),
      moodLabel: (map['moodLabel'] as String?) ?? 'Neutral',
      stress: LocalDataSafety.intValue(map['stress'], 5),
      loneliness: LocalDataSafety.intValue(map['loneliness'], 5),
      boredom: LocalDataSafety.intValue(map['boredom'], 5),
      energy: LocalDataSafety.intValue(map['energy'], 5),
      note: (map['note'] as String?) ?? '',
    );
  }
}
