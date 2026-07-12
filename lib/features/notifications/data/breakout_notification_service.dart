import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class BreakoutNotificationService {
  BreakoutNotificationService._();

  static final BreakoutNotificationService instance =
      BreakoutNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const String riskChannelId = 'breakout_risk_windows';
  static const String riskChannelName = 'Risk Window Reminders';
  static const String riskChannelDescription =
      'Proactive reminders before high-risk windows begin.';

  static const String delayChannelId = 'breakout_rescue_delay';
  static const String delayChannelName = 'Rescue Countdown';
  static const String delayChannelDescription =
      'Alerts when a Rescue countdown is complete.';
  static const int delayCompletionNotificationId = 55001;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz.initializeTimeZones();

    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (_) {
      // Keep timezone defaults if device lookup fails.
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(settings: initSettings);

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        riskChannelId,
        riskChannelName,
        description: riskChannelDescription,
        importance: Importance.high,
      ),
    );
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        delayChannelId,
        delayChannelName,
        description: delayChannelDescription,
        importance: Importance.high,
      ),
    );

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    await initialize();

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        return granted ?? true;
      case TargetPlatform.iOS:
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        return granted ?? false;
      case TargetPlatform.macOS:
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        return granted ?? false;
      default:
        return true;
    }
  }

  tz.TZDateTime nextOccurrence({
    required int hour,
    required int minute,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String payload,
  }) async {
    await initialize();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        riskChannelId,
        riskChannelName,
        channelDescription: riskChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: nextOccurrence(hour: hour, minute: minute),
      notificationDetails: details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleDelayCompletion(DateTime deadline) async {
    await initialize();

    final scheduledDate = tz.TZDateTime.from(deadline, tz.local);
    if (!scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      return;
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        delayChannelId,
        delayChannelName,
        channelDescription: delayChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: delayCompletionNotificationId,
      title: 'Countdown is complete',
      body: 'Take a breath and check in: did the urge subside?',
      scheduledDate: scheduledDate,
      notificationDetails: details,
      payload: 'rescue_delay_complete',
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelDelayCompletion() async {
    await cancel(delayCompletionNotificationId);
  }

  Future<void> cancel(int id) async {
    await initialize();
    await _plugin.cancel(id: id);
  }
}
