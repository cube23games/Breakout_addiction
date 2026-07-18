import 'package:breakout_addiction/features/premium/billing/domain/billing_product_ids.dart';
import 'package:breakout_addiction/features/premium/domain/premium_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('paid tiers map to stable Play product identifiers', () {
    expect(
      BillingProductIds.forPlan(PremiumPlan.plus),
      BillingProductIds.plusMonthly,
    );
    expect(
      BillingProductIds.forPlan(PremiumPlan.plusAi),
      BillingProductIds.plusAiMonthly,
    );
    expect(
      BillingProductIds.planFor(BillingProductIds.plusMonthly),
      PremiumPlan.plus,
    );
    expect(
      BillingProductIds.planFor(BillingProductIds.plusAiMonthly),
      PremiumPlan.plusAi,
    );
    expect(BillingProductIds.all.length, 2);
  });

  test('Standard has no Play product', () {
    expect(
      () => BillingProductIds.forPlan(PremiumPlan.none),
      throwsArgumentError,
    );
  });
}
