import '../../cycle/domain/cycle_stage.dart';
import '../../log/data/cycle_stage_log_repository.dart';
import '../../log/data/mood_log_repository.dart';
import '../../log/data/recovery_event_repository.dart';
import '../../log/domain/cycle_stage_log_entry.dart';
import '../../log/domain/mood_entry.dart';
import '../../log/domain/recovery_event_entry.dart';
import '../domain/private_pattern_summary.dart';

class PrivatePatternRepository {
  final RecoveryEventRepository _events;
  final MoodLogRepository _moods;
  final CycleStageLogRepository _stages;

  PrivatePatternRepository({
    RecoveryEventRepository? events,
    MoodLogRepository? moods,
    CycleStageLogRepository? stages,
  })  : _events = events ?? RecoveryEventRepository(),
        _moods = moods ?? MoodLogRepository(),
        _stages = stages ?? CycleStageLogRepository();

  Future<PrivatePatternSummary> build({DateTime? now}) async {
    final current = (now ?? DateTime.now()).toUtc();
    final cutoff90 = current.subtract(const Duration(days: 90));
    final cutoff7 = current.subtract(const Duration(days: 7));
    final cutoff14 = current.subtract(const Duration(days: 14));

    final events = (await _events.getEntries())
        .where((entry) => !entry.timestamp.toUtc().isBefore(cutoff90))
        .toList();
    final moods = (await _moods.getEntries())
        .where((entry) => !entry.timestamp.toUtc().isBefore(cutoff90))
        .toList();
    final stages = (await _stages.getEntries())
        .where((entry) => !entry.timestamp.toUtc().isBefore(cutoff90))
        .toList();

    final riskEvents = events
        .where((entry) => entry.type != RecoveryEventType.victory)
        .toList();
    final victories = events
        .where((entry) => entry.type == RecoveryEventType.victory)
        .toList();
    final currentWeek = events
        .where((entry) => !entry.timestamp.toUtc().isBefore(cutoff7))
        .toList();
    final previousWeek = events
        .where(
          (entry) =>
              !entry.timestamp.toUtc().isBefore(cutoff14) &&
              entry.timestamp.toUtc().isBefore(cutoff7),
        )
        .toList();

    final peakDay = _peakDay(riskEvents);
    final peakTime = _peakTime(riskEvents);
    final topTrigger = _topValue(
      riskEvents.map(_triggerValue),
      fallback: 'No repeated trigger yet',
    );
    final triggerPair = _topPair(riskEvents);
    final preSlipSignal = _preSlipSignal(
      events: events,
      stages: stages,
      moods: moods,
    );
    final effectiveInterruption = _effectiveInterruption(victories);
    final direction = _weekDirection(
      currentWeek: currentWeek,
      previousWeek: previousWeek,
    );

    return PrivatePatternSummary(
      peakDay: peakDay,
      peakTime: peakTime,
      topTrigger: topTrigger,
      triggerPair: triggerPair,
      preSlipSignal: preSlipSignal,
      effectiveInterruption: effectiveInterruption,
      currentWeekDirection: direction,
      weeklySummary: _weeklySummary(
        currentWeek: currentWeek,
        previousWeek: previousWeek,
        topTrigger: topTrigger,
        peakDay: peakDay,
      ),
      evidenceCount: events.length + moods.length + stages.length,
    );
  }

  String _triggerValue(RecoveryEventEntry event) {
    if (event.trigger.trim().isNotEmpty) {
      return event.trigger.trim();
    }
    if (event.context.trim().isNotEmpty) {
      return event.context.trim();
    }
    return '';
  }

  String _peakDay(List<RecoveryEventEntry> events) {
    if (events.isEmpty) {
      return 'No clear day yet';
    }
    final counts = <int, int>{};
    for (final event in events) {
      final day = event.timestamp.toLocal().weekday;
      counts.update(day, (value) => value + 1, ifAbsent: () => 1);
    }
    final best = counts.entries.toList()
      ..sort((a, b) {
        final count = b.value.compareTo(a.value);
        return count != 0 ? count : a.key.compareTo(b.key);
      });
    return _dayName(best.first.key);
  }

  String _peakTime(List<RecoveryEventEntry> events) {
    if (events.isEmpty) {
      return 'No clear time yet';
    }
    final counts = <int, int>{};
    for (final event in events) {
      final bucket = event.timestamp.toLocal().hour ~/ 4;
      counts.update(bucket, (value) => value + 1, ifAbsent: () => 1);
    }
    final best = counts.entries.toList()
      ..sort((a, b) {
        final count = b.value.compareTo(a.value);
        return count != 0 ? count : a.key.compareTo(b.key);
      });
    final start = best.first.key * 4;
    final end = (start + 4) % 24;
    return '${_hourLabel(start)}–${_hourLabel(end)}';
  }

  String _topPair(List<RecoveryEventEntry> events) {
    final pairs = <String>[];
    for (final event in events) {
      final trigger = _triggerValue(event);
      final reason = event.reason.trim();
      if (trigger.isNotEmpty && reason.isNotEmpty) {
        pairs.add('$trigger + $reason');
      }
    }
    return _topValue(
      pairs,
      fallback: 'Add both trigger and reason to reveal combinations',
    );
  }

  String _preSlipSignal({
    required List<RecoveryEventEntry> events,
    required List<CycleStageLogEntry> stages,
    required List<MoodEntry> moods,
  }) {
    final slips = events
        .where((entry) => entry.type == RecoveryEventType.relapse)
        .toList();
    if (slips.isEmpty) {
      return 'No logged slip to compare yet';
    }

    final stageCounts = <CycleStage, int>{};
    for (final slip in slips) {
      final slipTime = slip.timestamp.toUtc();
      final windowStart = slipTime.subtract(const Duration(hours: 36));
      for (final stage in stages) {
        final time = stage.timestamp.toUtc();
        if (!time.isBefore(windowStart) && !time.isAfter(slipTime)) {
          stageCounts.update(
            stage.stage,
            (value) => value + 1,
            ifAbsent: () => 1,
          );
        }
      }
    }
    if (stageCounts.isNotEmpty) {
      final best = stageCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return '${best.first.key.title} often appeared within 36 hours before a logged slip';
    }

    final pressureValues = <int>[];
    for (final slip in slips) {
      final slipTime = slip.timestamp.toUtc();
      final windowStart = slipTime.subtract(const Duration(hours: 36));
      for (final mood in moods) {
        final time = mood.timestamp.toUtc();
        if (!time.isBefore(windowStart) && !time.isAfter(slipTime)) {
          pressureValues.add(
            mood.stress + mood.loneliness + mood.boredom,
          );
        }
      }
    }
    if (pressureValues.isNotEmpty) {
      final average =
          pressureValues.reduce((a, b) => a + b) / pressureValues.length;
      return 'Average combined pressure before logged slips was ${average.toStringAsFixed(1)}/30';
    }
    return 'Add a mood or cycle-stage check-in before risky periods to reveal earlier signals';
  }

  String _effectiveInterruption(List<RecoveryEventEntry> victories) {
    if (victories.isEmpty) {
      return 'No victory detail yet';
    }
    final reasons = victories
        .map((entry) => entry.reason.trim())
        .where((value) => value.isNotEmpty);
    final topReason = _topValue(reasons, fallback: '');
    if (topReason.isNotEmpty) {
      return '$topReason appears most often in victory logs';
    }
    final triggers = victories
        .map(_triggerValue)
        .where((value) => value.isNotEmpty);
    final topTrigger = _topValue(triggers, fallback: '');
    if (topTrigger.isNotEmpty) {
      return 'Victories have been logged most often around $topTrigger';
    }
    return 'Add what helped to victory logs so effective interruptions become visible';
  }

  String _weekDirection({
    required List<RecoveryEventEntry> currentWeek,
    required List<RecoveryEventEntry> previousWeek,
  }) {
    final currentVictories = _count(currentWeek, RecoveryEventType.victory);
    final previousVictories = _count(previousWeek, RecoveryEventType.victory);
    final currentSlips = _count(currentWeek, RecoveryEventType.relapse);
    final previousSlips = _count(previousWeek, RecoveryEventType.relapse);

    if (currentWeek.isEmpty && previousWeek.isEmpty) {
      return 'Not enough activity for a weekly comparison';
    }
    if (currentVictories > previousVictories && currentSlips <= previousSlips) {
      return 'More victories with no increase in slips compared with last week';
    }
    if (currentSlips < previousSlips) {
      return 'Fewer slips than last week';
    }
    if (currentSlips > previousSlips) {
      return 'More slips than last week; review the earliest changed condition';
    }
    if (currentVictories > previousVictories) {
      return 'More victories than last week';
    }
    return 'The current week is broadly level with the previous week';
  }

  String _weeklySummary({
    required List<RecoveryEventEntry> currentWeek,
    required List<RecoveryEventEntry> previousWeek,
    required String topTrigger,
    required String peakDay,
  }) {
    final victories = _count(currentWeek, RecoveryEventType.victory);
    final urges = _count(currentWeek, RecoveryEventType.urge);
    final slips = _count(currentWeek, RecoveryEventType.relapse);
    final previousSlips = _count(previousWeek, RecoveryEventType.relapse);

    if (currentWeek.isEmpty) {
      return 'No recovery events were logged this week. Start with one honest entry rather than trying to reconstruct everything.';
    }

    final change = slips < previousSlips
        ? 'slips decreased'
        : slips > previousSlips
            ? 'slips increased'
            : 'slips stayed level';
    final triggerLine = topTrigger == 'No repeated trigger yet'
        ? 'No repeated trigger is clear yet.'
        : '$topTrigger remains the most repeated trigger.';
    final dayLine = peakDay == 'No clear day yet'
        ? ''
        : ' $peakDay currently carries the most logged risk.';
    return 'This week includes $victories victories, $urges urges, and '
        '$slips slips; $change compared with last week. '
        '$triggerLine$dayLine';
  }

  int _count(
    List<RecoveryEventEntry> events,
    RecoveryEventType type,
  ) {
    return events.where((entry) => entry.type == type).length;
  }

  String _topValue(
    Iterable<String> values, {
    required String fallback,
  }) {
    final counts = <String, int>{};
    for (final raw in values) {
      final value = raw.trim();
      if (value.isEmpty) {
        continue;
      }
      counts.update(value, (count) => count + 1, ifAbsent: () => 1);
    }
    if (counts.isEmpty) {
      return fallback;
    }
    final entries = counts.entries.toList()
      ..sort((a, b) {
        final count = b.value.compareTo(a.value);
        return count != 0 ? count : a.key.compareTo(b.key);
      });
    return entries.first.key;
  }

  String _dayName(int weekday) {
    const names = <int, String>{
      DateTime.monday: 'Monday',
      DateTime.tuesday: 'Tuesday',
      DateTime.wednesday: 'Wednesday',
      DateTime.thursday: 'Thursday',
      DateTime.friday: 'Friday',
      DateTime.saturday: 'Saturday',
      DateTime.sunday: 'Sunday',
    };
    return names[weekday] ?? 'No clear day yet';
  }

  String _hourLabel(int hour) {
    final normalized = hour % 24;
    if (normalized == 0) {
      return '12 AM';
    }
    if (normalized < 12) {
      return '$normalized AM';
    }
    if (normalized == 12) {
      return '12 PM';
    }
    return '${normalized - 12} PM';
  }
}
