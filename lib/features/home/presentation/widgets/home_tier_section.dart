import 'package:flutter/material.dart';

import '../../../../app/config/qa_billing_gate.dart';
import '../../../../app/config/qa_entitlement_gate.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../premium/data/premium_access_repository.dart';
import '../../../premium/domain/premium_plan.dart';
import '../../../premium/domain/premium_status.dart';
import 'active_recovery_plan_card.dart';

class HomeTierSection extends StatelessWidget {
  const HomeTierSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PremiumStatus>(
      future: PremiumAccessRepository().getStatus(),
      builder: (context, snapshot) {
        final status = snapshot.data;
        if (status == null) {
          return const InfoCard(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (QaEntitlementGate.enabled || QaBillingGate.enabled) ...[
              _QaTierBanner(status: status),
              const SizedBox(height: AppSpacing.md),
            ],
            if (status.hasPremium)
              const ActiveRecoveryPlanCard()
            else
              const _StandardPlusPreview(),
          ],
        );
      },
    );
  }
}

class _QaTierBanner extends StatelessWidget {
  const _QaTierBanner({required this.status});

  final PremiumStatus status;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'QA entitlement: ${status.plan.label}',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.science_outlined, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'QA access: ${status.plan.label}',
                style: AppTypography.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StandardPlusPreview extends StatelessWidget {
  const _StandardPlusPreview();

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recovery Plans', style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Standard includes Rescue, logging, basic planning, and one personal reason. Plus adds guided day-by-day plans and deeper progress tools.',
            style: AppTypography.muted,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                RouteNames.premium,
              ),
              icon: const Icon(Icons.workspace_premium_outlined),
              label: const Text('Explore Breakout Plus'),
            ),
          ),
        ],
      ),
    );
  }
}
