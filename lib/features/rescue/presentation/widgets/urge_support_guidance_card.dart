import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/info_card.dart';

class UrgeSupportGuidanceCard extends StatelessWidget {
  const UrgeSupportGuidanceCard({
    required this.intensity,
    required this.onChooseDelay,
    required this.onBreathe,
    required this.onReviewReasons,
    required this.onOpenSupport,
    super.key,
  });

  final int intensity;
  final VoidCallback onChooseDelay;
  final VoidCallback onBreathe;
  final VoidCallback onReviewReasons;
  final VoidCallback onOpenSupport;

  bool get _needsStrongerSupport => intensity >= 9;

  @override
  Widget build(BuildContext context) {
    final accent = _needsStrongerSupport
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    final title = _needsStrongerSupport
        ? 'This is an intense moment'
        : 'This urge is running high';

    final message = _needsStrongerSupport
        ? 'Put some distance between you and the trigger. Change locations, set the phone down, and use support instead of handling this alone.'
        : 'Create space before making your next decision. A short delay, slower breathing, or reviewing your reasons can help interrupt the pattern.';

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.14),
                ),
                child: Icon(
                  _needsStrongerSupport
                      ? Icons.support_agent_outlined
                      : Icons.shield_outlined,
                  color: accent,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.section),
                    const SizedBox(height: 4),
                    Text(
                      'Intensity $intensity/10',
                      style: AppTypography.muted.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(message, style: AppTypography.body),
          const SizedBox(height: AppSpacing.md),
          if (_needsStrongerSupport) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onOpenSupport,
                icon: const Icon(Icons.support_agent_outlined),
                label: const Text('Open Support'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              OutlinedButton.icon(
                onPressed: onChooseDelay,
                icon: const Icon(Icons.timer_outlined),
                label: const Text('Choose a delay'),
              ),
              OutlinedButton.icon(
                onPressed: onBreathe,
                icon: const Icon(Icons.air_outlined),
                label: const Text('Breathe now'),
              ),
              OutlinedButton.icon(
                onPressed: onReviewReasons,
                icon: const Icon(Icons.favorite_outline),
                label: const Text('Review my reasons'),
              ),
              if (!_needsStrongerSupport)
                OutlinedButton.icon(
                  onPressed: onOpenSupport,
                  icon: const Icon(Icons.support_agent_outlined),
                  label: const Text('Open Support'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
