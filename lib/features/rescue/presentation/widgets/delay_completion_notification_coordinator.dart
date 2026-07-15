import 'package:shared_preferences/shared_preferences.dart';

import '../../../notifications/data/breakout_notification_service.dart';

class DelayCompletionNotificationResult {
  const DelayCompletionNotificationResult({
    required this.permissionGranted,
    required this.scheduled,
    required this.exact,
  });

  final bool permissionGranted;
  final bool scheduled;
  final bool exact;
}

class DelayCompletionNotificationCoordinator {
  static const String _exactAlarmPromptedKey =
      'rescue_exact_alarm_prompted_v1';

  final BreakoutNotificationService _service =
      BreakoutNotificationService.instance;

  Future<DelayCompletionNotificationResult> schedule(
    DateTime deadline,
  ) async {
    try {
      final permissionGranted =
          await _service.requestPermissions();

      if (!permissionGranted) {
        return const DelayCompletionNotificationResult(
          permissionGranted: false,
          scheduled: false,
          exact: false,
        );
      }

      var shouldRequestExactAlarmAccess = false;

      try {
        final preferences = await SharedPreferences.getInstance();
        final alreadyPrompted =
            preferences.getBool(_exactAlarmPromptedKey) ?? false;

        if (!alreadyPrompted) {
          shouldRequestExactAlarmAccess = await preferences.setBool(
            _exactAlarmPromptedKey,
            true,
          );
        }
      } catch (_) {
        // Preference failure must not block or repeatedly interrupt Rescue.
      }

      final preferExact = shouldRequestExactAlarmAccess
          ? await _service.requestExactAlarmPermission()
          : true;

      final outcome = await _service.scheduleDelayCompletion(
        deadline,
        preferExact: preferExact,
      );

      return DelayCompletionNotificationResult(
        permissionGranted: true,
        scheduled: outcome.scheduled,
        exact: outcome.exact,
      );
    } catch (_) {
      return const DelayCompletionNotificationResult(
        permissionGranted: true,
        scheduled: false,
        exact: false,
      );
    }
  }

  Future<void> cancel() async {
    try {
      await _service.cancelDelayCompletion();
    } catch (_) {
      // The countdown itself must still cancel if notifications fail.
    }
  }
}
