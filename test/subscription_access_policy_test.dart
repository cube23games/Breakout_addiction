import 'package:breakout_addiction/features/premium/billing/domain/subscription_access_policy.dart';
import 'package:breakout_addiction/features/premium/billing/domain/subscription_lifecycle.dart';
import 'package:breakout_addiction/features/premium/billing/domain/verified_entitlement.dart';
import 'package:breakout_addiction/features/premium/domain/premium_plan.dart';
import 'package:flutter_test/flutter_test.dart';

VerifiedEntitlement entitlement({
  required SubscriptionLifecycle lifecycle,
  DateTime? verifiedAt,
  DateTime? expiresAt,
}) {
  return VerifiedEntitlement(
    plan: PremiumPlan.plusAi,
    lifecycle: lifecycle,
    productId: 'breakout_plus_ai_monthly',
    verifiedAt: verifiedAt ?? DateTime.utc(2026, 7, 18),
    expiresAt: expiresAt,
    verificationSource: 'test',
    serverAcknowledged: true,
  );
}

void main() {
  final now = DateTime.utc(2026, 7, 19);

  test('active, canceled-active, and grace retain access', () {
    for (final lifecycle in <SubscriptionLifecycle>[
      SubscriptionLifecycle.active,
      SubscriptionLifecycle.canceledActive,
      SubscriptionLifecycle.gracePeriod,
    ]) {
      expect(
        SubscriptionAccessPolicy.effectivePlan(
          entitlement(lifecycle: lifecycle),
          now: now,
        ),
        PremiumPlan.plusAi,
      );
    }
  });

  test('pending, hold, expired, and revoked do not unlock', () {
    for (final lifecycle in <SubscriptionLifecycle>[
      SubscriptionLifecycle.pending,
      SubscriptionLifecycle.accountHold,
      SubscriptionLifecycle.expired,
      SubscriptionLifecycle.revoked,
    ]) {
      expect(
        SubscriptionAccessPolicy.effectivePlan(
          entitlement(lifecycle: lifecycle),
          now: now,
        ),
        PremiumPlan.none,
      );
    }
  });

  test('expired entitlement does not unlock', () {
    expect(
      SubscriptionAccessPolicy.effectivePlan(
        entitlement(
          lifecycle: SubscriptionLifecycle.active,
          expiresAt: DateTime.utc(2026, 7, 18),
        ),
        now: now,
      ),
      PremiumPlan.none,
    );
  });

  test('stale offline verification fails closed', () {
    expect(
      SubscriptionAccessPolicy.effectivePlan(
        entitlement(
          lifecycle: SubscriptionLifecycle.active,
          verifiedAt: DateTime.utc(2026, 7, 1),
        ),
        now: now,
      ),
      PremiumPlan.none,
    );
  });
}
