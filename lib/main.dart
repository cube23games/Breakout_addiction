import 'dart:async';

import 'package:flutter/material.dart';

import 'app/breakout_app.dart';
import 'core/integrity/app_integrity_controller.dart';
import 'features/notifications/data/breakout_notification_service.dart';
import 'features/widget/data/widget_snapshot_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BreakoutApp());

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(AppIntegrityController.instance.start());
    unawaited(_initializeNotificationsSafely());
    unawaited(WidgetSnapshotRepository().syncToHomeScreenWidget());
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
