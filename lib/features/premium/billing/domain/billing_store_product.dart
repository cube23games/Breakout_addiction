import '../../domain/premium_plan.dart';

class BillingStoreProduct {
  final String id;
  final PremiumPlan plan;
  final String title;
  final String description;
  final String localizedPrice;
  final double rawPrice;
  final String currencyCode;

  const BillingStoreProduct({
    required this.id,
    required this.plan,
    required this.title,
    required this.description,
    required this.localizedPrice,
    required this.rawPrice,
    required this.currencyCode,
  });
}
