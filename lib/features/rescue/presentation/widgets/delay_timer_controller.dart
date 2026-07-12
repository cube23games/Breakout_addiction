import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../data/delay_session_repository.dart';

class DelayTimerController extends ChangeNotifier
    with WidgetsBindingObserver {
  DelayTimerController({DelaySessionRepository? repository})
      : _repository = repository ?? DelaySessionRepository() {
    WidgetsBinding.instance.addObserver(this);
  }

  final DelaySessionRepository _repository;
  Timer? _timer;
  Duration? _selectedDuration;
  Duration _remaining = Duration.zero;
  DateTime? _deadline;
  bool _completed = false;
  bool _restored = false;

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
    if (selected == null) return Duration.zero;
    final value = selected - _remaining;
    return value.isNegative ? Duration.zero : value;
  }

  String get remainingLabel {
    final totalSeconds = (_remaining.inMilliseconds / 1000).ceil();
    final minutes = totalSeconds ~/ 60;
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> restore() async {
    if (_restored) return;
    _restored = true;

    final snapshot = await _repository.load();
    _selectedDuration = snapshot.selectedDuration;
    _deadline = snapshot.deadline;
    _completed = snapshot.completed;

    final deadline = _deadline;
    if (deadline == null) {
      _remaining = Duration.zero;
      notifyListeners();
      return;
    }

    _remaining = deadline.difference(DateTime.now());
    if (_remaining.inMilliseconds <= 0) {
      _complete();
      return;
    }

    _startTicker();
    notifyListeners();
  }

  Future<void> start(Duration duration) async {
    _timer?.cancel();
    final deadline = DateTime.now().add(duration);

    _selectedDuration = duration;
    _remaining = duration;
    _deadline = deadline;
    _completed = false;

    notifyListeners();
    _startTicker();
    await _repository.saveActive(
      selectedDuration: duration,
      deadline: deadline,
    );
  }

  Future<void> reset() async {
    _timer?.cancel();
    _timer = null;
    _selectedDuration = null;
    _remaining = Duration.zero;
    _deadline = null;
    _completed = false;

    notifyListeners();
    await _repository.clear();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => _sync(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _sync();
  }

  void _sync() {
    final deadline = _deadline;
    if (deadline == null) return;

    final value = deadline.difference(DateTime.now());
    if (value.inMilliseconds <= 0) {
      _complete();
      return;
    }

    _remaining = value;
    notifyListeners();
  }

  void _complete() {
    final selected = _selectedDuration;
    _timer?.cancel();
    _timer = null;
    _deadline = null;
    _remaining = Duration.zero;
    _completed = true;

    if (selected != null) {
      unawaited(_repository.markCompleted(selected));
    }
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }
}
