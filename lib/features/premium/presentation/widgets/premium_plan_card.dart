import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/info_card.dart';
import '../../domain/premium_feature_catalog.dart';
import '../../domain/premium_plan.dart';
import 'premium_badge.dart';

class PremiumPlanCard extends StatelessWidget {
  final PremiumPlan plan;
  final PremiumPlan activePlan;
  final String? priceLabel;
  final VoidCallback? onPressed;
  final String actionLabel;

  const PremiumPlanCard({
    super.key,
    required this.plan,
    required this.activePlan,
    required this.actionLabel,
    this.priceLabel,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final features = PremiumFeatureCatalog.exactlyFor(plan);
    final active = activePlan == plan;

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(plan.label, style: AppTypography.title)),
              if (active) const PremiumBadge(label: 'Current'),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(plan.subtitle, style: AppTypography.muted),
          if (priceLabel != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(priceLabel!, style: AppTypography.section),
          ],
          const SizedBox(height: AppSpacing.md),
          for (final feature in features.take(6)) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(feature.title)),
              ],
            ),
            const SizedBox(height: 6),
          ],
          if (onPressed != null) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onPressed,
                child: Text(actionLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
