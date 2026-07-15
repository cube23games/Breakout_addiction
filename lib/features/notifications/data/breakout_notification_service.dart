import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class DelayNotificationScheduleOutcome {
  const DelayNotificationScheduleOutcome({
    required this.scheduled,
    required this.exact,
  });

  final bool scheduled;
  final bool exact;
}

class BreakoutNotificationService {
  BreakoutNotificationService._();

  static final BreakoutNotificationService instance =
      BreakoutNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  Future<void>? _initializationFuture;

  static const String notificationIconName = 'ic_stat_breakout';
  static const String fallbackNotificationIconName =
      '@mipmap/ic_launcher';

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

    final existing = _initializationFuture;
    if (existing != null) {
      await existing;
      return;
    }

    final future = _initialize();
    _initializationFuture = future;

    try {
      await future;
    } finally {
      if (!_initialized) {
        _initializationFuture = null;
      }
    }
  }

  Future<void> _initialize() async {
    tz.initializeTimeZones();

    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (_) {
      // Keep timezone defaults if device lookup fails.
    }

    // Keep startup independent from the custom status-bar icon. The
    // branded icon is applied explicitly when a notification is created.
    await _initializePlugin(fallbackNotificationIconName);

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

  Future<void> _initializePlugin(String iconName) async {
    final androidSettings =
        AndroidInitializationSettings(iconName);
    const darwinSettings = DarwinInitializationSettings();

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(settings: initSettings);
  }

  Future<bool> notificationsEnabled() async {
    await initialize();

    if (defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.areNotificationsEnabled() ?? true;
  }

  Future<bool> requestPermissions() async {
    await initialize();

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

        final alreadyEnabled =
            await android?.areNotificationsEnabled();
        if (alreadyEnabled == true) {
          return true;
        }

        final requested =
            await android?.requestNotificationsPermission();

        // Android settings can be changed outside the app. Always read
        // the live OS state again instead of trusting an older denial.
        final refreshed =
            await android?.areNotificationsEnabled();
        return refreshed ?? requested ?? false;

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

  Future<bool> requestExactAlarmPermission() async {
    await initialize();

    if (defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    try {
      return await android?.requestExactAlarmsPermission() ?? false;
    } catch (_) {
      return false;
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

  NotificationDetails _details({
    required String channelId,
    required String channelName,
    required String channelDescription,
    required bool useCustomIcon,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        icon: useCustomIcon ? notificationIconName : null,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
    );
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

    final scheduledDate =
        nextOccurrence(hour: hour, minute: minute);

    try {
      await _scheduleDailyReminder(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        payload: payload,
        useCustomIcon: true,
      );
    } catch (_) {
      await _scheduleDailyReminder(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        payload: payload,
        useCustomIcon: false,
      );
    }
  }

  Future<void> _scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required String payload,
    required bool useCustomIcon,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: _details(
        channelId: riskChannelId,
        channelName: riskChannelName,
        channelDescription: riskChannelDescription,
        useCustomIcon: useCustomIcon,
      ),
      payload: payload,
      androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<DelayNotificationScheduleOutcome>
      scheduleDelayCompletion(
    DateTime deadline, {
    required bool preferExact,
  }) async {
    await initialize();

    final scheduledDate = tz.TZDateTime.from(deadline, tz.local);

    if (!scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      return const DelayNotificationScheduleOutcome(
        scheduled: false,
        exact: false,
      );
    }

    // Remove any stale completion alert before registering a new one.
    await cancelDelayCompletion();

    final scheduleModes = preferExact
        ? const <AndroidScheduleMode>[
            AndroidScheduleMode.exactAllowWhileIdle,
            AndroidScheduleMode.inexactAllowWhileIdle,
          ]
        : const <AndroidScheduleMode>[
            AndroidScheduleMode.inexactAllowWhileIdle,
          ];

    for (final scheduleMode in scheduleModes) {
      try {
        await _scheduleDelayCompletionWithIconFallback(
          scheduledDate,
          scheduleMode: scheduleMode,
        );

        final pending = await _delayCompletionPending();

        if (pending) {
          return DelayNotificationScheduleOutcome(
            scheduled: true,
            exact:
                scheduleMode ==
                AndroidScheduleMode.exactAllowWhileIdle,
          );
        }
      } catch (_) {
        // Exact scheduling can fail if Android revokes precise-alarm access.
        // The next pass through the loop uses the honest inexact fallback.
      }

      await cancelDelayCompletion();
    }

    return const DelayNotificationScheduleOutcome(
      scheduled: false,
      exact: false,
    );
  }

  Future<void> _scheduleDelayCompletionWithIconFallback(
    tz.TZDateTime scheduledDate, {
    required AndroidScheduleMode scheduleMode,
  }) async {
    try {
      await _scheduleDelayCompletion(
        scheduledDate,
        scheduleMode: scheduleMode,
        useCustomIcon: true,
      );
    } catch (_) {
      await _plugin.cancel(
        id: delayCompletionNotificationId,
      );

      await _scheduleDelayCompletion(
        scheduledDate,
        scheduleMode: scheduleMode,
        useCustomIcon: false,
      );
    }
  }

  Future<bool> _delayCompletionPending() async {
    final pending = await _plugin.pendingNotificationRequests();

    return pending.any(
      (request) => request.id == delayCompletionNotificationId,
    );
  }

  Future<void> _scheduleDelayCompletion(
    tz.TZDateTime scheduledDate, {
    required AndroidScheduleMode scheduleMode,
    required bool useCustomIcon,
  }) async {
    await _plugin.zonedSchedule(
      id: delayCompletionNotificationId,
      title: 'Countdown is complete',
      body: 'Take a breath and check in: did the urge subside?',
      scheduledDate: scheduledDate,
      notificationDetails: _details(
        channelId: delayChannelId,
        channelName: delayChannelName,
        channelDescription: delayChannelDescription,
        useCustomIcon: useCustomIcon,
      ),
      payload: 'rescue_delay_complete',
      androidScheduleMode: scheduleMode,
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
