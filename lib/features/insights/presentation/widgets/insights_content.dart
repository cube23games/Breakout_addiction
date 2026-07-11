import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../domain/insight_summary.dart';
import 'insight_event_summary_grid.dart';
import 'insight_metric_card.dart';
import 'insight_mood_averages_card.dart';
import 'insight_next_action_card.dart';
import 'insight_risk_summary_card.dart';

class InsightsContent extends StatelessWidget {
  const InsightsContent({
    required this.summary,
    super.key,
  });

  final InsightSummary summary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const Text(
          'Insights',
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Patterns become easier to interrupt '
          'when they are easier to read.',
          style: AppTypography.muted,
        ),
        const SizedBox(height: AppSpacing.lg),
        InsightRiskSummaryCard(summary: summary),
        const SizedBox(height: AppSpacing.md),
        InsightEventSummaryGrid(
          urgeCount: summary.urgeCount,
          relapseCount: summary.relapseCount,
          victoryCount: summary.victoryCount,
        ),
        const SizedBox(height: AppSpacing.md),
        InsightMetricCard(
          title: 'Top Recent Stage',
          value: summary.topStageTitle,
          subtitle:
              'Where the cycle most often appears '
              'in your logs.',
        ),
        const SizedBox(height: AppSpacing.md),
        InsightMetricCard(
          title: 'Most Common Mood',
          value: summary.mostCommonMoodLabel,
          subtitle:
              'The mood label you log most often.',
        ),
        const SizedBox(height: AppSpacing.md),
        InsightMetricCard(
          title: 'Strongest Pressure Driver',
          value: summary.strongestPressureDriver,
          subtitle:
              'The heaviest average pressure in '
              'recent mood logs.',
        ),
        const SizedBox(height: AppSpacing.md),
        InsightMoodAveragesCard(
          averageStress: summary.averageStress,
          averageLoneliness:
              summary.averageLoneliness,
          averageBoredom: summary.averageBoredom,
        ),
        const SizedBox(height: AppSpacing.md),
        InsightNextActionCard(
          action: summary.nextBestAction,
        ),
      ],
    );
  }
}
