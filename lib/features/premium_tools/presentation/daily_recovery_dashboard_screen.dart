import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/daily_recovery_dashboard_repository.dart';
import '../domain/daily_recovery_dashboard.dart';

class DailyRecoveryDashboardScreen extends StatefulWidget {
  const DailyRecoveryDashboardScreen({super.key});

  @override
  State<DailyRecoveryDashboardScreen> createState() =>
      _DailyRecoveryDashboardScreenState();
}

class _DailyRecoveryDashboardScreenState
    extends State<DailyRecoveryDashboardScreen> {
  final DailyRecoveryDashboardRepository _repository =
      DailyRecoveryDashboardRepository();
  DailyRecoveryDashboard? _dashboard;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dashboard = await _repository.build();
    if (!mounted) {
      return;
    }
    setState(() {
      _dashboard = dashboard;
      _loading = false;
    });
  }

  Widget _metric(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTypography.section),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.muted,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _dashboard == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daily Recovery Dashboard')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final dashboard = _dashboard!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Recovery Dashboard'),
        actions: [
          IconButton(
            onPressed: _load,
            tooltip: 'Refresh dashboard',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Know what needs attention today.', style: AppTypography.title),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'This private dashboard uses only information stored on this device. It is guidance, not a prediction or diagnosis.',
            style: AppTypography.muted,
          ),
          const SizedBox(height: AppSpacing.lg),
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${dashboard.riskLabel} risk • ${dashboard.riskScore}/100',
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.sm),
                LinearProgressIndicator(value: dashboard.riskScore / 100),
                const SizedBox(height: AppSpacing.sm),
                Text(dashboard.riskReason, style: AppTypography.muted),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Today’s Focus', style: AppTypography.section),
                const SizedBox(height: AppSpacing.sm),
                Text(dashboard.todayFocus, style: AppTypography.body),
                const SizedBox(height: AppSpacing.md),
                Text('Your first action', style: AppTypography.section),
                const SizedBox(height: AppSpacing.sm),
                Text(dashboard.firstAction, style: AppTypography.body),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Open Rescue',
                  icon: Icons.flash_on_outlined,
                  onPressed: () =>
                      Navigator.pushNamed(context, RouteNames.rescue),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Private Pattern Snapshot', style: AppTypography.section),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Repeated trigger: ${dashboard.topTrigger}',
                  style: AppTypography.body,
                ),
                const SizedBox(height: 6),
                Text(
                  dashboard.nextRiskWindow,
                  style: AppTypography.body,
                ),
                const SizedBox(height: 6),
                Text(
                  'Recommended routine: ${dashboard.recommendedRoutineTitle}',
                  style: AppTypography.body,
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      RouteNames.guidedRoutines,
                    ),
                    icon: const Icon(Icons.checklist_rtl_outlined),
                    label: const Text('Open Recommended Routines'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      RouteNames.premiumPatterns,
                    ),
                    icon: const Icon(Icons.hub_outlined),
                    label: const Text('Open Private Pattern Intelligence'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This Week', style: AppTypography.section),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _metric('Victories', '${dashboard.weeklyVictories}'),
                    _metric('Urges', '${dashboard.weeklyUrges}'),
                    _metric('Slips', '${dashboard.weeklySlips}'),
                    _metric('Check-ins', '${dashboard.weeklyCheckIns}'),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(dashboard.weeklyLine, style: AppTypography.muted),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, RouteNames.recoveryEventLog),
              icon: const Icon(Icons.edit_note_outlined),
              label: const Text('Log What Is Happening'),
            ),
          ),
        ],
      ),
    );
  }
}
