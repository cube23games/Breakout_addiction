import 'package:breakout_addiction/features/ai_chat/domain/ai_fair_use_policy.dart';
import 'package:breakout_addiction/features/ai_chat/domain/ai_usage_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('daily period key uses UTC calendar date', () {
    expect(
      AiFairUsePolicy.periodKey(
        DateTime.parse('2026-07-18T23:30:00-04:00'),
      ),
      '2026-07-19',
    );
  });

  test('usage snapshot never reports negative remaining access', () {
    const snapshot = AiUsageSnapshot(
      promptAttempts: 50,
      stoppedAttempts: 2,
      livePrototypeCalls: 48,
      localOrStubReplies: 0,
      lastModeLabel: 'Secure AI Gateway',
      dailyPeriodKey: '2026-07-18',
      dailyRemoteRequests: 45,
      dailyRequestLimit: 40,
    );

    expect(snapshot.remainingToday, 0);
    expect(snapshot.fairUseReached, isTrue);
  });

  test('fair-use policy keeps bounded input and daily requests', () {
    expect(AiFairUsePolicy.dailyRequestLimit, greaterThan(0));
    expect(AiFairUsePolicy.dailyRequestLimit, lessThanOrEqualTo(100));
    expect(AiFairUsePolicy.maxInputCharacters, lessThanOrEqualTo(2000));
  });
}
