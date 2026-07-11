import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/route_names.dart';
import '../../quotes/domain/daily_quote.dart';
import '../data/onboarding_completion_service.dart';
import '../domain/onboarding_state.dart';
import 'widgets/onboarding_navigation_controls.dart';
import 'widgets/onboarding_options.dart';
import 'widgets/onboarding_step_content.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final OnboardingCompletionService _completionService =
      OnboardingCompletionService();

  final TextEditingController _contactNameController =
      TextEditingController();
  final TextEditingController _contactPhoneController =
      TextEditingController();
  final TextEditingController _customGoalController =
      TextEditingController();
  final TextEditingController _customTriggerController =
      TextEditingController();
  final TextEditingController _customRiskController =
      TextEditingController();

  final Set<String> _selectedTriggers = <String>{};
  final Set<String> _selectedRiskSituations = <String>{};

  int _stepIndex = 0;
  bool _saving = false;
  bool _customTriggerEnabled = false;
  bool _customRiskEnabled = false;
  bool _triggersUnknown = false;
  bool _riskTimesUnknown = false;

  String _goal = 'Break the cycle earlier';
  QuoteMode _quoteMode = QuoteMode.recovery;
  String _religion = 'Christian';

  @override
  void dispose() {
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _customGoalController.dispose();
    _customTriggerController.dispose();
    _customRiskController.dispose();
    super.dispose();
  }

  String _effectiveGoal() {
    if (_goal != OnboardingOptions.customGoal) {
      return _goal;
    }

    final custom = _customGoalController.text.trim();
    return custom.isEmpty ? 'My personal reason' : custom;
  }

  List<String> _effectiveTriggers() {
    if (_triggersUnknown) {
      return <String>[];
    }

    final values = _selectedTriggers.toList();
    final custom = _customTriggerController.text.trim();

    if (_customTriggerEnabled && custom.isNotEmpty) {
      values.add(custom);
    }

    return values;
  }

  List<String> _effectiveRiskSituations() {
    if (_riskTimesUnknown) {
      return <String>[];
    }

    final values = _selectedRiskSituations.toList();
    final custom = _customRiskController.text.trim();

    if (_customRiskEnabled && custom.isNotEmpty) {
      values.add(custom);
    }

    return values;
  }

  void _toggleTrigger(String item) {
    setState(() {
      _triggersUnknown = false;

      if (!_selectedTriggers.add(item)) {
        _selectedTriggers.remove(item);
      }
    });
  }

  void _toggleRiskSituation(String item) {
    setState(() {
      _riskTimesUnknown = false;

      if (!_selectedRiskSituations.add(item)) {
        _selectedRiskSituations.remove(item);
      }
    });
  }

  void _setTriggersUnknown(bool value) {
    setState(() {
      _triggersUnknown = value;

      if (value) {
        _selectedTriggers.clear();
        _customTriggerEnabled = false;
      }
    });
  }

  void _setRiskUnknown(bool value) {
    setState(() {
      _riskTimesUnknown = value;

      if (value) {
        _selectedRiskSituations.clear();
        _customRiskEnabled = false;
      }
    });
  }

  Future<void> _finish() async {
    setState(() => _saving = true);

    final state = OnboardingState(
      completed: true,
      primaryGoal: _effectiveGoal(),
      quoteMode: _quoteMode,
      religionPreference: _religion,
      topTriggers: _effectiveTriggers(),
      riskyTimes: _effectiveRiskSituations(),
      triggersUnknown: _triggersUnknown,
      riskTimesUnknown: _riskTimesUnknown,
      trustedContactName: _contactNameController.text.trim(),
      trustedContactPhone:
          _contactPhoneController.text.trim(),
    );

    await _completionService.complete(state);

    if (!mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteNames.home,
      (_) => false,
    );
  }

  Widget _stepContent() {
    return OnboardingStepContent(
      stepIndex: _stepIndex,
      goal: _goal,
      customGoalController: _customGoalController,
      onGoalChanged: (value) {
        setState(() => _goal = value);
      },
      quoteMode: _quoteMode,
      religion: _religion,
      onQuoteModeChanged: (value) {
        setState(() => _quoteMode = value);
      },
      onReligionChanged: (value) {
        setState(() => _religion = value);
      },
      selectedTriggers: _selectedTriggers,
      customTriggerEnabled: _customTriggerEnabled,
      triggersUnknown: _triggersUnknown,
      customTriggerController: _customTriggerController,
      onTriggerToggled: _toggleTrigger,
      onCustomTriggerChanged: (value) {
        setState(() {
          _customTriggerEnabled = value;

          if (value) {
            _triggersUnknown = false;
          }
        });
      },
      onTriggersUnknownChanged: _setTriggersUnknown,
      selectedRiskSituations: _selectedRiskSituations,
      customRiskEnabled: _customRiskEnabled,
      riskTimesUnknown: _riskTimesUnknown,
      customRiskController: _customRiskController,
      onRiskSituationToggled: _toggleRiskSituation,
      onCustomRiskChanged: (value) {
        setState(() {
          _customRiskEnabled = value;

          if (value) {
            _riskTimesUnknown = false;
          }
        });
      },
      onRiskUnknownChanged: _setRiskUnknown,
      contactNameController: _contactNameController,
      contactPhoneController: _contactPhoneController,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lastStep = _stepIndex == 5;

    return Scaffold(
      appBar: AppBar(title: const Text('Get Started')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'Step ${_stepIndex + 1} of 6',
              style: AppTypography.muted,
            ),
            const SizedBox(height: AppSpacing.sm),
            _stepContent(),
            const SizedBox(height: AppSpacing.lg),
            OnboardingNavigationControls(
              showBack: _stepIndex > 0,
              lastStep: lastStep,
              saving: _saving,
              onBack: () {
                setState(() => _stepIndex -= 1);
              },
              onNext: lastStep
                  ? _finish
                  : () {
                      setState(() => _stepIndex += 1);
                    },
            ),
          ],
        ),
      ),
    );
  }
}
