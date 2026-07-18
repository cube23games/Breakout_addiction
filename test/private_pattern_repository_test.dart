import 'package:breakout_addiction/features/cycle/domain/cycle_stage.dart';
import 'package:breakout_addiction/features/log/data/cycle_stage_log_repository.dart';
import 'package:breakout_addiction/features/log/data/recovery_event_repository.dart';
import 'package:breakout_addiction/features/log/domain/cycle_stage_log_entry.dart';
import 'package:breakout_addiction/features/log/domain/recovery_event_entry.dart';
import 'package:breakout_addiction/features/premium_tools/data/private_pattern_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('private pattern engine finds time, trigger, and pre-slip signal', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final now = DateTime.utc(2026, 7, 18, 20);

    final events = RecoveryEventRepository();
    await events.saveEntry(
      RecoveryEventEntry(
        timestamp: now.subtract(const Duration(days: 1, hours: 1)),
        type: RecoveryEventType.relapse,
        intensity: 8,
        trigger: 'Stress',
        reason: 'Isolation',
        context: '',
        note: '',
      ),
    );
    await events.saveEntry(
      RecoveryEventEntry(
        timestamp: now.subtract(const Duration(days: 8, hours: 1)),
        type: RecoveryEventType.urge,
        intensity: 7,
        trigger: 'Stress',
        reason: 'Isolation',
        context: '',
        note: '',
      ),
    );
    await events.saveEntry(
      RecoveryEventEntry(
        timestamp: now.subtract(const Duration(days: 2, hours: 1)),
        type: RecoveryEventType.victory,
        intensity: 6,
        trigger: 'Stress',
        reason: 'Left the room',
        context: '',
        note: '',
      ),
    );
    await CycleStageLogRepository().saveEntry(
      CycleStageLogEntry(
        timestamp: now.subtract(const Duration(days: 1, hours: 6)),
        stage: CycleStage.warningSigns,
        intensity: 8,
        note: '',
      ),
    );

    final summary = await PrivatePatternRepository().build(now: now);

    expect(summary.topTrigger, 'Stress');
    expect(summary.triggerPair, 'Stress + Isolation');
    expect(summary.preSlipSignal, contains('Warning Signs'));
    expect(summary.effectiveInterruption, contains('Left the room'));
    expect(summary.weeklySummary, contains('This week'));
  });
}
