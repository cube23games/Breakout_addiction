import 'dart:async';

import 'package:flutter/material.dart';

import 'app/breakout_app.dart';
import 'features/notifications/data/breakout_notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BreakoutApp());

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_initializeNotificationsSafely());
  });
}

Future<void> _initializeNotificationsSafely() async {
  try {
    await BreakoutNotificationService.instance.initialize();
  } catch (error, stackTrace) {
    debugPrint('Notification initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}
