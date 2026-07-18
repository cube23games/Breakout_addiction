import 'package:breakout_addiction/features/accountability/data/accountability_center_repository.dart';
import 'package:breakout_addiction/features/accountability/data/progress_scorecard_repository.dart';
import 'package:breakout_addiction/features/accountability/domain/accountability_check_in_plan.dart';
import 'package:breakout_addiction/features/log/data/mood_log_repository.dart';
import 'package:breakout_addiction/features/log/data/recovery_event_repository.dart';
import 'package:breakout_addiction/features/log/domain/mood_entry.dart';
import 'package:breakout_addiction/features/log/domain/recovery_event_entry.dart';
import 'package:breakout_addiction/features/support/data/recovery_plan_repository.dart';
import 'package:breakout_addiction/features/support/domain/recovery_plan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('accountability check-in preparation persists privately', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final repository = AccountabilityCenterRepository();
    final plan = AccountabilityCheckInPlan(
      partnerName: 'Alex',
      nextCheckIn: DateTime.utc(2026, 7, 25),
      currentGoal: 'Use Rescue before isolation',
      winToShare: 'Left the room',
      riskToDiscuss: 'Late night',
      supportRequest: 'Text me at 10 PM',
      nextCommitment: 'Charge phone outside bedroom',
    );

    await repository.savePlan(plan);
    final restored = await repository.getPlan();

    expect(restored.partnerName, 'Alex');
    expect(restored.hasUsefulPreparation, isTrue);
    expect(restored.nextCommitment, contains('Charge phone'));
  });

  test('progress scorecard rewards engagement without subtracting for slips', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final now = DateTime(2026, 7, 18, 12);

    await RecoveryPlanRepository().savePlan(
      const RecoveryPlan(
        riskyPlaces: <String>['Bedroom'],
        firstAction: 'Leave the room',
        secondAction: 'Text support',
        groundingAction: 'Walk',
        supportPerson: 'Alex',
        fallbackPlan: 'Open Rescue',
      ),
    );
    await MoodLogRepository().saveEntry(
      MoodEntry(
        timestamp: now.subtract(const Duration(hours: 3)),
        moodLabel: 'Tense',
        stress: 7,
        loneliness: 4,
        boredom: 3,
        energy: 4,
        note: '',
      ),
    );
    final events = RecoveryEventRepository();
    await events.saveEntry(
      RecoveryEventEntry(
        timestamp: now.subtract(const Duration(hours: 2)),
        type: RecoveryEventType.victory,
        intensity: 6,
        trigger: 'Stress',
        context: '',
        note: '',
      ),
    );
    await events.saveEntry(
      RecoveryEventEntry(
        timestamp: now.subtract(const Duration(hours: 1)),
        type: RecoveryEventType.relapse,
        intensity: 8,
        trigger: 'Stress',
        context: '',
        note: '',
      ),
    );

    final scorecard = await ProgressScorecardRepository().build(now: now);

    expect(scorecard.victories7, 1);
    expect(scorecard.slips7, 1);
    expect(scorecard.checkIns7, 1);
    expect(scorecard.engagementScore, greaterThan(0));
    expect(scorecard.scoreMeaning, contains('not a measure of worth'));
  });
}
