import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../../core/widgets/primary_button.dart';

class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Get through the next moment.', style: AppTypography.title),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Use Rescue when an urge is active. Use your plan and routines to prepare before pressure rises.',
            style: AppTypography.muted,
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: 'Open Rescue',
            icon: Icons.flash_on_outlined,
            onPressed: () => Navigator.pushNamed(
              context,
              RouteNames.rescue,
            ),
          ),
        ],
      ),
    );
  }
}
