import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import 'delay_check_in_result.dart';

class CompletedDelayContent extends StatelessWidget {
  const CompletedDelayContent({
    required this.result,
    required this.onResultSelected,
    required this.onDelayAgain,
    required this.onOpenBreathing,
    required this.onReviewReasons,
    required this.onOpenSupport,
    required this.onLog,
    required this.onFinish,
    super.key,
  });

  final DelayCheckInResult? result;
  final ValueChanged<DelayCheckInResult> onResultSelected;
  final VoidCallback onDelayAgain;
  final VoidCallback onOpenBreathing;
  final VoidCallback onReviewReasons;
  final VoidCallback onOpenSupport;
  final VoidCallback onLog;
  final VoidCallback onFinish;

  Widget _message({
    required String title,
    required String body,
    required List<Widget> actions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.section),
        const SizedBox(height: AppSpacing.sm),
        Text(body, style: AppTypography.muted),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: actions,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (result) {
      case null:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Countdown is complete',
              style: AppTypography.section,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Did the urge subside?',
              style: AppTypography.body,
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                OutlinedButton.icon(
                  onPressed: () => onResultSelected(
                    DelayCheckInResult.lower,
                  ),
                  icon: const Icon(Icons.trending_down),
                  label: const Text('Lower'),
                ),
                OutlinedButton.icon(
                  onPressed: () => onResultSelected(
                    DelayCheckInResult.same,
                  ),
                  icon: const Icon(Icons.horizontal_rule),
                  label: const Text('About the same'),
                ),
                OutlinedButton.icon(
                  onPressed: () => onResultSelected(
                    DelayCheckInResult.stronger,
                  ),
                  icon: const Icon(Icons.trending_up),
                  label: const Text('Stronger'),
                ),
              ],
            ),
          ],
        );

      case DelayCheckInResult.lower:
        return _message(
          title: 'That space helped',
          body:
              'Notice what made the urge easier to manage. That is useful recovery information.',
          actions: [
            OutlinedButton.icon(
              onPressed: onLog,
              icon: const Icon(Icons.edit_note_outlined),
              label: const Text('Log the win'),
            ),
            OutlinedButton(
              onPressed: onFinish,
              child: const Text('Finish'),
            ),
          ],
        );

      case DelayCheckInResult.same:
        return _message(
          title: 'Stay with the plan',
          body:
              'The urge has not passed yet, but you already interrupted the automatic response.',
          actions: [
            OutlinedButton(
              onPressed: onDelayAgain,
              child: const Text('Delay 3 more'),
            ),
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
          ],
        );

      case DelayCheckInResult.stronger:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Use more support now',
              style: AppTypography.section,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Change locations, put distance between you and the trigger, and contact someone instead of staying isolated.',
              style: AppTypography.muted,
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onOpenSupport,
                icon: const Icon(
                  Icons.support_agent_outlined,
                ),
                label: const Text('Open Support'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                OutlinedButton.icon(
                  onPressed: onOpenBreathing,
                  icon: const Icon(Icons.air_outlined),
                  label: const Text('Breathe now'),
                ),
                OutlinedButton.icon(
                  onPressed: onReviewReasons,
                  icon: const Icon(Icons.favorite_outline),
                  label: const Text('Review my reasons'),
                ),
                OutlinedButton.icon(
                  onPressed: onLog,
                  icon: const Icon(Icons.edit_note_outlined),
                  label: const Text('Log this moment'),
                ),
              ],
            ),
          ],
        );
    }
  }
}
