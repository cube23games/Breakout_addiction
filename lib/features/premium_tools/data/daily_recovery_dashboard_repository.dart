import '../../log/data/cycle_stage_log_repository.dart';
import '../../log/data/mood_log_repository.dart';
import '../../log/data/recovery_event_repository.dart';
import '../../log/domain/mood_entry.dart';
import '../../log/domain/recovery_event_entry.dart';
import '../../risk/data/risk_window_repository.dart';
import '../../risk/domain/risk_window.dart';
import '../../support/data/recovery_plan_repository.dart';
import '../domain/daily_recovery_dashboard.dart';

class DailyRecoveryDashboardRepository {
  final MoodLogRepository _moods;
  final CycleStageLogRepository _stages;
  final RecoveryEventRepository _events;
  final RiskWindowRepository _riskWindows;
  final RecoveryPlanRepository _plan;

  DailyRecoveryDashboardRepository({
    MoodLogRepository? moods,
    CycleStageLogRepository? stages,
    RecoveryEventRepository? events,
    RiskWindowRepository? riskWindows,
    RecoveryPlanRepository? plan,
  })  : _moods = moods ?? MoodLogRepository(),
        _stages = stages ?? CycleStageLogRepository(),
        _events = events ?? RecoveryEventRepository(),
        _riskWindows = riskWindows ?? RiskWindowRepository(),
        _plan = plan ?? RecoveryPlanRepository();

  Future<DailyRecoveryDashboard> build({DateTime? now}) async {
    final current = now ?? DateTime.now();
    final cutoff7 = current.subtract(const Duration(days: 7));
    final cutoff30 = current.subtract(const Duration(days: 30));
    final cutoff24 = current.subtract(const Duration(hours: 24));

    final moods = await _moods.getEntries();
    final stages = await _stages.getEntries();
    final events = await _events.getEntries();
    final windows = (await _riskWindows.getRiskWindows())
        .where((window) => window.isEnabled)
        .toList();
    final plan = await _plan.getPlan();

    final moods7 = moods
        .where((entry) => !entry.timestamp.isBefore(cutoff7))
        .toList();
    final events7 = events
        .where((entry) => !entry.timestamp.isBefore(cutoff7))
        .toList();
    final events24 = events
        .where((entry) => !entry.timestamp.isBefore(cutoff24))
        .toList();
    final events30 = events
        .where((entry) => !entry.timestamp.isBefore(cutoff30))
        .toList();
    final stages7 = stages
        .where((entry) => !entry.timestamp.isBefore(cutoff7))
        .toList();

    final activeWindow = windows
        .where((window) => _contains(window, current))
        .cast<RiskWindow?>()
        .firstWhere((window) => window != null, orElse: () => null);
    final nextWindow = _nextWindow(windows, current);
    final averagePressure = _averagePressure(moods7);

    var score = (averagePressure * 6).round();
    score += events24
        .where((entry) => entry.type == RecoveryEventType.urge)
        .fold<int>(0, (sum, entry) => sum + entry.intensity);
    score += events24
            .where((entry) => entry.type == RecoveryEventType.relapse)
            .length *
        18;
    if (activeWindow != null) {
      score += 18;
    }
    if (stages7.isNotEmpty && stages7.first.intensity >= 7) {
      score += 8;
    }
    score = score.clamp(0, 100).toInt();

    final riskLabel = score >= 70
        ? 'High'
        : score >= 40
            ? 'Elevated'
            : 'Steady';
    final riskReason = _riskReason(
      score: score,
      activeWindow: activeWindow,
      averagePressure: averagePressure,
      events24: events24,
    );
    final topTrigger = _topTrigger(events30);
    final weeklyVictories = _count(events7, RecoveryEventType.victory);
    final weeklyUrges = _count(events7, RecoveryEventType.urge);
    final weeklySlips = _count(events7, RecoveryEventType.relapse);
    final weeklyCheckIns = moods7.length + stages7.length;

    final routine = _recommendedRoutine(
      current: current,
      score: score,
      activeWindow: activeWindow,
      weeklySlips: weeklySlips,
    );

    final firstAction = plan.firstAction.trim().isEmpty
        ? 'Open Rescue and change location before negotiating with the urge.'
        : plan.firstAction.trim();

    return DailyRecoveryDashboard(
      riskScore: score,
      riskLabel: riskLabel,
      riskReason: riskReason,
      topTrigger: topTrigger,
      nextRiskWindow: nextWindow,
      recommendedRoutineId: routine.$1,
      recommendedRoutineTitle: routine.$2,
      firstAction: firstAction,
      weeklyVictories: weeklyVictories,
      weeklyUrges: weeklyUrges,
      weeklySlips: weeklySlips,
      weeklyCheckIns: weeklyCheckIns,
      weeklyLine: _weeklyLine(
        victories: weeklyVictories,
        urges: weeklyUrges,
        slips: weeklySlips,
        checkIns: weeklyCheckIns,
      ),
      todayFocus: _todayFocus(
        score: score,
        trigger: topTrigger,
        planFirstAction: firstAction,
      ),
    );
  }

  int _count(
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
      (sum, entry) =>
          sum + entry.stress + entry.loneliness + entry.boredom,
    );
    return total / (moods.length * 3);
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
      return 'No repeated trigger yet';
    }
    final entries = counts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });
    return entries.first.key;
  }

  bool _contains(RiskWindow window, DateTime now) {
    final minute = now.hour * 60 + now.minute;
    final start = window.startHour * 60 + window.startMinute;
    final end = window.endHour * 60 + window.endMinute;
    if (start == end) {
      return true;
    }
    if (end > start) {
      return minute >= start && minute < end;
    }
    return minute >= start || minute < end;
  }

  String _nextWindow(List<RiskWindow> windows, DateTime now) {
    if (windows.isEmpty) {
      return 'No enabled risk window';
    }
    final useMinutes = now.hour * 60 + now.minute;
    RiskWindow? best;
    var bestDistance = 24 * 60 + 1;
    for (final window in windows) {
      final start = window.startHour * 60 + window.startMinute;
      var distance = start - useMinutes;
      if (distance < 0) {
        distance += 24 * 60;
      }
      if (distance < bestDistance) {
        bestDistance = distance;
        best = window;
      }
    }
    if (best == null) {
      return 'No enabled risk window';
    }
    if (_contains(best, now)) {
      return '${best.label} is active now';
    }
    final hours = bestDistance ~/ 60;
    final minutes = bestDistance % 60;
    final distanceLabel = hours > 0
        ? '${hours}h ${minutes}m'
        : '${minutes}m';
    return '${best.label} begins in $distanceLabel';
  }

  String _riskReason({
    required int score,
    required RiskWindow? activeWindow,
    required double averagePressure,
    required List<RecoveryEventEntry> events24,
  }) {
    if (activeWindow != null) {
      return '${activeWindow.label} is active. Prepare before pressure rises further.';
    }
    if (events24.any((entry) => entry.type == RecoveryEventType.relapse)) {
      return 'A recent slip makes the next interruption especially important.';
    }
    if (events24.any((entry) => entry.type == RecoveryEventType.urge)) {
      return 'A recent urge is still part of today’s risk picture.';
    }
    if (averagePressure >= 7) {
      return 'Recent stress, loneliness, or boredom is running high.';
    }
    if (score == 0) {
      return 'Add a mood check-in or recovery event for a clearer private snapshot.';
    }
    return 'No single urgent signal stands out. Keep the next safe action visible.';
  }

  (String, String) _recommendedRoutine({
    required DateTime current,
    required int score,
    required RiskWindow? activeWindow,
    required int weeklySlips,
  }) {
    if (weeklySlips > 0) {
      return ('post_slip_rebuild', 'Post-Slip Rebuild');
    }
    if (activeWindow != null || score >= 60) {
      return ('risk_window_prep', 'High-Risk Window Prep');
    }
    if (current.hour >= 18) {
      return ('evening_protection', 'Evening Protection');
    }
    return ('morning_reset', 'Morning Reset');
  }

  String _weeklyLine({
    required int victories,
    required int urges,
    required int slips,
    required int checkIns,
  }) {
    if (victories + urges + slips + checkIns == 0) {
      return 'No activity yet this week. One honest check-in is enough to begin.';
    }
    return '$victories victories, $urges urges, $slips slips, and '
        '$checkIns mood or cycle check-ins this week.';
  }

  String _todayFocus({
    required int score,
    required String trigger,
    required String planFirstAction,
  }) {
    if (score >= 70) {
      return 'Use your first action early: $planFirstAction';
    }
    if (trigger != 'No repeated trigger yet') {
      return 'Watch for $trigger and act before the private ritual begins.';
    }
    return 'Practice one recovery action before you need it.';
  }
}
