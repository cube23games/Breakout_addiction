import 'package:flutter/material.dart';

import '../../../app/config/qa_entitlement_gate.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/info_card.dart';
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

  PremiumStatus _status = PremiumStatus.defaults();
  PremiumPlan _comparisonPlan = PremiumPlan.plus;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final status = await _repository.getStatus();
    if (!mounted) return;
    setState(() {
      _status = status;
      _loading = false;
    });
  }

  Future<void> _setQaPlan(PremiumPlan plan) async {
    await _repository.setPlan(plan);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('QA tier set to ${plan.label}.')),
    );
  }

  Future<void> _togglePrompts(bool value) async {
    await _repository.setUpgradePrompts(value);
    await _load();
  }

  Widget _qaEntitlementCard() {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('QA Entitlement Override', style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Tests direct tier access only. It does not simulate billing or a purchase.',
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
                  selected: _status.plan == plan,
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
            subtitle: const Text('Normal public builds hide this QA control.'),
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
              ButtonSegment(value: PremiumPlan.none, label: Text('Standard')),
              ButtonSegment(value: PremiumPlan.plus, label: Text('Plus')),
              ButtonSegment(value: PremiumPlan.plusAi, label: Text('Plus AI')),
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

  List<Widget> _featureSections() {
    final widgets = <Widget>[];
    for (final category in PremiumFeatureCategory.values) {
      final features = PremiumFeatureCatalog.all
          .where((feature) => feature.category == category)
          .toList();
      if (features.isEmpty) continue;
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
            priceLabel: 'Play price loads after billing setup',
            actionLabel: 'Coming through Google Play',
          ),
          const SizedBox(height: AppSpacing.md),
          PremiumPlanCard(
            plan: PremiumPlan.plusAi,
            activePlan: _status.plan,
            priceLabel: 'Play price loads after billing setup',
            actionLabel: 'Coming through Google Play',
          ),
          const SizedBox(height: AppSpacing.lg),
          _comparisonSelector(),
          const SizedBox(height: AppSpacing.lg),
          ..._featureSections(),
          const InfoCard(
            child: Text(
              'The public build remains Standard until a Google Play purchase is securely verified. AI access will be optional and subject to fair-use limits.',
              style: AppTypography.muted,
            ),
          ),
        ],
      ),
    );
  }
}
