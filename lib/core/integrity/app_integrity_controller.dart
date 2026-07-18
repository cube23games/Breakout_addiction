import 'package:flutter/foundation.dart';

import 'app_integrity_service.dart';
import 'app_integrity_status.dart';

class AppIntegrityController {
  AppIntegrityController._();

  static final AppIntegrityController instance =
      AppIntegrityController._();

  final ValueNotifier<AppIntegrityStatus> status =
      ValueNotifier<AppIntegrityStatus>(
    const AppIntegrityStatus.checking(),
  );

  final AppIntegrityService _service = AppIntegrityService();
  Future<AppIntegrityStatus>? _inFlight;

  Future<AppIntegrityStatus> start() => ensureChecked();

  Future<AppIntegrityStatus> ensureChecked() {
    if (status.value.state != AppIntegrityState.checking) {
      return Future<AppIntegrityStatus>.value(status.value);
    }

    final active = _inFlight;
    if (active != null) {
      return active;
    }

    final future = _service.verify().then((result) {
      status.value = result;
      return result;
    }).catchError((Object _) {
      const fallback = AppIntegrityStatus(
        state: AppIntegrityState.unavailable,
        message: 'Breakout Addiction could not verify this installation.',
      );
      status.value = fallback;
      return fallback;
    });

    _inFlight = future;
    return future;
  }
}
