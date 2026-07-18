import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/info_card.dart';
import '../../domain/premium_feature.dart';
import '../../domain/premium_plan.dart';
import 'premium_badge.dart';

class PremiumFeatureCard extends StatelessWidget {
  final PremiumFeature feature;
  final PremiumPlan activePlan;

  const PremiumFeatureCard({
    super.key,
    required this.feature,
    required this.activePlan,
  });

  String _availabilityLabel() {
    switch (feature.availability) {
      case PremiumFeatureAvailability.available:
        return 'Available';
      case PremiumFeatureAvailability.requiresStoreSetup:
        return 'Requires Play setup';
      case PremiumFeatureAvailability.requiresBackend:
        return 'Requires secure AI service';
    }
  }

  @override
  Widget build(BuildContext context) {
    final included = feature.isIncludedFor(activePlan);

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(feature.title, style: AppTypography.section),
              ),
              PremiumBadge(
                label: feature.requiredPlan == PremiumPlan.none
                    ? 'Free'
                    : feature.requiredPlan.label,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(feature.description, style: AppTypography.muted),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                included ? Icons.check_circle_outline : Icons.lock_outline,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  included
                      ? 'Included in your current tier'
                      : 'Not included in your current tier',
                  style: AppTypography.body,
                ),
              ),
            ],
          ),
          if (feature.availability != PremiumFeatureAvailability.available) ...[
            const SizedBox(height: 6),
            Text(
              _availabilityLabel(),
              style: AppTypography.muted,
            ),
          ],
        ],
      ),
    );
  }
}
