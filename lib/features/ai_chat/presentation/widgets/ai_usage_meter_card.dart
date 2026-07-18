import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/info_card.dart';
import '../../domain/ai_usage_snapshot.dart';

class AiUsageMeterCard extends StatelessWidget {
  final AiUsageSnapshot snapshot;
  final VoidCallback? onReset;

  const AiUsageMeterCard({
    super.key,
    required this.snapshot,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI fair-use status', style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${snapshot.remainingToday} of '
            '${snapshot.dailyRequestLimit} app-side requests remain today.',
            style: AppTypography.body,
          ),
          const SizedBox(height: 4),
          const Text(
            'The secure backend also applies abuse and cost controls. Local Rescue, plans, and guidance never depend on AI availability.',
            style: AppTypography.muted,
          ),
          const SizedBox(height: 4),
          Text(
            'Stopped unsafe or unavailable requests: '
            '${snapshot.stoppedAttempts}',
            style: AppTypography.muted,
          ),
          const SizedBox(height: 4),
          Text(
            'Last mode: ${snapshot.lastModeLabel}',
            style: AppTypography.muted,
          ),
          if (onReset != null) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh_outlined),
                label: const Text('Reset QA usage meter'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
