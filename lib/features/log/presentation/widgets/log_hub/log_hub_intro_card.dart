import 'package:flutter/material.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_typography.dart';
import '../../../../../core/widgets/info_card.dart';

class LogHubIntroCard extends StatelessWidget {
  const LogHubIntroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Private Logs',
            style: AppTypography.section,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Use different log types to understand '
            'mood, cycle stage, urges, slips, and '
            'wins more clearly.',
            style: AppTypography.muted,
          ),
        ],
      ),
    );
  }
}
