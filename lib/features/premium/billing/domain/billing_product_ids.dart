import '../../domain/premium_plan.dart';

class BillingProductIds {
  const BillingProductIds._();

  static const String plusMonthly = 'breakout_plus_monthly';
  static const String plusAiMonthly = 'breakout_plus_ai_monthly';

  static const Set<String> all = <String>{
    plusMonthly,
    plusAiMonthly,
  };

  static String forPlan(PremiumPlan plan) {
    switch (plan) {
      case PremiumPlan.plus:
        return plusMonthly;
      case PremiumPlan.plusAi:
        return plusAiMonthly;
      case PremiumPlan.none:
        throw ArgumentError('Standard does not have a Play product.');
    }
  }

  static PremiumPlan? planFor(String productId) {
    switch (productId) {
      case plusMonthly:
        return PremiumPlan.plus;
      case plusAiMonthly:
        return PremiumPlan.plusAi;
      default:
        return null;
    }
  }
}
