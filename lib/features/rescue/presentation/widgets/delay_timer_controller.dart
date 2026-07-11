import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class DelayTimerController extends ChangeNotifier
    with WidgetsBindingObserver {
  DelayTimerController() {
    WidgetsBinding.instance.addObserver(this);
  }

  Timer? _timer;
  Duration? _selectedDuration;
  Duration _remaining = Duration.zero;
  DateTime? _deadline;
  bool _completed = false;

  Duration? get selectedDuration => _selectedDuration;
  Duration get remaining => _remaining;
  DateTime? get deadline => _deadline;
  bool get completed => _completed;

  bool get isActive =>
      _deadline != null &&
      !_completed &&
      _remaining.inMilliseconds > 0;

  Duration get elapsed {
    final selected = _selectedDuration;

    if (selected == null) {
      return Duration.zero;
    }

    final value = selected - _remaining;
    return value.isNegative ? Duration.zero : value;
  }

  String get remainingLabel {
    final totalSeconds = (_remaining.inMilliseconds / 1000).ceil();
    final minutes = totalSeconds ~/ 60;
    final seconds =
        (totalSeconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  void start(Duration duration) {
    _timer?.cancel();

    _selectedDuration = duration;
    _remaining = duration;
    _deadline = DateTime.now().add(duration);
    _completed = false;

    notifyListeners();

    _timer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => _sync(),
    );
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _selectedDuration = null;
    _remaining = Duration.zero;
    _deadline = null;
    _completed = false;

    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _sync();
    }
  }

  void _sync() {
    final currentDeadline = _deadline;

    if (currentDeadline == null) {
      return;
    }

    final value = currentDeadline.difference(DateTime.now());

    if (value.inMilliseconds <= 0) {
      _timer?.cancel();
      _timer = null;
      _deadline = null;
      _remaining = Duration.zero;
      _completed = true;

      notifyListeners();
      return;
    }

    _remaining = value;
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }
}
