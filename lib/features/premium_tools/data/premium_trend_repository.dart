import '../../log/data/cycle_stage_log_repository.dart';
import '../../log/data/mood_log_repository.dart';
import '../../log/data/recovery_event_repository.dart';
import '../../log/domain/mood_entry.dart';
import '../../log/domain/recovery_event_entry.dart';
import '../domain/premium_trend_summary.dart';

class PremiumTrendRepository {
  final MoodLogRepository _moods;
  final CycleStageLogRepository _stages;
  final RecoveryEventRepository _events;

  PremiumTrendRepository({
    MoodLogRepository? moods,
    CycleStageLogRepository? stages,
    RecoveryEventRepository? events,
  })  : _moods = moods ?? MoodLogRepository(),
        _stages = stages ?? CycleStageLogRepository(),
        _events = events ?? RecoveryEventRepository();

  bool _since(DateTime timestamp, DateTime cutoff) {
    return !timestamp.toUtc().isBefore(cutoff);
  }

  int _eventCount(
    List<RecoveryEventEntry> events,
    RecoveryEventType type,
  ) {
    return events.where((entry) => entry.type == type).length;
  }

  double _averagePressure(List<MoodEntry> moods) {
    if (moods.isEmpty) {
      return 0;
    }
    final total = moods.fold<int>(
      0,
      (sum, mood) =>
          sum + mood.stress + mood.loneliness + mood.boredom,
    );
    return total / moods.length;
  }

  String _topTrigger(List<RecoveryEventEntry> events) {
    final counts = <String, int>{};
    for (final event in events) {
      final value = event.trigger.trim().isNotEmpty
          ? event.trigger.trim()
          : event.context.trim();
      if (value.isEmpty) {
        continue;
      }
      counts.update(value, (count) => count + 1, ifAbsent: () => 1);
    }
    if (counts.isEmpty) {
      return 'Not enough trigger detail yet';
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });
    return sorted.first.key;
  }

  Future<PremiumTrendSummary> buildSummary({DateTime? now}) async {
    final current = (now ?? DateTime.now()).toUtc();
    final cutoff30 = current.subtract(const Duration(days: 30));
    final cutoff60 = current.subtract(const Duration(days: 60));
    final cutoff90 = current.subtract(const Duration(days: 90));

    final moods = await _moods.getEntries();
    final stages = await _stages.getEntries();
    final events = await _events.getEntries();

    final moods30 = moods.where((entry) => _since(entry.timestamp, cutoff30)).toList();
    final stages30 = stages.where((entry) => _since(entry.timestamp, cutoff30)).toList();
    final events30 = events.where((entry) => _since(entry.timestamp, cutoff30)).toList();
    final events90 = events.where((entry) => _since(entry.timestamp, cutoff90)).toList();
    final previous30 = events
        .where(
          (entry) =>
              _since(entry.timestamp, cutoff60) &&
              entry.timestamp.toUtc().isBefore(cutoff30),
        )
        .toList();

    final urges30 = _eventCount(events30, RecoveryEventType.urge);
    final victories30 = _eventCount(events30, RecoveryEventType.victory);
    final slips30 = _eventCount(events30, RecoveryEventType.relapse);
    final priorSlips = _eventCount(previous30, RecoveryEventType.relapse);

    String directionLine;
    if (events30.isEmpty && previous30.isEmpty) {
      directionLine =
          'There is not enough recent activity to compare the last two 30-day periods.';
    } else if (slips30 < priorSlips) {
      directionLine =
          'Logged slips decreased compared with the previous 30-day period.';
    } else if (slips30 > priorSlips) {
      directionLine =
          'Logged slips increased compared with the previous 30-day period. Review what changed before the earliest warning signs.';
    } else {
      directionLine =
          'Logged slips are level with the previous 30-day period.';
    }

    String nextFocus;
    if (slips30 > victories30 && slips30 > 0) {
      nextFocus =
          'Tighten one first action and use it before the urge becomes a private ritual.';
    } else if (victories30 > 0) {
      nextFocus =
          'Study the conditions around recent victories and repeat the easiest successful interruption.';
    } else if (urges30 > 0) {
      nextFocus =
          'Add outcome details to urge logs so effective interruptions become visible.';
    } else {
      nextFocus =
          'Log one early warning sign or recovery win to begin a clearer trend.';
    }

    return PremiumTrendSummary(
      urges30: urges30,
      victories30: victories30,
      slips30: slips30,
      urges90: _eventCount(events90, RecoveryEventType.urge),
      victories90: _eventCount(events90, RecoveryEventType.victory),
      slips90: _eventCount(events90, RecoveryEventType.relapse),
      moodLogs30: moods30.length,
      stageLogs30: stages30.length,
      averagePressure30: _averagePressure(moods30),
      topTrigger30: _topTrigger(events30),
      directionLine: directionLine,
      nextFocus: nextFocus,
    );
  }
}
