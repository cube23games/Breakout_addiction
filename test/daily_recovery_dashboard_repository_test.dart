import 'package:breakout_addiction/features/log/data/mood_log_repository.dart';
import 'package:breakout_addiction/features/log/data/recovery_event_repository.dart';
import 'package:breakout_addiction/features/log/domain/mood_entry.dart';
import 'package:breakout_addiction/features/log/domain/recovery_event_entry.dart';
import 'package:breakout_addiction/features/premium_tools/data/daily_recovery_dashboard_repository.dart';
import 'package:breakout_addiction/features/risk/data/risk_window_repository.dart';
import 'package:breakout_addiction/features/risk/domain/risk_window.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('daily dashboard combines local risk, plan, and weekly activity', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final now = DateTime(2026, 7, 18, 22, 30);

    await MoodLogRepository().saveEntry(
      MoodEntry(
        timestamp: now.subtract(const Duration(hours: 3)),
        moodLabel: 'Tense',
        stress: 9,
        loneliness: 7,
        boredom: 5,
        energy: 3,
        note: '',
      ),
    );
    await RecoveryEventRepository().saveEntry(
      RecoveryEventEntry(
        timestamp: now.subtract(const Duration(hours: 2)),
        type: RecoveryEventType.urge,
        intensity: 8,
        trigger: 'Stress',
        context: '',
        note: '',
      ),
    );
    await RiskWindowRepository().saveRiskWindows(
      const <RiskWindow>[
        RiskWindow(
          id: 'night',
          label: 'Late night',
          startHour: 22,
          startMinute: 0,
          endHour: 23,
          endMinute: 30,
          isEnabled: true,
        ),
      ],
    );

    final dashboard =
        await DailyRecoveryDashboardRepository().build(now: now);

    expect(dashboard.riskScore, greaterThanOrEqualTo(40));
    expect(dashboard.riskLabel, isNot('Steady'));
    expect(dashboard.topTrigger, 'Stress');
    expect(dashboard.nextRiskWindow, contains('active now'));
    expect(dashboard.recommendedRoutineId, 'risk_window_prep');
    expect(dashboard.weeklyUrges, 1);
    expect(dashboard.weeklyCheckIns, 1);
  });
}
