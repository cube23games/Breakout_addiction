import 'premium_plan.dart';

enum PremiumFeatureCategory {
  safety,
  insight,
  planning,
  guidance,
  learning,
  accountability,
  reporting,
  personalization,
  artificialIntelligence,
}

extension PremiumFeatureCategoryX on PremiumFeatureCategory {
  String get label {
    switch (this) {
      case PremiumFeatureCategory.safety:
        return 'Safety and core recovery';
      case PremiumFeatureCategory.insight:
        return 'Insights and patterns';
      case PremiumFeatureCategory.planning:
        return 'Plans, routines, and journeys';
      case PremiumFeatureCategory.guidance:
        return 'Guidance and encouragement';
      case PremiumFeatureCategory.learning:
        return 'Learning';
      case PremiumFeatureCategory.accountability:
        return 'Accountability';
      case PremiumFeatureCategory.reporting:
        return 'Reports and exports';
      case PremiumFeatureCategory.personalization:
        return 'Personalization';
      case PremiumFeatureCategory.artificialIntelligence:
        return 'AI personalization';
    }
  }
}

enum PremiumFeatureAvailability {
  available,
  requiresStoreSetup,
  requiresBackend,
}

class PremiumFeature {
  final String id;
  final String title;
  final String description;
  final PremiumPlan requiredPlan;
  final PremiumFeatureCategory category;
  final PremiumFeatureAvailability availability;
  final bool neverPaywall;

  const PremiumFeature({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredPlan,
    required this.category,
    this.availability = PremiumFeatureAvailability.available,
    this.neverPaywall = false,
  });

  bool isIncludedFor(PremiumPlan plan) => plan.includes(requiredPlan);
}
