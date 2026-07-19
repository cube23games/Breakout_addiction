import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/guided_routine_repository.dart';
import '../data/premium_preferences_repository.dart';
import '../data/premium_progress_repository.dart';
import '../domain/guided_routine.dart';
import '../domain/premium_preferences.dart';

class GuidedRoutinesScreen extends StatefulWidget {
  const GuidedRoutinesScreen({super.key});

  @override
  State<GuidedRoutinesScreen> createState() =>
      _GuidedRoutinesScreenState();
}

class _GuidedRoutinesScreenState extends State<GuidedRoutinesScreen> {
  final PremiumProgressRepository _progress = PremiumProgressRepository();
  final PremiumPreferencesRepository _preferences =
      PremiumPreferencesRepository();
  final Map<String, int> _completedCount = <String, int>{};
  PremiumRoutineFocus _focus = PremiumRoutineFocus.balanced;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final preferences = await _preferences.getPreferences();
    for (final routine in GuidedRoutineRepository.routines) {
      _completedCount[routine.id] =
          await _progress.contiguousCompletedCount(
        routine.id,
        maxCount: routine.steps.length,
      );
    }
    if (mounted) {
      setState(() {
        _focus = preferences.routineFocus;
        _loading = false;
      });
    }
  }

  Future<void> _completeCurrent(GuidedRoutine routine) async {
    final count = _completedCount[routine.id] ?? 0;
    if (count >= routine.steps.length) {
      return;
    }
    await _progress.setSequentialCount(
      itemId: routine.id,
      completedCount: count + 1,
      maxCount: routine.steps.length,
    );
    await _load();
  }

  Future<void> _reset(GuidedRoutine routine) async {
    await _progress.reset(routine.id);
    await _load();
  }

  List<GuidedRoutine> _orderedRoutines() {
    final routines = <GuidedRoutine>[...GuidedRoutineRepository.routines];
    if (_focus == PremiumRoutineFocus.balanced) {
      return routines;
    }
    final firstId = _focus == PremiumRoutineFocus.prevention
        ? 'risk_window_prep'
        : 'post_slip_rebuild';
    routines.sort((a, b) {
      if (a.id == firstId) return -1;
      if (b.id == firstId) return 1;
      return 0;
    });
    return routines;
  }

  Widget _activityTile({
    required GuidedRoutine routine,
    required int index,
    required int completedCount,
  }) {
    final completed = index < completedCount;
    final active = index == completedCount;
    final locked = index > completedCount;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        completed
            ? Icons.check_circle
            : active
                ? Icons.radio_button_checked
                : Icons.lock_outline,
      ),
      title: Text(routine.steps[index]),
      subtitle: Text(
        completed
            ? 'Finished'
            : active
                ? 'Current activity'
                : 'Complete the current activity first',
        style: AppTypography.muted,
      ),
      enabled: !locked,
    );
  }

  Widget _routineCard(GuidedRoutine routine) {
    final count = (_completedCount[routine.id] ?? 0)
        .clamp(0, routine.steps.length);
    final finished = count >= routine.steps.length;

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(routine.title, style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          Text(routine.description, style: AppTypography.muted),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: routine.steps.isEmpty ? 0 : count / routine.steps.length,
          ),
          const SizedBox(height: 6),
          Text(
            '$count of ${routine.steps.length} activities finished',
            style: AppTypography.muted,
          ),
          const SizedBox(height: AppSpacing.md),
          for (var index = 0; index < routine.steps.length; index++)
            _activityTile(
              routine: routine,
              index: index,
              completedCount: count,
            ),
          const SizedBox(height: AppSpacing.sm),
          if (finished)
            const Text(
              'Routine finished for this session.',
              style: AppTypography.body,
            )
          else
            PrimaryButton(
              label: 'Complete current activity',
              icon: Icons.check,
              onPressed: () => _completeCurrent(routine),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _reset(routine),
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset routine'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guided Routines')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text('Choose one activity at a time.',
                    style: AppTypography.title),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Finish the current activity to unlock the next one. Progress stays on this device.',
                  style: AppTypography.muted,
                ),
                const SizedBox(height: AppSpacing.lg),
                for (final routine in _orderedRoutines()) ...[
                  _routineCard(routine),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
    );
  }
}
