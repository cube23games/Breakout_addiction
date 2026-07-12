import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/info_card.dart';
import '../../domain/accountability_scope.dart';
import '../../domain/accountability_summary_item.dart';

class AccountabilitySummaryItemCard extends StatelessWidget {
  const AccountabilitySummaryItemCard({
    required this.item,
    super.key,
  });

  final AccountabilitySummaryItem item;

  IconData get _icon {
    switch (item.scope) {
      case AccountabilityScope.progress:
        return Icons.insights_outlined;
      case AccountabilityScope.recentUrges:
        return Icons.bolt_outlined;
      case AccountabilityScope.relapseEvents:
        return Icons.warning_amber_outlined;
      case AccountabilityScope.victoryEvents:
        return Icons.emoji_events_outlined;
      case AccountabilityScope.moodTrends:
        return Icons.mood_outlined;
      case AccountabilityScope.riskWindows:
        return Icons.schedule_outlined;
      case AccountabilityScope.recoveryPlan:
        return Icons.fact_check_outlined;
      case AccountabilityScope.reasonsToStop:
        return Icons.favorite_outline;
      case AccountabilityScope.supportNeeded:
        return Icons.support_agent_outlined;
    }
  }

  String get _statusLabel {
    switch (item.status) {
      case AccountabilityDataStatus.available:
        return 'Shared data';
      case AccountabilityDataStatus.empty:
        return 'No data yet';
      case AccountabilityDataStatus.unavailable:
        return 'Unavailable';
    }
  }

  Color _statusColor(ColorScheme colors) {
    switch (item.status) {
      case AccountabilityDataStatus.available:
        return colors.primaryContainer;
      case AccountabilityDataStatus.empty:
        return colors.surfaceContainerHighest;
      case AccountabilityDataStatus.unavailable:
        return colors.errorContainer;
    }
  }

  Color _statusTextColor(ColorScheme colors) {
    switch (item.status) {
      case AccountabilityDataStatus.available:
        return colors.onPrimaryContainer;
      case AccountabilityDataStatus.empty:
        return colors.onSurfaceVariant;
      case AccountabilityDataStatus.unavailable:
        return colors.onErrorContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_icon, color: colors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  item.scope.label,
                  style: AppTypography.section,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(colors),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusLabel,
                  style: AppTypography.muted.copyWith(
                    color: _statusTextColor(colors),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(item.summary, style: AppTypography.body),
          if (item.details.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            for (final detail in item.details) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•', style: AppTypography.body),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      detail,
                      style: AppTypography.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ],
        ],
      ),
    );
  }
}
