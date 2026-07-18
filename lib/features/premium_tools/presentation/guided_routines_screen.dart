import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/info_card.dart';
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

class _GuidedRoutinesScreenState
    extends State<GuidedRoutinesScreen> {
  final PremiumProgressRepository _progress =
      PremiumProgressRepository();
  final PremiumPreferencesRepository _preferences =
      PremiumPreferencesRepository();
  final Map<String, Set<int>> _completed = <String, Set<int>>{};
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
      _completed[routine.id] =
          await _progress.completedSteps(routine.id);
    }
    if (mounted) {
      setState(() {
        _focus = preferences.routineFocus;
        _loading = false;
      });
    }
  }

  Future<void> _toggle(
    GuidedRoutine routine,
    int index,
    bool value,
  ) async {
    await _progress.setStep(
      itemId: routine.id,
      index: index,
      completed: value,
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

  Widget _routineCard(GuidedRoutine routine) {
    final completed = _completed[routine.id] ?? <int>{};
    final count = completed.length.clamp(0, routine.steps.length);

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(routine.title, style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          Text(routine.description, style: AppTypography.muted),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: routine.steps.isEmpty
                ? 0
                : count / routine.steps.length,
          ),
          const SizedBox(height: 6),
          Text(
            '$count of ${routine.steps.length} steps complete',
            style: AppTypography.muted,
          ),
          const SizedBox(height: AppSpacing.md),
          for (var index = 0;
              index < routine.steps.length;
              index++)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: completed.contains(index),
              onChanged: (value) => _toggle(
                routine,
                index,
                value ?? false,
              ),
              title: Text(routine.steps[index]),
              controlAffinity: ListTileControlAffinity.leading,
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
                Text(
                  'Make the next steps concrete.',
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Progress stays on this device. Completing a routine is support, not a score or a moral grade.',
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
