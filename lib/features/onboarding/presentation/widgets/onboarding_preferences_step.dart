import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../quotes/domain/daily_quote.dart';
import 'onboarding_options.dart';

class OnboardingPreferencesStep extends StatelessWidget {
  const OnboardingPreferencesStep({
    required this.quoteMode,
    required this.religion,
    required this.onQuoteModeChanged,
    required this.onReligionChanged,
    super.key,
  });

  final QuoteMode quoteMode;
  final String religion;
  final ValueChanged<QuoteMode> onQuoteModeChanged;
  final ValueChanged<String> onReligionChanged;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose your daily focus style',
            style: AppTypography.section,
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<QuoteMode>(
            initialValue: quoteMode,
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: QuoteMode.values
                .map(
                  (mode) => DropdownMenuItem<QuoteMode>(
                    value: mode,
                    child: Text(
                      OnboardingOptions.quoteModeLabel(mode),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                onQuoteModeChanged(value);
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: religion,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Faith / Religion',
              border: OutlineInputBorder(),
            ),
            items: OnboardingOptions.religions
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                onReligionChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
