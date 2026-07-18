import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/info_card.dart';
import '../../settings/data/feature_control_settings_repository.dart';
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
  final PremiumProgressRepository _progress =
      PremiumProgressRepository();
  final FeatureControlSettingsRepository _settings =
      FeatureControlSettingsRepository();
  final Map<String, Set<int>> _completed = <String, Set<int>>{};
  bool _faithLayerEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await _settings.getSettings();
    for (final program in RecoveryProgramRepository.programs) {
      _completed[program.id] =
          await _progress.completedSteps('program_${program.id}');
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _faithLayerEnabled = settings.faithLayerEnabled;
      _loading = false;
    });
  }

  Future<void> _toggle(
    RecoveryProgram program,
    int index,
    bool completed,
  ) async {
    await _progress.setStep(
      itemId: 'program_${program.id}',
      index: index,
      completed: completed,
    );
    await _load();
  }

  Future<void> _reset(RecoveryProgram program) async {
    await _progress.reset('program_${program.id}');
    await _load();
  }

  Widget _programCard(RecoveryProgram program) {
    final completed = _completed[program.id] ?? <int>{};
    final count = completed
        .where((index) => index >= 0 && index < program.steps.length)
        .length;
    final value = program.steps.isEmpty ? 0.0 : count / program.steps.length;

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(program.title, style: AppTypography.section),
              ),
              if (program.faithSensitive)
                const Chip(label: Text('Optional faith')),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(program.description, style: AppTypography.muted),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${program.durationDays} days • $count of ${program.steps.length} complete',
            style: AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(value: value),
          const SizedBox(height: AppSpacing.sm),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: const Text('Open program steps'),
            children: [
              for (var index = 0; index < program.steps.length; index++)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: completed.contains(index),
                  onChanged: (checked) => _toggle(
                    program,
                    index,
                    checked ?? false,
                  ),
                  title: Text(program.steps[index]),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
            ],
          ),
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

  @override
  Widget build(BuildContext context) {
    final visiblePrograms = RecoveryProgramRepository.programs
        .where(
          (program) =>
              !program.faithSensitive || _faithLayerEnabled,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Guided Recovery Programs')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(
                  'Build recovery through a real sequence.',
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Programs stay private on this device. Progress is a guide for continuity, not a moral score.',
                  style: AppTypography.muted,
                ),
                const SizedBox(height: AppSpacing.lg),
                for (final program in visiblePrograms) ...[
                  _programCard(program),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
    );
  }
}
