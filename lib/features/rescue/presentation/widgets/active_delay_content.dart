import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import 'animated_delay_ring.dart';

class ActiveDelayContent extends StatelessWidget {
  const ActiveDelayContent({
    required this.deadline,
    required this.totalDuration,
    required this.remainingLabel,
    required this.guidance,
    required this.onOpenBreathing,
    required this.onReviewReasons,
    required this.onOpenSupport,
    required this.onCancel,
    super.key,
  });

  final DateTime deadline;
  final Duration totalDuration;
  final String remainingLabel;
  final String guidance;
  final VoidCallback onOpenBreathing;
  final VoidCallback onReviewReasons;
  final VoidCallback onOpenSupport;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: AnimatedDelayRing(
            deadline: deadline,
            totalDuration: totalDuration,
            remainingLabel: remainingLabel,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'You are creating space between the urge and the action.',
          style: AppTypography.muted,
        ),
        const SizedBox(height: AppSpacing.md),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: Container(
            key: ValueKey<String>(guidance),
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Try this now', style: AppTypography.section),
                const SizedBox(height: AppSpacing.xs),
                Text(guidance, style: AppTypography.body),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            OutlinedButton.icon(
              onPressed: onOpenBreathing,
              icon: const Icon(Icons.air_outlined),
              label: const Text('Breathe'),
            ),
            OutlinedButton.icon(
              onPressed: onReviewReasons,
              icon: const Icon(Icons.favorite_outline),
              label: const Text('My reasons'),
            ),
            OutlinedButton.icon(
              onPressed: onOpenSupport,
              icon: const Icon(Icons.support_agent_outlined),
              label: const Text('Support'),
            ),
            TextButton(
              onPressed: onCancel,
              child: const Text('Cancel timer'),
            ),
          ],
        ),
      ],
    );
  }
}
