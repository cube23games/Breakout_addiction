import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/info_card.dart';

class InsightMoodAveragesCard extends StatelessWidget {
  const InsightMoodAveragesCard({
    required this.averageStress,
    required this.averageLoneliness,
    required this.averageBoredom,
    super.key,
  });

  final double averageStress;
  final double averageLoneliness;
  final double averageBoredom;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mood Pressure Averages',
            style: AppTypography.section,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Stress: '
            '${averageStress.toStringAsFixed(1)}/10',
            style: AppTypography.body,
          ),
          const SizedBox(height: 6),
          Text(
            'Loneliness: '
            '${averageLoneliness.toStringAsFixed(1)}/10',
            style: AppTypography.body,
          ),
          const SizedBox(height: 6),
          Text(
            'Boredom: '
            '${averageBoredom.toStringAsFixed(1)}/10',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}
