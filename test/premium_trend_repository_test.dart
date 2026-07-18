import 'package:breakout_addiction/features/cycle/domain/cycle_stage.dart';
import 'package:breakout_addiction/features/log/data/cycle_stage_log_repository.dart';
import 'package:breakout_addiction/features/log/data/mood_log_repository.dart';
import 'package:breakout_addiction/features/log/data/recovery_event_repository.dart';
import 'package:breakout_addiction/features/log/domain/cycle_stage_log_entry.dart';
import 'package:breakout_addiction/features/log/domain/mood_entry.dart';
import 'package:breakout_addiction/features/log/domain/recovery_event_entry.dart';
import 'package:breakout_addiction/features/premium_tools/data/premium_trend_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('premium trends separate 30- and 90-day activity', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final now = DateTime.utc(2026, 7, 18, 12);

    await MoodLogRepository().saveEntry(
      MoodEntry(
        timestamp: now.subtract(const Duration(days: 2)),
        moodLabel: 'Tense',
        stress: 8,
        loneliness: 4,
        boredom: 3,
        energy: 4,
        note: '',
      ),
    );
    await CycleStageLogRepository().saveEntry(
      CycleStageLogEntry(
        timestamp: now.subtract(const Duration(days: 3)),
        stage: CycleStage.warningSigns,
        intensity: 7,
        note: '',
      ),
    );

    final events = RecoveryEventRepository();
    await events.saveEntry(
      RecoveryEventEntry(
        timestamp: now.subtract(const Duration(days: 4)),
        type: RecoveryEventType.victory,
        intensity: 6,
        trigger: 'Stress',
        context: '',
        note: '',
      ),
    );
    await events.saveEntry(
      RecoveryEventEntry(
        timestamp: now.subtract(const Duration(days: 45)),
        type: RecoveryEventType.relapse,
        intensity: 8,
        trigger: 'Stress',
        context: '',
        note: '',
      ),
    );
    await events.saveEntry(
      RecoveryEventEntry(
        timestamp: now.subtract(const Duration(days: 70)),
        type: RecoveryEventType.urge,
        intensity: 5,
        trigger: 'Boredom',
        context: '',
        note: '',
      ),
    );

    final summary = await PremiumTrendRepository().buildSummary(now: now);

    expect(summary.victories30, 1);
    expect(summary.slips30, 0);
    expect(summary.slips90, 1);
    expect(summary.urges90, 1);
    expect(summary.moodLogs30, 1);
    expect(summary.stageLogs30, 1);
    expect(summary.topTrigger30, 'Stress');
  });
}
