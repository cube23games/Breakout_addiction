import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/widgets/info_card.dart';
import '../../premium/data/premium_access_repository.dart';
import '../../premium/domain/premium_plan.dart';
import '../../premium/domain/premium_status.dart';

class PremiumToolsScreen extends StatelessWidget {
  const PremiumToolsScreen({super.key});

  Widget _toolCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required String route,
    bool enabled = true,
    String? lockedLabel,
  }) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          Text(description, style: AppTypography.muted),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: enabled
                  ? () => Navigator.pushNamed(context, route)
                  : () => Navigator.pushNamed(
                        context,
                        RouteNames.premium,
                      ),
              icon: Icon(enabled ? Icons.arrow_forward : Icons.lock_outline),
              label: Text(
                enabled ? 'Open' : (lockedLabel ?? 'Upgrade required'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PremiumStatus>(
      future: PremiumAccessRepository().getStatus(),
      builder: (context, snapshot) {
        final status = snapshot.data;
        final hasAi = status?.plan == PremiumPlan.plusAi;

        return Scaffold(
          appBar: AppBar(title: const Text('Premium Tools')),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                'Put premium depth to work.',
                style: AppTypography.title,
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'These tools add structure, progress, reports, and optional AI without taking core Rescue away from Standard users.',
                style: AppTypography.muted,
              ),
              const SizedBox(height: AppSpacing.lg),
              _toolCard(
                context,
                title: 'Daily Recovery Dashboard',
                description:
                    'See today’s risk snapshot, first action, next risk window, recommended routine, and weekly progress.',
                icon: Icons.dashboard_customize_outlined,
                route: RouteNames.premiumDashboard,
              ),
              const SizedBox(height: AppSpacing.md),
              _toolCard(
                context,
                title: 'Private Pattern Intelligence',
                description:
                    'Find peak days and times, repeated trigger combinations, earlier warning signals, and what has helped.',
                icon: Icons.hub_outlined,
                route: RouteNames.premiumPatterns,
              ),
              const SizedBox(height: AppSpacing.md),
              _toolCard(
                context,
                title: 'Local Recovery Guidance',
                description:
                    'Use on-device patterns, encouragement, and optional faith-sensitive guidance without an AI call.',
                icon: Icons.explore_outlined,
                route: RouteNames.premiumGuidance,
              ),
              const SizedBox(height: AppSpacing.md),
              _toolCard(
                context,
                title: 'Guided Recovery Routines',
                description:
                    'Follow practical morning, evening, high-risk, and post-slip steps.',
                icon: Icons.checklist_rtl_outlined,
                route: RouteNames.guidedRoutines,
              ),
              const SizedBox(height: AppSpacing.md),
              _toolCard(
                context,
                title: 'Recovery Journeys',
                description:
                    'Work through secular or optional faith-sensitive multi-step journeys.',
                icon: Icons.route_outlined,
                route: RouteNames.recoveryJourneys,
              ),
              const SizedBox(height: AppSpacing.md),
              _toolCard(
                context,
                title: 'Recovery Report',
                description:
                    'Create a private, readable summary from your logs, plan, and risk tools.',
                icon: Icons.description_outlined,
                route: RouteNames.recoveryReport,
              ),
              const SizedBox(height: AppSpacing.md),
              _toolCard(
                context,
                title: 'Premium Preferences and Widget',
                description:
                    'Choose routine emphasis, report detail, and the private focus shown in widget content.',
                icon: Icons.tune_outlined,
                route: RouteNames.premiumPreferences,
              ),
              const SizedBox(height: AppSpacing.md),
              _toolCard(
                context,
                title: 'AI Personalization Tools',
                description:
                    'Open the secure AI coach for plan help, reflections, weekly review, and accountability drafting.',
                icon: Icons.auto_awesome_outlined,
                route: RouteNames.aiTools,
                enabled: hasAi,
                lockedLabel: 'Breakout Plus AI required',
              ),
              const SizedBox(height: AppSpacing.md),
              _toolCard(
                context,
                title: 'Educate Me Plus',
                description:
                    'Open deeper tracks on ritual setup, risk windows, practical friction, and rebuilding.',
                icon: Icons.menu_book_outlined,
                route: RouteNames.educate,
              ),
              const SizedBox(height: AppSpacing.md),
              _toolCard(
                context,
                title: 'Advanced Risk Windows',
                description:
                    'Prepare recurring vulnerable times and local reminders before pressure rises.',
                icon: Icons.schedule_outlined,
                route: RouteNames.riskWindows,
              ),
              const SizedBox(height: AppSpacing.md),
              _toolCard(
                context,
                title: 'Advanced Insights',
                description:
                    'Review pressure drivers, stage patterns, risks, and next actions.',
                icon: Icons.insights_outlined,
                route: RouteNames.premiumInsights,
              ),
              const SizedBox(height: AppSpacing.md),
              _toolCard(
                context,
                title: 'Personal Recovery Plan',
                description:
                    'Keep first actions, backup steps, grounding, support, and fallback ready.',
                icon: Icons.health_and_safety_outlined,
                route: RouteNames.recoveryPlan,
              ),
              const SizedBox(height: AppSpacing.md),
              _toolCard(
                context,
                title: 'Accountability Tools',
                description:
                    'Prepare privacy-controlled summaries for trusted human support.',
                icon: Icons.people_alt_outlined,
                route: RouteNames.accountabilitySettings,
              ),
            ],
          ),
        );
      },
    );
  }
}
