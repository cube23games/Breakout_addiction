import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/info_card.dart';

class OnboardingWelcomeStep extends StatelessWidget {
  const OnboardingWelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Breakout Addiction',
            style: AppTypography.title,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'This short setup helps tailor support, privacy, and daily focus to you.',
            style: AppTypography.muted,
          ),
        ],
      ),
    );
  }
}
