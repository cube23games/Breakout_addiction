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
import 'delay_completion_notification_coordinator.dart';
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
  State<DelayActionsCard> createState() => _DelayActionsCardState();
}

class _DelayActionsCardState extends State<DelayActionsCard> {
  late final DelayTimerController _timerController;
  final DelayCompletionNotificationCoordinator _notifications =
      DelayCompletionNotificationCoordinator();
  QuoteMode _quoteMode = QuoteMode.recovery;
  DelayCheckInResult? _checkInResult;
  bool _restoring = true;
  @override
  void initState() {
    super.initState();
    _timerController = DelayTimerController()
      ..addListener(_handleTimerChange);
    _restore();
    _loadPreferences();
  }
  Future<void> _restore() async {
    await _timerController.restore();
    if (mounted) setState(() => _restoring = false);
  }

  Future<void> _loadPreferences() async {
    final mode = await QuotePreferencesRepository().getMode();
    if (mounted) setState(() => _quoteMode = mode);
  }

  void _handleTimerChange() {
    if (mounted) setState(() {});
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF13212C),
        content: Text(message),
      ),
    );
  }

  Future<void> _startDelay(int minutes) async {
    _checkInResult = null;
    await _timerController.start(Duration(minutes: minutes));
    final deadline = _timerController.deadline;
    final result = deadline == null
        ? const DelayCompletionNotificationResult(
            permissionGranted: false,
            scheduled: false,
          )
        : await _notifications.schedule(deadline);
    if (!mounted) return;

    final message = result.scheduled
        ? '$minutes-minute countdown started. '
            'Breakout will notify you when it ends.'
        : result.permissionGranted
            ? '$minutes-minute countdown started, but the completion '
                'alert could not be scheduled.'
            : '$minutes-minute countdown started. Notifications are off, '
                'so keep Breakout open or enable them in Android Settings.';
    _showMessage(message);
  }

  Future<void> _cancelDelay() async {
    _checkInResult = null;
    await _notifications.cancel();
    await _timerController.reset();
    if (mounted) _showMessage('Countdown canceled.');
  }

  Future<void> _finishDelay() async {
    await _notifications.cancel();
    await _timerController.reset();
  }
  Future<void> _openRecoveryEventLog() async {
    final result = await Navigator.pushNamed(
      context,
      RouteNames.recoveryEventLog,
    );
    if (!mounted || result is! RecoveryEventSaveResult) return;
    _showMessage(result.message);
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
            ? 'Countdown Complete'
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
          if (_restoring)
            const Center(child: CircularProgressIndicator())
          else ...[
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
                onOpenSupport: () => Navigator.pushNamed(
                  context,
                  RouteNames.support,
                ),
                onCancel: _cancelDelay,
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
                onOpenSupport: () => Navigator.pushNamed(
                  context,
                  RouteNames.support,
                ),
                onLog: _openRecoveryEventLog,
                onFinish: _finishDelay,
              ),
            ],
          ],
        ],
      ),
    );
  }
}
