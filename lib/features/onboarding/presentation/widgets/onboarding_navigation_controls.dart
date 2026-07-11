import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';

class OnboardingNavigationControls extends StatelessWidget {
  const OnboardingNavigationControls({
    required this.showBack,
    required this.lastStep,
    required this.saving,
    required this.onBack,
    required this.onNext,
    super.key,
  });

  final bool showBack;
  final bool lastStep;
  final bool saving;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
            ),
          ),
        if (showBack)
          const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: PrimaryButton(
            label: lastStep
                ? saving
                    ? 'Saving...'
                    : 'Finish Setup'
                : 'Next',
            icon: lastStep
                ? Icons.check_circle_outline
                : Icons.arrow_forward,
            onPressed: saving ? () {} : onNext,
          ),
        ),
      ],
    );
  }
}
