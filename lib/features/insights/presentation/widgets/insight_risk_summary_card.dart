import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/info_card.dart';
import '../../domain/insight_summary.dart';

class InsightRiskSummaryCard extends StatelessWidget {
  const InsightRiskSummaryCard({
    required this.summary,
    super.key,
  });

  final InsightSummary summary;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Risk Summary',
            style: AppTypography.section,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.shield_outlined,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  summary.recentRiskLabel,
                  style: AppTypography.title,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            summary.summaryLine,
            style: AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            summary.recommendationLine,
            style: AppTypography.muted,
          ),
        ],
      ),
    );
  }
}
