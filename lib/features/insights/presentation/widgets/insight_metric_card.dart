import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/info_card.dart';

class InsightMetricCard extends StatelessWidget {
  const InsightMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.section,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.title,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTypography.muted,
          ),
        ],
      ),
    );
  }
}
