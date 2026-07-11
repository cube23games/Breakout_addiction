import 'dart:async';

import 'package:flutter/foundation.dart';

class BreathingSessionController extends ChangeNotifier {
  static const int inhaleSeconds = 4;
  static const int holdSeconds = 4;
  static const int exhaleSeconds = 6;
  static const int cycleSeconds =
      inhaleSeconds + holdSeconds + exhaleSeconds;
  static const int totalCycles = 3;
  static const int totalSeconds =
      cycleSeconds * totalCycles;

  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _running = false;
  bool _completed = false;

  int get elapsedSeconds => _elapsedSeconds;
  bool get running => _running;
  bool get completed => _completed;

  int get phaseSecond =>
      _elapsedSeconds % cycleSeconds;

  int get currentCycle {
    if (_elapsedSeconds >= totalSeconds) {
      return totalCycles;
    }

    return (_elapsedSeconds ~/ cycleSeconds) + 1;
  }

  String get phaseLabel {
    if (_completed) {
      return 'Done';
    }

    if (!_running) {
      return 'Ready';
    }

    if (phaseSecond < inhaleSeconds) {
      return 'Inhale';
    }

    if (phaseSecond < inhaleSeconds + holdSeconds) {
      return 'Hold';
    }

    return 'Exhale';
  }

  String get instruction {
    switch (phaseLabel) {
      case 'Inhale':
        return 'Breathe in slowly.';
      case 'Hold':
        return 'Hold gently.';
      case 'Exhale':
        return 'Let it out slowly.';
      case 'Done':
        return 'Good. You slowed the moment down.';
      default:
        return 'Tap the orb and follow its pace.';
    }
  }

  int get secondsLeftInPhase {
    if (!_running) {
      return 0;
    }

    if (phaseSecond < inhaleSeconds) {
      return inhaleSeconds - phaseSecond;
    }

    if (phaseSecond < inhaleSeconds + holdSeconds) {
      return inhaleSeconds + holdSeconds - phaseSecond;
    }

    return cycleSeconds - phaseSecond;
  }

  void start() {
    _timer?.cancel();

    _elapsedSeconds = 0;
    _running = true;
    _completed = false;
    notifyListeners();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      _handleTick,
    );
  }

  void _handleTick(Timer timer) {
    if (_elapsedSeconds >= totalSeconds - 1) {
      timer.cancel();
      _timer = null;
      _elapsedSeconds = totalSeconds;
      _running = false;
      _completed = true;
      notifyListeners();
      return;
    }

    _elapsedSeconds += 1;
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _elapsedSeconds = 0;
    _running = false;
    _completed = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
