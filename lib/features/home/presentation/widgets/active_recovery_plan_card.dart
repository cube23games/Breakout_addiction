import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../premium/data/premium_access_repository.dart';
import '../../../premium/domain/premium_plan.dart';
import '../../../premium/domain/premium_status.dart';
import '../../../settings/data/feature_control_settings_repository.dart';
import '../../../premium_tools/data/active_recovery_program_repository.dart';
import '../../../premium_tools/data/premium_progress_repository.dart';
import '../../../premium_tools/data/recovery_program_repository.dart';
import '../../../premium_tools/domain/recovery_program.dart';

class ActiveRecoveryPlanCard extends StatefulWidget {
  const ActiveRecoveryPlanCard({super.key});

  @override
  State<ActiveRecoveryPlanCard> createState() =>
      _ActiveRecoveryPlanCardState();
}

class _ActiveRecoveryPlanCardState extends State<ActiveRecoveryPlanCard> {
  final PremiumAccessRepository _access = PremiumAccessRepository();
  final ActiveRecoveryProgramRepository _activePrograms =
      ActiveRecoveryProgramRepository();
  final PremiumProgressRepository _progress = PremiumProgressRepository();
  final FeatureControlSettingsRepository _settings =
      FeatureControlSettingsRepository();

  PremiumStatus? _status;
  RecoveryProgram? _activeProgram;
  String? _activeProgramId;
  int _completedDays = 0;
  bool _completedToday = false;
  bool _faithLayerEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _itemId(RecoveryProgram program) => 'program_${program.id}';

  Future<void> _load() async {
    final status = await _access.getStatus();
    final activeState = await _activePrograms.getState();
    final settings = await _settings.getSettings();
    RecoveryProgram? activeProgram;
    var completedDays = 0;
    var completedToday = false;

    if (activeState.activeProgramId != null) {
      for (final program in RecoveryProgramRepository.programs) {
        if (program.id == activeState.activeProgramId) {
          activeProgram = program;
          completedDays = await _progress.contiguousCompletedCount(
            _itemId(program),
            maxCount: program.steps.length,
          );
          completedToday = await _progress.completedToday(_itemId(program));
          break;
        }
      }
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _status = status;
      _activeProgram = activeProgram;
      _activeProgramId = activeState.activeProgramId;
      _completedDays = completedDays;
      _completedToday = completedToday;
      _faithLayerEnabled = settings.faithLayerEnabled;
      _loading = false;
    });
  }

  Future<bool> _confirmSwitch(RecoveryProgram selected) async {
    if (_activeProgramId == null || _activeProgramId == selected.id) {
      return true;
    }
    return await showDialog<bool>(
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
  }

  Future<void> _choosePlan() async {
    final status = _status;
    if (status == null) {
      return;
    }
    if (!status.plan.includes(PremiumPlan.plus)) {
      await Navigator.pushNamed(context, RouteNames.premium);
      await _load();
      return;
    }

    final visiblePrograms = RecoveryProgramRepository.programs
        .where(
          (program) =>
              !program.faithSensitive ||
              _faithLayerEnabled ||
              program.id == _activeProgramId,
        )
        .toList();

    final selected = await showModalBottomSheet<RecoveryProgram>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('Choose Your Recovery Plan', style: AppTypography.title),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Choose one plan to follow day by day. You can change plans later without deleting the old progress.',
              style: AppTypography.muted,
            ),
            const SizedBox(height: AppSpacing.md),
            for (final program in visiblePrograms)
              Card(
                child: ListTile(
                  title: Text(program.title),
                  subtitle: Text(
                    '${program.durationDays} days — ${program.description}',
                  ),
                  trailing: program.id == _activeProgramId
                      ? const Icon(Icons.check_circle)
                      : const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pop(context, program),
                ),
              ),
          ],
        ),
      ),
    );

    if (selected == null || selected.id == _activeProgramId) {
      return;
    }
    if (!await _confirmSwitch(selected)) {
      return;
    }

    final previous = _activeProgram;
    await _progress.reset(_itemId(selected));
    await _activePrograms.startProgram(
      programId: selected.id,
      previousProgramId: previous?.id,
      previousCompletedDays: previous == null ? 0 : _completedDays,
      previousTotalDays: previous?.steps.length ?? 0,
    );
    await _load();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${selected.title} starts at Day 1.')),
    );
  }

  Future<void> _openFullPlan() async {
    await Navigator.pushNamed(context, RouteNames.recoveryPrograms);
    await _load();
  }

  String _withoutDayPrefix(String step) {
    final marker = step.indexOf('—');
    if (marker < 0 || marker + 1 >= step.length) {
      return step;
    }
    return step.substring(marker + 1).trim();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final status = _status;
    final activeProgram = _activeProgram;

    return Card(
      color: colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.primary.withOpacity(0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: _loading || status == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.route_outlined,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Your Recovery Plan',
                          style: AppTypography.section,
                        ),
                      ),
                      Text(
                        status.plan.label,
                        style: AppTypography.muted,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (!status.plan.includes(PremiumPlan.plus)) ...[
                    Text(
                      'Follow one clear recovery action each day.',
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Day-by-day recovery plans are available with Breakout Plus and Breakout Plus AI.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PrimaryButton(
                      label: 'Explore Recovery Plans',
                      icon: Icons.workspace_premium_outlined,
                      onPressed: _choosePlan,
                    ),
                  ] else if (activeProgram == null) ...[
                    Text(
                      'Choose a day-by-day plan.',
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Your selected plan will show today’s action and progress here on Home.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PrimaryButton(
                      label: 'Choose a Recovery Plan',
                      icon: Icons.playlist_add_check_circle_outlined,
                      onPressed: _choosePlan,
                    ),
                  ] else ...[
                    Text(activeProgram.title, style: AppTypography.title),
                    const SizedBox(height: AppSpacing.sm),
                    LinearProgressIndicator(
                      value: activeProgram.steps.isEmpty
                          ? 0
                          : _completedDays / activeProgram.steps.length,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$_completedDays of ${activeProgram.steps.length} days completed',
                      style: AppTypography.muted,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (_completedDays >= activeProgram.steps.length) ...[
                      const Text(
                        'Plan complete',
                        style: AppTypography.section,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const Text(
                        'Review your completed days or choose the next plan.',
                      ),
                    ] else if (_completedToday) ...[
                      Text(
                        'Day $_completedDays complete',
                        style: AppTypography.section,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Next: ${_withoutDayPrefix(activeProgram.steps[_completedDays])}',
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const Text(
                        'The next day unlocks tomorrow.',
                        style: AppTypography.muted,
                      ),
                    ] else ...[
                      Text(
                        'Day ${_completedDays + 1} of ${activeProgram.steps.length}',
                        style: AppTypography.section,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _withoutDayPrefix(
                          activeProgram.steps[_completedDays],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    PrimaryButton(
                      label: _completedDays >= activeProgram.steps.length
                          ? 'View Completed Plan'
                          : _completedToday
                              ? 'View Plan Progress'
                              : 'Open Day ${_completedDays + 1}',
                      icon: Icons.arrow_forward,
                      onPressed: _openFullPlan,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _choosePlan,
                        icon: const Icon(Icons.swap_horiz),
                        label: const Text('Change Plan'),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
