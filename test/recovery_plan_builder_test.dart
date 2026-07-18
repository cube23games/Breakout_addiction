import 'package:breakout_addiction/features/support/domain/recovery_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy recovery plan data remains readable', () {
    final plan = RecoveryPlan.fromMap(<String, dynamic>{
      'riskyPlaces': <String>['Bedroom'],
      'firstAction': 'Leave the room',
      'secondAction': 'Text support',
      'groundingAction': 'Walk',
      'supportPerson': 'Alex',
      'fallbackPlan': 'Open Rescue',
    });

    expect(plan.firstAction, 'Leave the room');
    expect(plan.warningSigns, isEmpty);
    expect(plan.reviewDate, isNull);
    expect(plan.hasBasicPlan, isTrue);
  });

  test('advanced recovery plan reports meaningful readiness', () {
    final plan = RecoveryPlan(
      riskyPlaces: const <String>['Bedroom'],
      firstAction: 'Leave the room',
      secondAction: 'Text support',
      groundingAction: 'Walk',
      supportPerson: 'Alex',
      fallbackPlan: 'Open Rescue',
      warningSigns: const <String>['Hiding phone'],
      triggers: const <String>['Stress'],
      highRiskTimes: const <String>['Late night'],
      postSlipPlan: 'Change location and log honestly',
      morningCommitment: 'Read one reason',
      eveningCommitment: 'Charge phone outside room',
      reviewDate: DateTime.utc(2026, 8, 1),
    );

    expect(plan.completedSections, plan.totalSections);
    expect(plan.completion, 1);
    expect(plan.hasAdvancedPlan, isTrue);
    expect(plan.toMap()['warningSigns'], <String>['Hiding phone']);
  });
}
