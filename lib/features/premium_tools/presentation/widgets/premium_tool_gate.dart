import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../premium/data/premium_access_repository.dart';
import '../../../premium/domain/premium_feature_catalog.dart';
import '../../../premium/domain/premium_status.dart';

class PremiumToolGate extends StatelessWidget {
  final String featureId;
  final Widget child;

  const PremiumToolGate({
    super.key,
    required this.featureId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PremiumStatus>(
      future: PremiumAccessRepository().getStatus(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final status = snapshot.data!;
        final feature = PremiumFeatureCatalog.byId(featureId);
        final requiredPlan = feature.requiredPlan;
        if (status.plan.includes(requiredPlan)) {
          return child;
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Premium Tool')),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              InfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${requiredPlan.label} required',
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      status.statusMessage,
                      style: AppTypography.muted,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PrimaryButton(
                      label: 'Open Premium',
                      icon: Icons.workspace_premium_outlined,
                      onPressed: () => Navigator.pushNamed(
                        context,
                        RouteNames.premium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
