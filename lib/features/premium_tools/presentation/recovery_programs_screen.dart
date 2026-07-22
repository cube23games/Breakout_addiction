import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/info_card.dart';
import '../../settings/data/feature_control_settings_repository.dart';
import '../../faith/presentation/faith_reflection_card.dart';
import '../data/active_recovery_program_repository.dart';
import '../data/premium_progress_repository.dart';
import '../data/recovery_program_repository.dart';
import '../domain/recovery_program.dart';

class RecoveryProgramsScreen extends StatefulWidget {
  const RecoveryProgramsScreen({super.key});

  @override
  State<RecoveryProgramsScreen> createState() =>
      _RecoveryProgramsScreenState();
}

class _RecoveryProgramsScreenState extends State<RecoveryProgramsScreen> {
  final PremiumProgressRepository _progress = PremiumProgressRepository();
  final ActiveRecoveryProgramRepository _activePrograms =
      ActiveRecoveryProgramRepository();
  final FeatureControlSettingsRepository _settings =
      FeatureControlSettingsRepository();
  final Map<String, int> _completedCount = <String, int>{};
  final Map<String, bool> _completedToday = <String, bool>{};
  List<ArchivedRecoveryProgram> _pastPrograms =
      <ArchivedRecoveryProgram>[];
  String? _activeProgramId;
  bool _faithLayerEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _itemId(RecoveryProgram program) => 'program_${program.id}';

  Future<void> _load() async {
    final settings = await _settings.getSettings();
    final activeState = await _activePrograms.getState();
    for (final program in RecoveryProgramRepository.programs) {
      final itemId = _itemId(program);
      _completedCount[program.id] =
          await _progress.contiguousCompletedCount(
        itemId,
        maxCount: program.steps.length,
      );
      _completedToday[program.id] =
          await _progress.completedToday(itemId);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _activeProgramId = activeState.activeProgramId;
      _pastPrograms = activeState.pastPrograms;
      _faithLayerEnabled = settings.faithLayerEnabled;
      _loading = false;
    });
  }

  RecoveryProgram? _programById(String? id) {
    if (id == null) {
      return null;
    }
    for (final program in RecoveryProgramRepository.programs) {
      if (program.id == id) {
        return program;
      }
    }
    return null;
  }

  Future<void> _selectProgram(RecoveryProgram selected) async {
    if (_activeProgramId == selected.id) {
      return;
    }

    final current = _programById(_activeProgramId);
    if (current != null) {
      final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Change recovery plans?'),
              content: const Text(
                'Your current progress will be saved in Past Plans. '
                'The selected plan will begin at Day 1.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Keep Current Plan'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Change Plan'),
                ),
              ],
            ),
          ) ??
          false;
      if (!confirmed) {
        return;
      }
    }

    await _progress.reset(_itemId(selected));
    await _activePrograms.startProgram(
      programId: selected.id,
      previousProgramId: current?.id,
      previousCompletedDays:
          current == null ? 0 : (_completedCount[current.id] ?? 0),
      previousTotalDays: current?.steps.length ?? 0,
    );
    await _load();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${selected.title} starts at Day 1.')),
    );
  }

  Future<void> _completeNextDay(RecoveryProgram program) async {
    if (_activeProgramId != program.id) {
      return;
    }
    final completed = await _progress.completeNextDay(
      itemId: _itemId(program),
      maxCount: program.steps.length,
    );
    if (!mounted) {
      return;
    }
    if (!completed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The next day unlocks tomorrow.')),
      );
      return;
    }
    await _load();
  }

  Future<void> _reset(RecoveryProgram program) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reset this program?'),
            content: const Text(
              'This clears the completed days for this program on this device.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Reset'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) {
      return;
    }
    await _progress.reset(_itemId(program));
    await _load();
  }

  Widget _dayTile({
    required RecoveryProgram program,
    required int index,
    required int completedCount,
  }) {
    final completed = index < completedCount;
    final active = index == completedCount &&
        _activeProgramId == program.id;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        completed
            ? Icons.check_circle
            : active
                ? Icons.today_outlined
                : Icons.lock_outline,
      ),
      title: Text(program.steps[index]),
      subtitle: Text(
        completed
            ? 'Completed'
            : active
                ? 'Current day'
                : 'Locked',
        style: AppTypography.muted,
      ),
      enabled: completed || active,
    );
  }

  Widget _programCard(RecoveryProgram program) {
    final count = (_completedCount[program.id] ?? 0)
        .clamp(0, program.steps.length)
        .toInt();
    final completedToday = _completedToday[program.id] ?? false;
    final finished = count >= program.steps.length;
    final value = program.steps.isEmpty ? 0.0 : count / program.steps.length;
    final isActive = _activeProgramId == program.id;

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(program.title, style: AppTypography.section),
              ),
              if (isActive)
                const Chip(
                  avatar: Icon(Icons.route_outlined, size: 18),
                  label: Text('Active plan'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(program.description, style: AppTypography.muted),
          if (program.faithSensitive) ...[
            const SizedBox(height: AppSpacing.sm),
            const Row(
              children: [
                Icon(Icons.church_outlined, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Includes optional Christian reflection.'),
                ),
              ],
            ),
          ],
          if (program.faithSensitive && isActive && _faithLayerEnabled) ...[
            const SizedBox(height: AppSpacing.md),
            FaithReflectionCard(dayNumber: finished ? program.steps.length : count + 1),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${program.durationDays} days • $count of ${program.steps.length} completed',
            style: AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(value: value),
          const SizedBox(height: AppSpacing.md),
          if (!isActive)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _selectProgram(program),
                icon: const Icon(Icons.playlist_add_check_circle_outlined),
                label: Text(
                  _activeProgramId == null
                      ? 'Start This Plan'
                      : 'Change to This Plan',
                ),
              ),
            )
          else if (finished)
            const Text('Program complete.', style: AppTypography.body)
          else ...[
            Text(
              completedToday
                  ? 'Day $count is complete. Day ${count + 1} unlocks tomorrow.'
                  : 'Day ${count + 1} is ready.',
              style: AppTypography.body,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              program.steps[count],
              style: AppTypography.section,
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed:
                    completedToday ? null : () => _completeNextDay(program),
                icon: Icon(
                  completedToday
                      ? Icons.lock_clock
                      : Icons.check_circle_outline,
                ),
                label: Text(
                  completedToday
                      ? 'Next day unlocks tomorrow'
                      : 'Complete Day ${count + 1}',
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: const Text('View day-by-day plan'),
            children: [
              for (var index = 0; index < program.steps.length; index++)
                _dayTile(
                  program: program,
                  index: index,
                  completedCount: count,
                ),
            ],
          ),
          if (isActive)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _reset(program),
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset program'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _pastPlansCard() {
    if (_pastPrograms.isEmpty) {
      return const SizedBox.shrink();
    }
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Past Plans', style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Changing plans does not erase the progress you already made.',
            style: AppTypography.muted,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final archived in _pastPrograms)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history),
              title: Text(
                _programById(archived.programId)?.title ??
                    archived.programId,
              ),
              subtitle: Text(
                '${archived.completedDays} of ${archived.totalDays} days completed',
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visiblePrograms = RecoveryProgramRepository.programs
        .where(
          (program) =>
              !program.faithSensitive ||
              _faithLayerEnabled ||
              program.id == _activeProgramId,
        )
        .toList()
      ..sort((a, b) {
        if (a.id == _activeProgramId) return -1;
        if (b.id == _activeProgramId) return 1;
        return 0;
      });

    return Scaffold(
      appBar: AppBar(title: const Text('Guided Recovery Programs')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(
                  _activeProgramId == null
                      ? 'Choose one recovery plan.'
                      : 'Follow today’s recovery action.',
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Only the active plan advances. Future days remain locked until their day arrives. Progress is a guide for continuity, not a moral score.',
                  style: AppTypography.muted,
                ),
                const SizedBox(height: AppSpacing.lg),
                for (final program in visiblePrograms) ...[
                  _programCard(program),
                  const SizedBox(height: AppSpacing.md),
                ],
                _pastPlansCard(),
              ],
            ),
    );
  }
}
