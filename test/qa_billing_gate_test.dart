import 'package:breakout_addiction/features/premium/billing/domain/subscription_access_policy.dart';
import 'package:breakout_addiction/features/premium/billing/domain/subscription_lifecycle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('access lifecycle allowlist is explicit', () {
    expect(
      SubscriptionAccessPolicy.lifecycleAllowsAccess(
        SubscriptionLifecycle.active,
      ),
      isTrue,
    );
    expect(
      SubscriptionAccessPolicy.lifecycleAllowsAccess(
        SubscriptionLifecycle.canceledActive,
      ),
      isTrue,
    );
    expect(
      SubscriptionAccessPolicy.lifecycleAllowsAccess(
        SubscriptionLifecycle.gracePeriod,
      ),
      isTrue,
    );
    expect(
      SubscriptionAccessPolicy.lifecycleAllowsAccess(
        SubscriptionLifecycle.pending,
      ),
      isFalse,
    );
    expect(
      SubscriptionAccessPolicy.lifecycleAllowsAccess(
        SubscriptionLifecycle.accountHold,
      ),
      isFalse,
    );
  });
}
