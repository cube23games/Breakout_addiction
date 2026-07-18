import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/config/qa_billing_gate.dart';
import '../../../app/config/qa_entitlement_gate.dart';
import '../../../core/integrity/app_integrity_controller.dart';
import '../../../core/storage/local_data_safety.dart';
import '../billing/data/verified_entitlement_repository.dart';
import '../billing/domain/subscription_access_policy.dart';
import '../billing/domain/subscription_lifecycle.dart';
import '../domain/premium_plan.dart';
import '../domain/premium_status.dart';

class PremiumAccessRepository {
  static const String _premiumPlanKey = 'premium_plan';
  static const String _legacyPremiumUnlockedKey = 'premium_unlocked';
  static const String _upgradePromptsKey = 'premium_upgrade_prompts';

  final VerifiedEntitlementRepository _entitlementRepository;

  PremiumAccessRepository({
    VerifiedEntitlementRepository? entitlementRepository,
  }) : _entitlementRepository =
            entitlementRepository ?? VerifiedEntitlementRepository();

  Future<PremiumStatus> getStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final integrity =
        await AppIntegrityController.instance.ensureChecked();
    final showPrompts = prefs.getBool(_upgradePromptsKey) ?? true;
    PremiumPlan plan = PremiumPlan.none;

    if (!integrity.allowsPaidFeatures) {
      return PremiumStatus(
        plan: PremiumPlan.none,
        showUpgradePrompts: showPrompts,
        lifecycle: SubscriptionLifecycle.verificationUnavailable,
        source: 'integrity',
        statusMessage:
            'Paid features are unavailable because app integrity could not be confirmed. Core Rescue and recovery tools remain available.',
      );
    }

    if (QaBillingGate.enabled) {
      final entitlement = await _entitlementRepository.read();
      if (entitlement != null) {
        final plan = SubscriptionAccessPolicy.effectivePlan(
          entitlement,
          now: DateTime.now().toUtc(),
        );
        return PremiumStatus(
          plan: plan,
          showUpgradePrompts: showPrompts,
          lifecycle: entitlement.lifecycle,
          source: entitlement.verificationSource,
          productId: entitlement.productId,
          expiresAt: entitlement.expiresAt,
          statusMessage: plan == PremiumPlan.none
              ? 'QA billing lifecycle does not currently grant paid access.'
              : '${plan.label} is active through QA billing simulation.',
        );
      }
    }

    if (QaEntitlementGate.enabled && integrity.allowsPaidFeatures) {
      final rawPlan = prefs.getString(_premiumPlanKey);
      final legacyUnlocked =
          prefs.getBool(_legacyPremiumUnlockedKey) ?? false;
      final fallbackPlan =
          legacyUnlocked ? PremiumPlan.plus : PremiumPlan.none;
      plan = LocalDataSafety.enumByName(
        PremiumPlan.values,
        rawPlan,
        fallbackPlan,
      );

      return PremiumStatus(
        plan: plan,
        showUpgradePrompts: showPrompts,
        lifecycle: plan == PremiumPlan.none
            ? SubscriptionLifecycle.none
            : SubscriptionLifecycle.active,
        source: 'qa-override',
        statusMessage:
            'QA entitlement override is active. This is not a Play purchase.',
      );
    }

    final entitlement = await _entitlementRepository.read();
    plan = SubscriptionAccessPolicy.effectivePlan(
      entitlement,
      now: DateTime.now().toUtc(),
    );

    if (entitlement == null) {
      return PremiumStatus(
        plan: PremiumPlan.none,
        showUpgradePrompts: showPrompts,
      );
    }

    return PremiumStatus(
      plan: plan,
      showUpgradePrompts: showPrompts,
      lifecycle: entitlement.lifecycle,
      source: entitlement.verificationSource,
      productId: entitlement.productId,
      expiresAt: entitlement.expiresAt,
      statusMessage: plan == PremiumPlan.none
          ? 'The last verified subscription does not currently grant paid access.'
          : '${plan.label} is verified.',
    );
  }

  Future<void> saveStatus(PremiumStatus status) async {
    await _requireTrustedQaWrite();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_premiumPlanKey, status.plan.name);
    await prefs.setBool(
      _legacyPremiumUnlockedKey,
      status.isUnlocked,
    );
    await prefs.setBool(
      _upgradePromptsKey,
      status.showUpgradePrompts,
    );
  }

  Future<void> setPlan(PremiumPlan plan) async {
    final current = await getStatus();
    await saveStatus(current.copyWith(plan: plan));
  }

  Future<void> setUnlocked(bool value) async {
    await setPlan(
      value ? PremiumPlan.plus : PremiumPlan.none,
    );
  }

  Future<void> setUpgradePrompts(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_upgradePromptsKey, value);
  }

  Future<void> _requireTrustedQaWrite() async {
    if (!QaEntitlementGate.enabled) {
      throw StateError(
        'Local premium plan writes are disabled in public builds.',
      );
    }

    final integrity =
        await AppIntegrityController.instance.ensureChecked();
    if (!integrity.allowsPaidFeatures) {
      throw StateError(
        'Local premium plan writes are blocked by app integrity.',
      );
    }
  }
}
