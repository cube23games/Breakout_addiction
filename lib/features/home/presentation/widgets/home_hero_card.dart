import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/privacy/neutral_labels.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../privacy/data/privacy_label_repository.dart';

class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = PrivacyLabelRepository();

    return FutureBuilder<bool>(
      future: repository.isNeutralModeEnabled(),
      builder: (context, snapshot) {
        final neutralMode = snapshot.data ?? true;

        return InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Break the cycle earlier.',
                style: AppTypography.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'The goal is not perfection. Recognize '
                'the pattern sooner and interrupt it faster.',
                style: AppTypography.muted,
              ),
              const SizedBox(height: AppSpacing.md),
              const Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                children: [
                  _HeroMetadata(
                    icon: Icons.lock_outline,
                    label: 'Private by design',
                  ),
                  _HeroMetadata(
                    icon: Icons.bolt_outlined,
                    label: 'Built for action',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: NeutralLabels.rescuePrimary(
                  neutralMode,
                ),
                icon: Icons.health_and_safety_outlined,
                onPressed: () => Navigator.pushNamed(
                  context,
                  RouteNames.rescue,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    RouteNames.cycle,
                  ),
                  icon: const Icon(
                    Icons.donut_large_outlined,
                  ),
                  label: Text(
                    NeutralLabels.cycleWheelTitle(
                      neutralMode,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroMetadata extends StatelessWidget {
  const _HeroMetadata({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.muted,
        ),
      ],
    );
  }
}
