import '../../../notifications/data/breakout_notification_service.dart';

class DelayCompletionNotificationResult {
  const DelayCompletionNotificationResult({
    required this.permissionGranted,
    required this.scheduled,
  });

  final bool permissionGranted;
  final bool scheduled;
}

class DelayCompletionNotificationCoordinator {
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
        );
      }

      await _service.scheduleDelayCompletion(deadline);
      return const DelayCompletionNotificationResult(
        permissionGranted: true,
        scheduled: true,
      );
    } catch (_) {
      return const DelayCompletionNotificationResult(
        permissionGranted: true,
        scheduled: false,
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
