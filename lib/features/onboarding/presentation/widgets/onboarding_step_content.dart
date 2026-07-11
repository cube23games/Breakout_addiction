import 'package:flutter/material.dart';

import '../../../quotes/domain/daily_quote.dart';
import 'onboarding_contact_step.dart';
import 'onboarding_goal_step.dart';
import 'onboarding_preferences_step.dart';
import 'onboarding_risk_step.dart';
import 'onboarding_trigger_step.dart';
import 'onboarding_welcome_step.dart';

class OnboardingStepContent extends StatelessWidget {
  const OnboardingStepContent({
    required this.stepIndex,
    required this.goal,
    required this.customGoalController,
    required this.onGoalChanged,
    required this.quoteMode,
    required this.religion,
    required this.onQuoteModeChanged,
    required this.onReligionChanged,
    required this.selectedTriggers,
    required this.customTriggerEnabled,
    required this.triggersUnknown,
    required this.customTriggerController,
    required this.onTriggerToggled,
    required this.onCustomTriggerChanged,
    required this.onTriggersUnknownChanged,
    required this.selectedRiskSituations,
    required this.customRiskEnabled,
    required this.riskTimesUnknown,
    required this.customRiskController,
    required this.onRiskSituationToggled,
    required this.onCustomRiskChanged,
    required this.onRiskUnknownChanged,
    required this.contactNameController,
    required this.contactPhoneController,
    super.key,
  });

  final int stepIndex;

  final String goal;
  final TextEditingController customGoalController;
  final ValueChanged<String> onGoalChanged;

  final QuoteMode quoteMode;
  final String religion;
  final ValueChanged<QuoteMode> onQuoteModeChanged;
  final ValueChanged<String> onReligionChanged;

  final Set<String> selectedTriggers;
  final bool customTriggerEnabled;
  final bool triggersUnknown;
  final TextEditingController customTriggerController;
  final ValueChanged<String> onTriggerToggled;
  final ValueChanged<bool> onCustomTriggerChanged;
  final ValueChanged<bool> onTriggersUnknownChanged;

  final Set<String> selectedRiskSituations;
  final bool customRiskEnabled;
  final bool riskTimesUnknown;
  final TextEditingController customRiskController;
  final ValueChanged<String> onRiskSituationToggled;
  final ValueChanged<bool> onCustomRiskChanged;
  final ValueChanged<bool> onRiskUnknownChanged;

  final TextEditingController contactNameController;
  final TextEditingController contactPhoneController;

  @override
  Widget build(BuildContext context) {
    switch (stepIndex) {
      case 0:
        return const OnboardingWelcomeStep();

      case 1:
        return OnboardingGoalStep(
          goal: goal,
          customController: customGoalController,
          onGoalChanged: onGoalChanged,
        );

      case 2:
        return OnboardingPreferencesStep(
          quoteMode: quoteMode,
          religion: religion,
          onQuoteModeChanged: onQuoteModeChanged,
          onReligionChanged: onReligionChanged,
        );

      case 3:
        return OnboardingTriggerStep(
          selected: selectedTriggers,
          customEnabled: customTriggerEnabled,
          unknown: triggersUnknown,
          customController: customTriggerController,
          onPresetToggled: onTriggerToggled,
          onCustomChanged: onCustomTriggerChanged,
          onUnknownChanged: onTriggersUnknownChanged,
        );

      case 4:
        return OnboardingRiskStep(
          selected: selectedRiskSituations,
          customEnabled: customRiskEnabled,
          unknown: riskTimesUnknown,
          customController: customRiskController,
          onPresetToggled: onRiskSituationToggled,
          onCustomChanged: onCustomRiskChanged,
          onUnknownChanged: onRiskUnknownChanged,
        );

      case 5:
        return OnboardingContactStep(
          nameController: contactNameController,
          phoneController: contactPhoneController,
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
