import 'recovery_event_entry.dart';

class RecoveryEventSaveResult {
  const RecoveryEventSaveResult({
    required this.entry,
    required this.updated,
  });

  final RecoveryEventEntry entry;
  final bool updated;

  String get message {
    final action = updated ? 'Updated' : 'Saved';
    return '$action ${entry.type.label.toLowerCase()} log.';
  }
}
