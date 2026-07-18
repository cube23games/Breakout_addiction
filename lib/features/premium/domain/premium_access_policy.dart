import 'premium_feature.dart';
import 'premium_plan.dart';

class PremiumAccessDecision {
  final bool allowed;
  final PremiumPlan requiredPlan;
  final String message;

  const PremiumAccessDecision({
    required this.allowed,
    required this.requiredPlan,
    required this.message,
  });
}

class PremiumAccessPolicy {
  const PremiumAccessPolicy._();

  static PremiumAccessDecision evaluate({
    required PremiumPlan activePlan,
    required PremiumFeature feature,
    required bool integrityAllowsPaidFeatures,
  }) {
    if (feature.neverPaywall) {
      return PremiumAccessDecision(
        allowed: true,
        requiredPlan: PremiumPlan.none,
        message: 'This core recovery feature stays available.',
      );
    }

    if (!integrityAllowsPaidFeatures) {
      return PremiumAccessDecision(
        allowed: false,
        requiredPlan: feature.requiredPlan,
        message:
            'Paid features are temporarily unavailable because app integrity could not be confirmed.',
      );
    }

    if (!activePlan.includes(feature.requiredPlan)) {
      return PremiumAccessDecision(
        allowed: false,
        requiredPlan: feature.requiredPlan,
        message: '${feature.requiredPlan.label} is required.',
      );
    }

    return PremiumAccessDecision(
      allowed: true,
      requiredPlan: feature.requiredPlan,
      message: 'Included with ${activePlan.label}.',
    );
  }
}
