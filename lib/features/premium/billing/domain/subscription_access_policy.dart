import '../../domain/premium_plan.dart';
import 'subscription_lifecycle.dart';
import 'verified_entitlement.dart';

class SubscriptionAccessPolicy {
  const SubscriptionAccessPolicy._();

  static const Duration maxOfflineVerificationAge = Duration(days: 3);

  static bool lifecycleAllowsAccess(
    SubscriptionLifecycle lifecycle,
  ) {
    return lifecycle == SubscriptionLifecycle.active ||
        lifecycle == SubscriptionLifecycle.canceledActive ||
        lifecycle == SubscriptionLifecycle.gracePeriod;
  }

  static PremiumPlan effectivePlan(
    VerifiedEntitlement? entitlement, {
    required DateTime now,
  }) {
    if (entitlement == null ||
        !lifecycleAllowsAccess(entitlement.lifecycle)) {
      return PremiumPlan.none;
    }

    final expiration = entitlement.expiresAt;
    if (expiration != null && !expiration.isAfter(now.toUtc())) {
      return PremiumPlan.none;
    }

    final age = now.toUtc().difference(entitlement.verifiedAt);
    if (age > maxOfflineVerificationAge) {
      return PremiumPlan.none;
    }

    return entitlement.plan;
  }
}
