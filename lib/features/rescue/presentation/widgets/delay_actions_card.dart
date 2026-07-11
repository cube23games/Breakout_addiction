import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../log/domain/recovery_event_save_result.dart';
import '../../../quotes/data/quote_preferences_repository.dart';
import '../../../quotes/domain/daily_quote.dart';
import 'active_delay_content.dart';
import 'completed_delay_content.dart';
import 'delay_check_in_result.dart';
import 'delay_duration_selector.dart';
import 'delay_guidance_content.dart';
import 'delay_timer_controller.dart';

class DelayActionsCard extends StatefulWidget {
  const DelayActionsCard({
    required this.onOpenBreathing,
    required this.onReviewReasons,
    super.key,
  });

  final VoidCallback onOpenBreathing;
  final VoidCallback onReviewReasons;

  @override
  State<DelayActionsCard> createState() =>
      _DelayActionsCardState();
}

class _DelayActionsCardState extends State<DelayActionsCard> {
  late final DelayTimerController _timerController;

  QuoteMode _quoteMode = QuoteMode.recovery;
  DelayCheckInResult? _checkInResult;

  @override
  void initState() {
    super.initState();

    _timerController = DelayTimerController()
      ..addListener(_handleTimerChange);

    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final mode = await QuotePreferencesRepository().getMode();

    if (mounted) {
      setState(() => _quoteMode = mode);
    }
  }

  void _handleTimerChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _startDelay(int minutes) {
    _checkInResult = null;
    _timerController.start(Duration(minutes: minutes));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF13212C),
        content: Text(
          'Good call. Delay for $minutes minutes and stay with the plan.',
        ),
      ),
    );
  }

  void _resetDelay() {
    _checkInResult = null;
    _timerController.reset();
  }

  void _openSupport() {
    Navigator.pushNamed(context, RouteNames.support);
  }

  void _openLog() {
    _openRecoveryEventLog();
  }

  Future<void> _openRecoveryEventLog() async {
    final result = await Navigator.pushNamed(
      context,
      RouteNames.recoveryEventLog,
    );

    if (!mounted ||
        result is! RecoveryEventSaveResult) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
      ),
    );
  }

  @override
  void dispose() {
    _timerController
      ..removeListener(_handleTimerChange)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deadline = _timerController.deadline;
    final selectedDuration = _timerController.selectedDuration;

    final title = _timerController.isActive
        ? 'Delay Active'
        : _timerController.completed
            ? 'Delay Complete'
            : 'Delay Actions';

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Choose a delay. The active choice stays highlighted.',
            style: AppTypography.muted,
          ),
          const SizedBox(height: AppSpacing.md),
          DelayDurationSelector(
            selectedMinutes: selectedDuration?.inMinutes,
            onSelected: _startDelay,
          ),
          if (_timerController.isActive &&
              deadline != null &&
              selectedDuration != null) ...[
            const SizedBox(height: AppSpacing.md),
            ActiveDelayContent(
              deadline: deadline,
              totalDuration: selectedDuration,
              remainingLabel: _timerController.remainingLabel,
              guidance: DelayGuidanceContent.tipFor(
                _quoteMode,
                _timerController.elapsed,
              ),
              onOpenBreathing: widget.onOpenBreathing,
              onReviewReasons: widget.onReviewReasons,
              onOpenSupport: _openSupport,
              onCancel: _resetDelay,
            ),
          ] else if (_timerController.completed) ...[
            const SizedBox(height: AppSpacing.md),
            CompletedDelayContent(
              result: _checkInResult,
              onResultSelected: (result) {
                setState(() => _checkInResult = result);
              },
              onDelayAgain: () => _startDelay(3),
              onOpenBreathing: widget.onOpenBreathing,
              onReviewReasons: widget.onReviewReasons,
              onOpenSupport: _openSupport,
              onLog: _openLog,
              onFinish: _resetDelay,
            ),
          ],
        ],
      ),
    );
  }
}
