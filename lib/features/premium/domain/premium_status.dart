import '../billing/domain/subscription_lifecycle.dart';
import 'premium_plan.dart';

class PremiumStatus {
  final PremiumPlan plan;
  final bool showUpgradePrompts;
  final SubscriptionLifecycle lifecycle;
  final String source;
  final String statusMessage;
  final String? productId;
  final DateTime? expiresAt;

  const PremiumStatus({
    required this.plan,
    required this.showUpgradePrompts,
    this.lifecycle = SubscriptionLifecycle.none,
    this.source = 'standard',
    this.statusMessage = 'Standard access is active.',
    this.productId,
    this.expiresAt,
  });

  factory PremiumStatus.defaults() {
    return const PremiumStatus(
      plan: PremiumPlan.none,
      showUpgradePrompts: true,
    );
  }

  PremiumStatus copyWith({
    PremiumPlan? plan,
    bool? showUpgradePrompts,
    SubscriptionLifecycle? lifecycle,
    String? source,
    String? statusMessage,
    String? productId,
    DateTime? expiresAt,
  }) {
    return PremiumStatus(
      plan: plan ?? this.plan,
      showUpgradePrompts: showUpgradePrompts ?? this.showUpgradePrompts,
      lifecycle: lifecycle ?? this.lifecycle,
      source: source ?? this.source,
      statusMessage: statusMessage ?? this.statusMessage,
      productId: productId ?? this.productId,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  bool get isUnlocked => plan != PremiumPlan.none;
  bool get hasPremium => plan == PremiumPlan.plus || plan == PremiumPlan.plusAi;
  bool get hasAiPremium => plan == PremiumPlan.plusAi;
}
