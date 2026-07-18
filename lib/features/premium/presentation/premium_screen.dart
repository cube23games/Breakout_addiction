import 'package:flutter/material.dart';

import '../../../app/config/qa_entitlement_gate.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/info_card.dart';
import '../billing/domain/billing_product_ids.dart';
import '../billing/presentation/premium_billing_controller.dart';
import '../billing/presentation/widgets/subscription_status_card.dart';
import '../data/premium_access_repository.dart';
import '../domain/premium_feature.dart';
import '../domain/premium_feature_catalog.dart';
import '../domain/premium_plan.dart';
import '../domain/premium_status.dart';
import 'widgets/premium_feature_card.dart';
import 'widgets/premium_plan_card.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final PremiumAccessRepository _repository = PremiumAccessRepository();
  final PremiumBillingController _billing =
      PremiumBillingController.instance;

  PremiumStatus _status = PremiumStatus.defaults();
  PremiumPlan _comparisonPlan = PremiumPlan.plus;
  bool _loading = true;
  bool _reloadingFromBilling = false;

  @override
  void initState() {
    super.initState();
    _billing.addListener(_onBillingChanged);
    _load();
  }

  @override
  void dispose() {
    _billing.removeListener(_onBillingChanged);
    super.dispose();
  }

  void _onBillingChanged() {
    if (!_reloadingFromBilling) {
      _load(fromBilling: true);
    }
  }

  Future<void> _load({bool fromBilling = false}) async {
    if (fromBilling) {
      _reloadingFromBilling = true;
    }
    final status = await _repository.getStatus();
    if (!mounted) {
      return;
    }
    setState(() {
      _status = status;
      _loading = false;
    });
    _reloadingFromBilling = false;
  }

  Future<void> _setQaPlan(PremiumPlan plan) async {
    await _repository.setPlan(plan);
    await _load();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('QA tier set to ${plan.label}.')),
    );
  }

  Future<void> _togglePrompts(bool value) async {
    await _repository.setUpgradePrompts(value);
    await _load();
  }

  Future<void> _purchase(PremiumPlan plan) async {
    try {
      await _billing.beginPurchase(plan);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _restore() async {
    try {
      await _billing.restore();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore failed: $error')),
      );
    }
  }

  Future<void> _manage() async {
    final plan = _status.plan == PremiumPlan.none
        ? PremiumPlan.plus
        : _status.plan;
    final opened = await _billing.manageSubscription(plan);
    if (!mounted || opened) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not open Google Play subscription management.'),
      ),
    );
  }

  Widget _qaEntitlementCard() {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('QA Entitlement Override', style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Tests direct tier access only. It does not simulate a Play purchase.',
            style: AppTypography.muted,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final plan in PremiumPlan.values)
                ChoiceChip(
                  label: Text(plan.label),
                  selected: _status.plan == plan &&
                      _status.source == 'qa-override',
                  onSelected: (_) => _setQaPlan(plan),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _status.showUpgradePrompts,
            onChanged: _togglePrompts,
            title: const Text('Show upgrade prompts'),
            subtitle: const Text(
              'Normal public builds hide this QA control.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _comparisonSelector() {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Compare feature access', style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<PremiumPlan>(
            segments: const [
              ButtonSegment(
                value: PremiumPlan.none,
                label: Text('Standard'),
              ),
              ButtonSegment(
                value: PremiumPlan.plus,
                label: Text('Plus'),
              ),
              ButtonSegment(
                value: PremiumPlan.plusAi,
                label: Text('Plus AI'),
              ),
            ],
            selected: <PremiumPlan>{_comparisonPlan},
            onSelectionChanged: (selection) {
              setState(() => _comparisonPlan = selection.first);
            },
          ),
        ],
      ),
    );
  }

  String _priceFor(PremiumPlan plan) {
    final productId = BillingProductIds.forPlan(plan);
    final product = _billing.storeSnapshot.productForId(productId);
    return product?.localizedPrice ?? 'Price unavailable';
  }

  List<Widget> _featureSections() {
    final widgets = <Widget>[];

    for (final category in PremiumFeatureCategory.values) {
      final features = PremiumFeatureCatalog.all
          .where((feature) => feature.category == category)
          .toList();
      if (features.isEmpty) {
        continue;
      }

      widgets.add(Text(category.label, style: AppTypography.title));
      widgets.add(const SizedBox(height: AppSpacing.sm));
      for (final feature in features) {
        widgets.add(
          PremiumFeatureCard(
            feature: feature,
            activePlan: _comparisonPlan,
          ),
        );
        widgets.add(const SizedBox(height: AppSpacing.md));
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Premium')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final purchaseEnabled =
        _billing.verificationConfigured && !_billing.busy;

    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Breakout Premium', style: AppTypography.title),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Core Rescue, logging, privacy, human support, and emergency information stay free. Premium adds depth, structure, reporting, and optional AI personalization.',
            style: AppTypography.muted,
          ),
          const SizedBox(height: AppSpacing.lg),
          SubscriptionStatusCard(
            status: _status,
            operationMessage: _billing.operationMessage,
            busy: _billing.busy,
            onRestore: _restore,
            onManage: _status.plan == PremiumPlan.none ? null : _manage,
          ),
          const SizedBox(height: AppSpacing.md),
          if (QaEntitlementGate.enabled) ...[
            _qaEntitlementCard(),
            const SizedBox(height: AppSpacing.md),
          ],
          PremiumPlanCard(
            plan: PremiumPlan.none,
            activePlan: _status.plan,
            actionLabel: 'Included',
          ),
          const SizedBox(height: AppSpacing.md),
          PremiumPlanCard(
            plan: PremiumPlan.plus,
            activePlan: _status.plan,
            priceLabel: _priceFor(PremiumPlan.plus),
            actionLabel: 'Choose Breakout Plus',
            onPressed:
                purchaseEnabled ? () => _purchase(PremiumPlan.plus) : null,
          ),
          const SizedBox(height: AppSpacing.md),
          PremiumPlanCard(
            plan: PremiumPlan.plusAi,
            activePlan: _status.plan,
            priceLabel: _priceFor(PremiumPlan.plusAi),
            actionLabel: 'Choose Breakout Plus AI',
            onPressed:
                purchaseEnabled ? () => _purchase(PremiumPlan.plusAi) : null,
          ),
          if (!_billing.verificationConfigured) ...[
            const SizedBox(height: AppSpacing.md),
            const InfoCard(
              child: Text(
                'Purchasing is safely disabled until the HTTPS purchase-verification service is configured. No local toggle can grant public paid access.',
                style: AppTypography.muted,
              ),
            ),
          ],
          if (_billing.storeSnapshot.missingProductIds.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            InfoCard(
              child: Text(
                'Missing Play products: '
                '${_billing.storeSnapshot.missingProductIds.join(', ')}',
                style: AppTypography.muted,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          _comparisonSelector(),
          const SizedBox(height: AppSpacing.lg),
          ..._featureSections(),
          const InfoCard(
            child: Text(
              'AI access is designed for generous normal recovery use, subject to fair-use limits. It does not replace therapy, emergency care, or human support.',
              style: AppTypography.muted,
            ),
          ),
        ],
      ),
    );
  }
}
