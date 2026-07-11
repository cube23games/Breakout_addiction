import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/info_card.dart';

class InsightNextActionCard extends StatelessWidget {
  const InsightNextActionCard({
    required this.action,
    super.key,
  });

  final String action;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Next Best Action',
            style: AppTypography.section,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            action,
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}
