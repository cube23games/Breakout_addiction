import 'package:flutter/material.dart';

import '../../../app/config/qa_billing_gate.dart';
import '../../../app/config/qa_entitlement_gate.dart';
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
  }) {
    return InfoCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, size: 30),
        title: Text(title, style: AppTypography.section),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Text(description, style: AppTypography.muted),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }

  Widget _standardView(BuildContext context, PremiumStatus status) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('Breakout Plus', style: AppTypography.title),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Standard recovery tools stay available. Plus adds guided plans, deeper progress, reports, and accountability tools.',
          style: AppTypography.muted,
        ),
        const SizedBox(height: AppSpacing.lg),
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('What Plus adds', style: AppTypography.section),
              const SizedBox(height: AppSpacing.sm),
              const Text('• Day-by-day recovery plans'),
              const Text('• Guided routines and deeper insights'),
              const Text('• Private reports and accountability tools'),
              const Text('• Premium widget options'),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    RouteNames.premium,
                  ),
                  icon: const Icon(Icons.workspace_premium_outlined),
                  label: const Text('Compare Plans'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PremiumStatus>(
      future: PremiumAccessRepository().getStatus(),
      builder: (context, snapshot) {
        final status = snapshot.data;
        if (status == null) {
          return const Scaffold(
            appBar: AppBar(title: Text('Premium Tools')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!status.hasPremium) {
          return Scaffold(
            appBar: AppBar(title: const Text('Premium Tools')),
            body: _standardView(context, status),
          );
        }

        final hasAi = status.plan == PremiumPlan.plusAi;
        return Scaffold(
          appBar: AppBar(title: const Text('Premium Tools')),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (QaEntitlementGate.enabled || QaBillingGate.enabled) ...[
                InfoCard(
                  child: Text(
                    'QA access: ${status.plan.label}',
                    style: AppTypography.muted,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              Text('Your Plus tools', style: AppTypography.title),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Open the tool you need. Rescue and basic recovery tools remain separate and always available.',
                style: AppTypography.muted,
              ),
              const SizedBox(height: AppSpacing.lg),
              _toolCard(
                context,
                title: 'Daily Recovery Dashboard',
                description: 'See today’s risk, next action, and weekly progress.',
                icon: Icons.dashboard_customize_outlined,
                route: RouteNames.premiumDashboard,
              ),
              const SizedBox(height: AppSpacing.md),
              _toolCard(
                context,
                title: 'Private Pattern Intelligence',
                description: 'Find repeated trigger combinations, warning signs, and helpful actions.',
                icon: Icons.hub_outlined,
                route: RouteNames.premiumPatterns,
              ),
              const SizedBox(height: AppSpacing.md),
              _toolCard(
                context,
                title: 'Guided Recovery Routines',
                description: 'Follow one practical activity at a time.',
                icon: Icons.checklist_rtl_outlined,
                route: RouteNames.guidedRoutines,
              ),
              const SizedBox(height: AppSpacing.md),
              _toolCard(
                context,
                title: 'Recovery Programs',
                description: 'Follow your selected plan day by day.',
                icon: Icons.view_timeline_outlined,
                route: RouteNames.recoveryPrograms,
              ),
              const SizedBox(height: AppSpacing.md),
              _toolCard(
                context,
                title: 'Recovery Journeys',
                description: 'Work through secular or optional faith-based journeys.',
                icon: Icons.route_outlined,
                route: RouteNames.recoveryJourneys,
              ),
              const SizedBox(height: AppSpacing.md),
              _toolCard(
                context,
                title: 'Advanced Insights',
                description: 'Review repeated pressure, timing, and helpful actions.',
                icon: Icons.insights_outlined,
                route: RouteNames.premiumInsights,
              ),
              const SizedBox(height: AppSpacing.md),
              _toolCard(
                context,
                title: 'Recovery Report',
                description: 'Build a private summary you control.',
                icon: Icons.description_outlined,
                route: RouteNames.recoveryReport,
              ),
              const SizedBox(height: AppSpacing.md),
              _toolCard(
                context,
                title: 'Advanced Risk Windows',
                description: 'Prepare vulnerable times before pressure rises.',
                icon: Icons.schedule_outlined,
                route: RouteNames.riskWindows,
              ),
              const SizedBox(height: AppSpacing.md),
              _toolCard(
                context,
                title: 'Advanced Recovery Plan Builder',
                description: 'Add warning signs, triggers, daily commitments, and review dates.',
                icon: Icons.health_and_safety_outlined,
                route: RouteNames.recoveryPlan,
              ),
              const SizedBox(height: AppSpacing.md),
              _toolCard(
                context,
                title: 'Accountability Center',
                description: 'Prepare check-ins and review recovery engagement.',
                icon: Icons.people_alt_outlined,
                route: RouteNames.accountabilityCenter,
              ),
              const SizedBox(height: AppSpacing.md),
              _toolCard(
                context,
                title: 'Premium Preferences and Widget',
                description: 'Choose your private widget focus and report detail.',
                icon: Icons.tune_outlined,
                route: RouteNames.premiumPreferences,
              ),
              const SizedBox(height: AppSpacing.md),
              _toolCard(
                context,
                title: 'Local Recovery Guidance',
                description: 'Use private on-device patterns and optional faith-sensitive guidance.',
                icon: Icons.explore_outlined,
                route: RouteNames.premiumGuidance,
              ),
              const SizedBox(height: AppSpacing.md),
              _toolCard(
                context,
                title: 'Educate Me Plus',
                description: 'Open deeper recovery lessons without crowding the free Learn screen.',
                icon: Icons.menu_book_outlined,
                route: RouteNames.educate,
              ),
              const SizedBox(height: AppSpacing.md),
              if (hasAi)
                _toolCard(
                  context,
                  title: 'AI Personalization Tools',
                  description: 'Use optional AI support with clear privacy controls.',
                  icon: Icons.auto_awesome_outlined,
                  route: RouteNames.aiTools,
                )
              else
                InfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Breakout Plus AI', style: AppTypography.section),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'AI support is separate from Breakout Plus. Your Plus tools work without it.',
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
                          icon: const Icon(Icons.auto_awesome_outlined),
                          label: const Text('Compare Plus AI'),
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
