import 'package:breakout_addiction/features/premium/billing/domain/subscription_lifecycle.dart';
import 'package:breakout_addiction/features/premium/billing/domain/verified_entitlement.dart';
import 'package:breakout_addiction/features/premium/domain/premium_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('service access token survives secure entitlement serialization', () {
    final now = DateTime.utc(2026, 7, 18, 12);
    final original = VerifiedEntitlement(
      plan: PremiumPlan.plusAi,
      lifecycle: SubscriptionLifecycle.active,
      productId: 'breakout_plus_ai_monthly',
      purchaseId: 'purchase-1',
      verifiedAt: now,
      expiresAt: now.add(const Duration(days: 30)),
      verificationSource: 'secure-backend',
      serverAcknowledged: true,
      serviceAccessToken: 'opaque-short-lived-token',
      serviceAccessExpiresAt: now.add(const Duration(hours: 12)),
    );

    final restored = VerifiedEntitlement.fromMap(original.toMap());

    expect(restored.plan, PremiumPlan.plusAi);
    expect(restored.serviceAccessToken, 'opaque-short-lived-token');
    expect(restored.hasUsableServiceAccess(now), isTrue);
    expect(
      restored.hasUsableServiceAccess(now.add(const Duration(days: 1))),
      isFalse,
    );
  });
}
