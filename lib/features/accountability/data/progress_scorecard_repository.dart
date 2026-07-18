import '../../log/data/cycle_stage_log_repository.dart';
import '../../log/data/mood_log_repository.dart';
import '../../log/data/recovery_event_repository.dart';
import '../../log/domain/recovery_event_entry.dart';
import '../../premium_tools/data/guided_routine_repository.dart';
import '../../premium_tools/data/premium_progress_repository.dart';
import '../../premium_tools/data/recovery_program_repository.dart';
import '../../support/data/recovery_plan_repository.dart';
import '../domain/progress_scorecard.dart';

class ProgressScorecardRepository {
  final RecoveryEventRepository _events;
  final MoodLogRepository _moods;
  final CycleStageLogRepository _stages;
  final RecoveryPlanRepository _plan;
  final PremiumProgressRepository _progress;

  ProgressScorecardRepository({
    RecoveryEventRepository? events,
    MoodLogRepository? moods,
    CycleStageLogRepository? stages,
    RecoveryPlanRepository? plan,
    PremiumProgressRepository? progress,
  })  : _events = events ?? RecoveryEventRepository(),
        _moods = moods ?? MoodLogRepository(),
        _stages = stages ?? CycleStageLogRepository(),
        _plan = plan ?? RecoveryPlanRepository(),
        _progress = progress ?? PremiumProgressRepository();

  Future<ProgressScorecard> build({DateTime? now}) async {
    final current = now ?? DateTime.now();
    final cutoff7 = current.subtract(const Duration(days: 7));
    final events = (await _events.getEntries())
        .where((entry) => !entry.timestamp.isBefore(cutoff7))
        .toList();
    final moods = (await _moods.getEntries())
        .where((entry) => !entry.timestamp.isBefore(cutoff7))
        .toList();
    final stages = (await _stages.getEntries())
        .where((entry) => !entry.timestamp.isBefore(cutoff7))
        .toList();
    final plan = await _plan.getPlan();

    var routineCompleted = 0;
    var routineTotal = 0;
    var completedRoutines = 0;
    for (final routine in GuidedRoutineRepository.routines) {
      final completed = await _progress.completedSteps(routine.id);
      final valid = completed
          .where((index) => index >= 0 && index < routine.steps.length)
          .length;
      routineCompleted += valid;
      routineTotal += routine.steps.length;
      if (routine.steps.isNotEmpty && valid == routine.steps.length) {
        completedRoutines++;
      }
    }

    var programCompleted = 0;
    var programTotal = 0;
    var programsStarted = 0;
    for (final program in RecoveryProgramRepository.programs) {
      final completed =
          await _progress.completedSteps('program_${program.id}');
      final valid = completed
          .where((index) => index >= 0 && index < program.steps.length)
          .length;
      programCompleted += valid;
      programTotal += program.steps.length;
      if (valid > 0) {
        programsStarted++;
      }
    }

    final victories = _count(events, RecoveryEventType.victory);
    final urges = _count(events, RecoveryEventType.urge);
    final slips = _count(events, RecoveryEventType.relapse);
    final checkIns = moods.length + stages.length;
    final routineRatio =
        routineTotal == 0 ? 0.0 : routineCompleted / routineTotal;
    final programRatio =
        programTotal == 0 ? 0.0 : programCompleted / programTotal;

    var score = 0;
    score += (victories * 10).clamp(0, 25).toInt();
    score += (checkIns * 4).clamp(0, 20).toInt();
    score += (urges * 2).clamp(0, 10).toInt();
    score += (plan.completion * 20).round();
    score += (routineRatio * 15).round();
    score += (programRatio * 10).round();
    score = score.clamp(0, 100).toInt();

    final milestones = <String>[
      if (checkIns > 0) 'You completed $checkIns honest check-ins this week.',
      if (victories > 0) 'You recorded $victories recovery victories this week.',
      if (plan.completedSections >= 6)
        'Your recovery plan has ${plan.completedSections} prepared sections.',
      if (completedRoutines > 0)
        '$completedRoutines guided routine${completedRoutines == 1 ? '' : 's'} fully completed.',
      if (programsStarted > 0)
        '$programsStarted structured program${programsStarted == 1 ? '' : 's'} in progress.',
    ];

    if (milestones.isEmpty) {
      milestones.add(
        'One honest check-in or one prepared plan section is enough to start building continuity.',
      );
    }

    return ProgressScorecard(
      engagementScore: score,
      momentumLabel: score >= 70
          ? 'Strong continuity'
          : score >= 40
              ? 'Building continuity'
              : 'Early foundation',
      scoreMeaning:
          'This score reflects recovery engagement and preparation. It is not a measure of worth, purity, or whether you deserve support.',
      victories7: victories,
      urges7: urges,
      slips7: slips,
      checkIns7: checkIns,
      routineStepsCompleted: routineCompleted,
      routineStepsTotal: routineTotal,
      programStepsCompleted: programCompleted,
      programStepsTotal: programTotal,
      planSectionsCompleted: plan.completedSections,
      planSectionsTotal: plan.totalSections,
      milestones: milestones,
      nextFocus: _nextFocus(
        planProgress: plan.completion,
        checkIns: checkIns,
        routineRatio: routineRatio,
        programRatio: programRatio,
      ),
    );
  }

  int _count(
    List<RecoveryEventEntry> events,
    RecoveryEventType type,
  ) {
    return events.where((entry) => entry.type == type).length;
  }

  String _nextFocus({
    required double planProgress,
    required int checkIns,
    required double routineRatio,
    required double programRatio,
  }) {
    if (planProgress < 0.5) {
      return 'Prepare one more section of the recovery plan.';
    }
    if (checkIns == 0) {
      return 'Add one mood or cycle-stage check-in this week.';
    }
    if (routineRatio < 0.2) {
      return 'Complete one guided routine from beginning to end.';
    }
    if (programRatio < 0.1) {
      return 'Start the structured program that matches the current risk.';
    }
    return 'Review private patterns and carry one useful protection into next week.';
  }
}
