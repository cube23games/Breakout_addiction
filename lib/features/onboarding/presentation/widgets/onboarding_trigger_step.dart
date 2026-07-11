import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/info_card.dart';
import 'onboarding_options.dart';

class OnboardingTriggerStep extends StatelessWidget {
  const OnboardingTriggerStep({
    required this.selected,
    required this.customEnabled,
    required this.unknown,
    required this.customController,
    required this.onPresetToggled,
    required this.onCustomChanged,
    required this.onUnknownChanged,
    super.key,
  });

  final Set<String> selected;
  final bool customEnabled;
  final bool unknown;
  final TextEditingController customController;
  final ValueChanged<String> onPresetToggled;
  final ValueChanged<bool> onCustomChanged;
  final ValueChanged<bool> onUnknownChanged;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What tends to trigger you?',
            style: AppTypography.section,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Choose any that fit. You can use your own words or leave this unknown for now.',
            style: AppTypography.muted,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in OnboardingOptions.triggers)
                FilterChip(
                  selected: selected.contains(item),
                  label: Text(item),
                  onSelected: (_) => onPresetToggled(item),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                selected: customEnabled,
                label: const Text(OnboardingOptions.customTrigger),
                onSelected: onCustomChanged,
              ),
              FilterChip(
                selected: unknown,
                label: const Text(OnboardingOptions.unknown),
                onSelected: onUnknownChanged,
              ),
            ],
          ),
          if (customEnabled) ...[
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: customController,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'My trigger',
                hintText: 'Describe it in your own words...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          if (unknown) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'That is completely okay. Breakout can help you notice patterns as you log real moments over time.',
              style: AppTypography.muted,
            ),
          ],
        ],
      ),
    );
  }
}
