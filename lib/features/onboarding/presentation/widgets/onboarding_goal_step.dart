import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/info_card.dart';
import 'onboarding_options.dart';

class OnboardingGoalStep extends StatelessWidget {
  const OnboardingGoalStep({
    required this.goal,
    required this.customController,
    required this.onGoalChanged,
    super.key,
  });

  final String goal;
  final TextEditingController customController;
  final ValueChanged<String> onGoalChanged;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What is your main reason for changing?',
            style: AppTypography.section,
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            initialValue: goal,
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: OnboardingOptions.goals
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                onGoalChanged(value);
              }
            },
          ),
          if (goal == OnboardingOptions.customGoal) ...[
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: customController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'My reason',
                hintText: 'Write what matters to you...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
