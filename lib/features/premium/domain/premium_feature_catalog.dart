import 'premium_feature.dart';
import 'premium_plan.dart';

class PremiumFeatureCatalog {
  const PremiumFeatureCatalog._();

  static const List<PremiumFeature> all = <PremiumFeature>[
    PremiumFeature(
      id: 'rescue',
      title: 'Immediate Rescue',
      description: 'Urge interruption, delay, breathing, and next safe actions.',
      requiredPlan: PremiumPlan.none,
      category: PremiumFeatureCategory.safety,
      neverPaywall: true,
    ),
    PremiumFeature(
      id: 'basic_logging',
      title: 'Basic Recovery Logging',
      description: 'Record urges, victories, slips, moods, and cycle stages.',
      requiredPlan: PremiumPlan.none,
      category: PremiumFeatureCategory.safety,
      neverPaywall: true,
    ),
    PremiumFeature(
      id: 'human_support',
      title: 'Human and Emergency Support',
      description: 'Trusted contacts, professional-help information, and crisis links.',
      requiredPlan: PremiumPlan.none,
      category: PremiumFeatureCategory.safety,
      neverPaywall: true,
    ),
    PremiumFeature(
      id: 'privacy',
      title: 'Privacy, Lock Mode, and Data Deletion',
      description: 'Protect private recovery data and remove it whenever needed.',
      requiredPlan: PremiumPlan.none,
      category: PremiumFeatureCategory.safety,
      neverPaywall: true,
    ),
    PremiumFeature(
      id: 'advanced_insights',
      title: 'Advanced 30- and 90-Day Insights',
      description: 'Private longer-term counts, pressure context, repeated triggers, direction, and next focus.',
      requiredPlan: PremiumPlan.plus,
      category: PremiumFeatureCategory.insight,
    ),
    PremiumFeature(
      id: 'risk_windows',
      title: 'Advanced Risk-Window Tools',
      description: 'Prepare recurring high-risk periods with proactive local reminders.',
      requiredPlan: PremiumPlan.plus,
      category: PremiumFeatureCategory.insight,
    ),
    PremiumFeature(
      id: 'recovery_plan',
      title: 'Recovery-Plan Integration',
      description: 'Bring saved first actions, backup steps, support, and fallback plans into premium routines and reports.',
      requiredPlan: PremiumPlan.plus,
      category: PremiumFeatureCategory.planning,
    ),
    PremiumFeature(
      id: 'guided_routines',
      title: 'Guided Recovery Routines',
      description: 'Step-by-step morning, evening, high-risk, and post-slip routines.',
      requiredPlan: PremiumPlan.plus,
      category: PremiumFeatureCategory.planning,
    ),
    PremiumFeature(
      id: 'recovery_journeys',
      title: 'Multi-Step Recovery Journeys',
      description: 'Structured secular and optional Christian recovery journeys with progress.',
      requiredPlan: PremiumPlan.plus,
      category: PremiumFeatureCategory.planning,
    ),
    PremiumFeature(
      id: 'local_guidance',
      title: 'Pattern-Aware Local Guidance',
      description: 'Private guidance selected on-device without a cloud call.',
      requiredPlan: PremiumPlan.plus,
      category: PremiumFeatureCategory.guidance,
    ),
    PremiumFeature(
      id: 'encouragement_packs',
      title: 'Expanded Encouragement Packs',
      description: 'More recovery, motivational, and situation-aware encouragement.',
      requiredPlan: PremiumPlan.plus,
      category: PremiumFeatureCategory.guidance,
    ),
    PremiumFeature(
      id: 'faith_packs',
      title: 'Optional Faith-Sensitive Packs',
      description: 'Expanded Christian reflections, scripture prompts, and journeys.',
      requiredPlan: PremiumPlan.plus,
      category: PremiumFeatureCategory.guidance,
    ),
    PremiumFeature(
      id: 'educate_plus',
      title: 'Educate Me Plus',
      description: 'Deeper learning tracks about triggers, habits, shame, and relapse prevention.',
      requiredPlan: PremiumPlan.plus,
      category: PremiumFeatureCategory.learning,
    ),
    PremiumFeature(
      id: 'accountability',
      title: 'Accountability Reports and Preparation',
      description: 'Prepare privacy-controlled summaries and focused check-in material for trusted support.',
      requiredPlan: PremiumPlan.plus,
      category: PremiumFeatureCategory.accountability,
    ),
    PremiumFeature(
      id: 'reports',
      title: 'Recovery Reports and Exports',
      description: 'Generate a readable progress report for personal use or approved sharing.',
      requiredPlan: PremiumPlan.plus,
      category: PremiumFeatureCategory.reporting,
    ),
    PremiumFeature(
      id: 'personalization',
      title: 'Expanded Personalization',
      description: 'Choose routine, guidance, faith, reminder, and encouragement preferences.',
      requiredPlan: PremiumPlan.plus,
      category: PremiumFeatureCategory.personalization,
    ),
    PremiumFeature(
      id: 'widget_options',
      title: 'Enhanced Widget Options',
      description: 'More private widget content and action choices.',
      requiredPlan: PremiumPlan.plus,
      category: PremiumFeatureCategory.personalization,
    ),
    PremiumFeature(
      id: 'ai_chat',
      title: 'AI Recovery Coach',
      description: 'Optional conversational support with safety boundaries and human-help fallback.',
      requiredPlan: PremiumPlan.plusAi,
      category: PremiumFeatureCategory.artificialIntelligence,
      availability: PremiumFeatureAvailability.requiresBackend,
    ),
    PremiumFeature(
      id: 'ai_rescue',
      title: 'AI-Personalized Rescue Guidance',
      description: 'Tailored prompts and next actions while core Rescue remains free.',
      requiredPlan: PremiumPlan.plusAi,
      category: PremiumFeatureCategory.artificialIntelligence,
      availability: PremiumFeatureAvailability.requiresBackend,
    ),
    PremiumFeature(
      id: 'ai_plan',
      title: 'AI Recovery-Plan Assistance',
      description: 'Help drafting and refining warning signs, actions, and fallback plans.',
      requiredPlan: PremiumPlan.plusAi,
      category: PremiumFeatureCategory.artificialIntelligence,
      availability: PremiumFeatureAvailability.requiresBackend,
    ),
    PremiumFeature(
      id: 'ai_patterns',
      title: 'AI Pattern Interpretation',
      description: 'Plain-language observations grounded in the user’s own logged data.',
      requiredPlan: PremiumPlan.plusAi,
      category: PremiumFeatureCategory.artificialIntelligence,
      availability: PremiumFeatureAvailability.requiresBackend,
    ),
    PremiumFeature(
      id: 'ai_reviews',
      title: 'AI Weekly Reviews',
      description: 'Personalized progress highlights, emerging risks, and next-week focus.',
      requiredPlan: PremiumPlan.plusAi,
      category: PremiumFeatureCategory.artificialIntelligence,
      availability: PremiumFeatureAvailability.requiresBackend,
    ),
    PremiumFeature(
      id: 'ai_reflection',
      title: 'AI-Assisted Reflections',
      description: 'Guided, non-shaming reflection after urges, victories, or slips.',
      requiredPlan: PremiumPlan.plusAi,
      category: PremiumFeatureCategory.artificialIntelligence,
      availability: PremiumFeatureAvailability.requiresBackend,
    ),
    PremiumFeature(
      id: 'ai_routines',
      title: 'AI-Adaptive Routines and Journeys',
      description: 'Adjust routine suggestions and journey focus to the current situation.',
      requiredPlan: PremiumPlan.plusAi,
      category: PremiumFeatureCategory.artificialIntelligence,
      availability: PremiumFeatureAvailability.requiresBackend,
    ),
    PremiumFeature(
      id: 'ai_accountability',
      title: 'AI Accountability Assistance',
      description: 'Draft check-in messages and summaries that the user reviews before sharing.',
      requiredPlan: PremiumPlan.plusAi,
      category: PremiumFeatureCategory.artificialIntelligence,
      availability: PremiumFeatureAvailability.requiresBackend,
    ),
    PremiumFeature(
      id: 'ai_encouragement',
      title: 'AI-Personalized Encouragement',
      description: 'Adapt encouragement to the current pressure, recovery focus, and preferred tone.',
      requiredPlan: PremiumPlan.plusAi,
      category: PremiumFeatureCategory.artificialIntelligence,
      availability: PremiumFeatureAvailability.requiresBackend,
    ),
    PremiumFeature(
      id: 'ai_faith_support',
      title: 'Optional AI Faith-Sensitive Support',
      description: 'Offer faith-aware reflection only when the user has chosen the faith layer.',
      requiredPlan: PremiumPlan.plusAi,
      category: PremiumFeatureCategory.artificialIntelligence,
      availability: PremiumFeatureAvailability.requiresBackend,
    ),
    PremiumFeature(
      id: 'ai_report_help',
      title: 'AI Report Interpretation',
      description: 'Help explain a user-reviewed recovery report without changing the underlying data.',
      requiredPlan: PremiumPlan.plusAi,
      category: PremiumFeatureCategory.artificialIntelligence,
      availability: PremiumFeatureAvailability.requiresBackend,
    ),
  ];

  static List<PremiumFeature> forPlan(PremiumPlan plan) {
    return all.where((feature) => feature.isIncludedFor(plan)).toList();
  }

  static List<PremiumFeature> exactlyFor(PremiumPlan plan) {
    return all.where((feature) => feature.requiredPlan == plan).toList();
  }

  static PremiumFeature byId(String id) {
    return all.firstWhere((feature) => feature.id == id);
  }
}
