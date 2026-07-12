import 'package:shared_preferences/shared_preferences.dart';

class DelaySessionSnapshot {
  final Duration? selectedDuration;
  final DateTime? deadline;
  final bool completed;

  const DelaySessionSnapshot({
    required this.selectedDuration,
    required this.deadline,
    required this.completed,
  });

  bool get hasRestorableState =>
      selectedDuration != null && (deadline != null || completed);
}

class DelaySessionRepository {
  static const String _durationKey =
      'rescue_delay_selected_duration_ms';
  static const String _deadlineKey =
      'rescue_delay_deadline_ms';
  static const String _completedKey =
      'rescue_delay_completed';

  Future<DelaySessionSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();
    final durationMs = prefs.getInt(_durationKey);
    final deadlineMs = prefs.getInt(_deadlineKey);
    final completed = prefs.getBool(_completedKey) ?? false;

    if (durationMs == null || durationMs <= 0) {
      await clear();
      return const DelaySessionSnapshot(
        selectedDuration: null,
        deadline: null,
        completed: false,
      );
    }

    final selectedDuration =
        Duration(milliseconds: durationMs);

    if (completed) {
      return DelaySessionSnapshot(
        selectedDuration: selectedDuration,
        deadline: null,
        completed: true,
      );
    }

    if (deadlineMs == null) {
      await clear();
      return const DelaySessionSnapshot(
        selectedDuration: null,
        deadline: null,
        completed: false,
      );
    }

    final deadline =
        DateTime.fromMillisecondsSinceEpoch(deadlineMs);

    if (!deadline.isAfter(DateTime.now())) {
      await markCompleted(selectedDuration);
      return DelaySessionSnapshot(
        selectedDuration: selectedDuration,
        deadline: null,
        completed: true,
      );
    }

    return DelaySessionSnapshot(
      selectedDuration: selectedDuration,
      deadline: deadline,
      completed: false,
    );
  }

  Future<bool> hasRestorableSession() async {
    final snapshot = await load();
    return snapshot.hasRestorableState;
  }

  Future<void> saveActive({
    required Duration selectedDuration,
    required DateTime deadline,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _durationKey,
      selectedDuration.inMilliseconds,
    );
    await prefs.setInt(
      _deadlineKey,
      deadline.millisecondsSinceEpoch,
    );
    await prefs.setBool(_completedKey, false);
  }

  Future<void> markCompleted(
    Duration selectedDuration,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _durationKey,
      selectedDuration.inMilliseconds,
    );
    await prefs.remove(_deadlineKey);
    await prefs.setBool(_completedKey, true);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_durationKey);
    await prefs.remove(_deadlineKey);
    await prefs.remove(_completedKey);
  }
}
