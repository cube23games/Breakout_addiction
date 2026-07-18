import 'package:breakout_addiction/features/premium/domain/premium_access_policy.dart';
import 'package:breakout_addiction/features/premium/domain/premium_feature_catalog.dart';
import 'package:breakout_addiction/features/premium/domain/premium_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('core rescue features are never paywalled', () {
    final rescue = PremiumFeatureCatalog.byId('rescue');
    expect(rescue.requiredPlan, PremiumPlan.none);
    expect(rescue.neverPaywall, isTrue);

    final decision = PremiumAccessPolicy.evaluate(
      activePlan: PremiumPlan.none,
      feature: rescue,
      integrityAllowsPaidFeatures: false,
    );

    expect(decision.allowed, isTrue);
  });

  test('Plus does not grant Plus AI features', () {
    final aiChat = PremiumFeatureCatalog.byId('ai_chat');
    final decision = PremiumAccessPolicy.evaluate(
      activePlan: PremiumPlan.plus,
      feature: aiChat,
      integrityAllowsPaidFeatures: true,
    );

    expect(decision.allowed, isFalse);
    expect(decision.requiredPlan, PremiumPlan.plusAi);
  });

  test('Plus AI includes Plus and AI features', () {
    final plusFeature = PremiumFeatureCatalog.byId('advanced_insights');
    final aiFeature = PremiumFeatureCatalog.byId('ai_chat');

    expect(PremiumPlan.plusAi.includes(plusFeature.requiredPlan), isTrue);
    expect(PremiumPlan.plusAi.includes(aiFeature.requiredPlan), isTrue);
  });

  test('catalog identifiers are unique', () {
    final ids = PremiumFeatureCatalog.all.map((feature) => feature.id).toList();
    expect(ids.toSet().length, ids.length);
  });
}
