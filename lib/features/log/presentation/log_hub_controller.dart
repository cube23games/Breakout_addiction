import '../data/cycle_stage_log_repository.dart';
import '../data/recovery_event_repository.dart';
import '../domain/cycle_stage_log_entry.dart';
import '../domain/recovery_event_entry.dart';

class LogHubController {
  LogHubController() {
    reload();
  }

  final CycleStageLogRepository _stageRepository =
      CycleStageLogRepository();

  final RecoveryEventRepository _eventRepository =
      RecoveryEventRepository();

  late Future<List<CycleStageLogEntry>>
      stageEntriesFuture;

  late Future<List<RecoveryEventEntry>>
      eventEntriesFuture;

  void reload() {
    stageEntriesFuture =
        _stageRepository.getEntries();

    eventEntriesFuture =
        _eventRepository.getEntries();
  }

  Future<void> deleteEvent(
    RecoveryEventEntry entry,
  ) {
    return _eventRepository.deleteEntry(entry);
  }

  Future<void> restoreEvent(
    RecoveryEventEntry entry,
  ) {
    return _eventRepository.saveEntry(entry);
  }
}
