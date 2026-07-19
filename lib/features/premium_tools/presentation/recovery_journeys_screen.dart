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

class _RecoveryJourneysScreenState extends State<RecoveryJourneysScreen> {
  final PremiumProgressRepository _progress = PremiumProgressRepository();
  final FeatureControlSettingsRepository _settings =
      FeatureControlSettingsRepository();
  final Map<String, int> _completedCount = <String, int>{};
  final Map<String, bool> _completedToday = <String, bool>{};
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
      _completedCount[journey.id] =
          await _progress.contiguousCompletedCount(
        journey.id,
        maxCount: journey.steps.length,
      );
      _completedToday[journey.id] =
          await _progress.completedToday(journey.id);
    }
    if (mounted) {
      setState(() {
        _faithEnabled = settings.faithLayerEnabled;
        _loading = false;
      });
    }
  }

  Future<void> _completeNextDay(RecoveryJourney journey) async {
    final completed = await _progress.completeNextDay(
      itemId: journey.id,
      maxCount: journey.steps.length,
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

  Future<void> _reset(RecoveryJourney journey) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reset this journey?'),
            content: const Text(
              'This clears the completed days for this journey on this device.',
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
    await _progress.reset(journey.id);
    await _load();
  }

  Widget _dayTile({
    required RecoveryJourney journey,
    required int index,
    required int completedCount,
  }) {
    final completed = index < completedCount;
    final active = index == completedCount;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        completed
            ? Icons.check_circle
            : active
                ? Icons.today_outlined
                : Icons.lock_outline,
      ),
      title: Text(journey.steps[index]),
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

  Widget _journeyCard(RecoveryJourney journey) {
    final count = (_completedCount[journey.id] ?? 0)
        .clamp(0, journey.steps.length);
    final completedToday = _completedToday[journey.id] ?? false;
    final finished = count >= journey.steps.length;

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(journey.title, style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          Text(journey.description, style: AppTypography.muted),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                journey.faithSensitive
                    ? Icons.church_outlined
                    : Icons.self_improvement_outlined,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                journey.faithSensitive
                    ? 'Christian recovery journey'
                    : 'Secular recovery journey',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: journey.steps.isEmpty ? 0 : count / journey.steps.length,
          ),
          const SizedBox(height: 6),
          Text(
            '$count of ${journey.steps.length} days completed',
            style: AppTypography.muted,
          ),
          const SizedBox(height: AppSpacing.md),
          if (finished)
            const Text('Journey complete.', style: AppTypography.body)
          else ...[
            Text(
              completedToday
                  ? 'Day ${count + 1} unlocks tomorrow.'
                  : 'Day ${count + 1} is ready.',
              style: AppTypography.body,
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed:
                    completedToday ? null : () => _completeNextDay(journey),
                icon: Icon(
                  completedToday ? Icons.lock_clock : Icons.check_circle_outline,
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
            title: const Text('View day-by-day journey'),
            children: [
              for (var index = 0; index < journey.steps.length; index++)
                _dayTile(
                  journey: journey,
                  index: index,
                  completedCount: count,
                ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _reset(journey),
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
          (journey) => !journey.faithSensitive || _faithEnabled,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Recovery Journeys')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text('Move through one day at a time.',
                    style: AppTypography.title),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Complete today’s recovery work before the next day unlocks.',
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
