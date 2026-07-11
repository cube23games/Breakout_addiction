import 'package:flutter/material.dart';

import '../data/lock_settings_repository.dart';

class LockSessionController extends ChangeNotifier
    with WidgetsBindingObserver {
  LockSessionController._();

  static final LockSessionController instance =
      LockSessionController._();

  final LockSettingsRepository _repository =
      LockSettingsRepository();

  bool _started = false;
  bool _unlocked = false;
  DateTime? _backgroundedAt;
  Duration _backgroundGrace = Duration.zero;

  bool get isUnlocked => _unlocked;
  Duration get backgroundGrace => _backgroundGrace;

  void start() {
    if (_started) {
      return;
    }

    _started = true;
    WidgetsBinding.instance.addObserver(this);
    refreshSettings();
  }

  void stop() {
    if (!_started) {
      return;
    }

    WidgetsBinding.instance.removeObserver(this);
    _started = false;
    lockNow();
  }

  Future<void> refreshSettings() async {
    final settings = await _repository.getSettings();
    updateGraceMinutes(settings.backgroundGraceMinutes);
  }

  void updateGraceMinutes(int minutes) {
    _backgroundGrace = Duration(minutes: minutes);
  }

  void unlock() {
    _backgroundedAt = null;

    if (_unlocked) {
      return;
    }

    _unlocked = true;
    notifyListeners();
  }

  void lockNow() {
    _backgroundedAt = null;

    if (!_unlocked) {
      return;
    }

    _unlocked = false;
    notifyListeners();
  }

  void _recordBackgrounding() {
    _backgroundedAt ??= DateTime.now();

    if (_backgroundGrace == Duration.zero) {
      lockNow();
    }
  }

  void _handleResume() {
    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;

    if (!_unlocked || backgroundedAt == null) {
      return;
    }

    final elapsed = DateTime.now().difference(backgroundedAt);

    if (elapsed >= _backgroundGrace) {
      lockNow();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _handleResume();
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _recordBackgrounding();
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }
}
