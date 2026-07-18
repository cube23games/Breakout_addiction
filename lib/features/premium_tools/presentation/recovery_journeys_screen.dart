import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/info_card.dart';
import '../../settings/data/feature_control_settings_repository.dart';
import '../data/premium_progress_repository.dart';
import '../data/recovery_journey_repository.dart';
import '../domain/recovery_journey.dart';

class RecoveryJourneysScreen extends StatefulWidget {
  const RecoveryJourneysScreen({super.key});

  @override
  State<RecoveryJourneysScreen> createState() =>
      _RecoveryJourneysScreenState();
}

class _RecoveryJourneysScreenState
    extends State<RecoveryJourneysScreen> {
  final PremiumProgressRepository _progress =
      PremiumProgressRepository();
  final FeatureControlSettingsRepository _settings =
      FeatureControlSettingsRepository();
  final Map<String, Set<int>> _completed = <String, Set<int>>{};
  bool _faithEnabled = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await _settings.getSettings();
    for (final journey in RecoveryJourneyRepository.journeys) {
      _completed[journey.id] =
          await _progress.completedSteps(journey.id);
    }
    if (mounted) {
      setState(() {
        _faithEnabled = settings.faithLayerEnabled;
        _loading = false;
      });
    }
  }

  Future<void> _toggle(
    RecoveryJourney journey,
    int index,
    bool value,
  ) async {
    await _progress.setStep(
      itemId: journey.id,
      index: index,
      completed: value,
    );
    await _load();
  }

  Widget _journeyCard(RecoveryJourney journey) {
    final completed = _completed[journey.id] ?? <int>{};
    final count = completed.length.clamp(0, journey.steps.length);

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  journey.title,
                  style: AppTypography.section,
                ),
              ),
              Chip(
                label: Text(
                  journey.faithSensitive ? 'Christian' : 'Secular',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(journey.description, style: AppTypography.muted),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: journey.steps.isEmpty
                ? 0
                : count / journey.steps.length,
          ),
          const SizedBox(height: AppSpacing.md),
          for (var index = 0;
              index < journey.steps.length;
              index++)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: completed.contains(index),
              onChanged: (value) => _toggle(
                journey,
                index,
                value ?? false,
              ),
              title: Text(journey.steps[index]),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () async {
                await _progress.reset(journey.id);
                await _load();
              },
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset journey'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final journeys = RecoveryJourneyRepository.journeys
        .where(
          (journey) =>
              !journey.faithSensitive || _faithEnabled,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Recovery Journeys')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(
                  'Build recovery over several honest steps.',
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Faith-sensitive content appears only when the faith layer is enabled.',
                  style: AppTypography.muted,
                ),
                const SizedBox(height: AppSpacing.lg),
                for (final journey in journeys) ...[
                  _journeyCard(journey),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
    );
  }
}
