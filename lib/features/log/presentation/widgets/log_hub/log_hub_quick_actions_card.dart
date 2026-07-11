import 'package:flutter/material.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_typography.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../../../../core/widgets/primary_button.dart';

class LogHubQuickActionsCard
    extends StatelessWidget {
  const LogHubQuickActionsCard({
    required this.onLogCycleStage,
    required this.onLogMood,
    required this.onLogRecoveryEvent,
    super.key,
  });

  final VoidCallback onLogCycleStage;
  final VoidCallback onLogMood;
  final VoidCallback onLogRecoveryEvent;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Log Actions',
            style: AppTypography.section,
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: 'Log Cycle Stage',
            icon: Icons.add_chart_outlined,
            onPressed: onLogCycleStage,
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onLogMood,
              icon: const Icon(
                Icons.mood_outlined,
              ),
              label: const Text('Log Mood'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onLogRecoveryEvent,
              icon: const Icon(
                Icons.flag_outlined,
              ),
              label: const Text(
                'Log Urge / Relapse / Victory',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
