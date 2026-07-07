import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';

class PrivacySafetyCenterScreen extends StatelessWidget {
  const PrivacySafetyCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Safety Center')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Private by default', style: AppTypography.section),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Breakout is designed around local-first recovery tools, neutral labels, optional feature controls, and clear boundaries around AI.',
                  style: AppTypography.muted,
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Open Privacy Settings',
                  icon: Icons.lock_outline,
                  onPressed: () => Navigator.pushNamed(
                    context,
                    RouteNames.privacySettings,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      RouteNames.featureControls,
                    ),
                    icon: const Icon(Icons.tune_outlined),
                    label: const Text('Open Feature Controls'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const _SafetyPoint(
            icon: Icons.phone_android_outlined,
            title: 'Local-first recovery path',
            detail: 'The core demo path works without requiring cloud AI. Rescue, logging, education, support planning, and insights remain available locally.',
          ),
          const SizedBox(height: AppSpacing.sm),
          const _SafetyPoint(
            icon: Icons.visibility_off_outlined,
            title: 'Neutral wording',
            detail: 'Privacy mode helps keep sensitive recovery language out of casual view when the app may be seen by someone else.',
          ),
          const SizedBox(height: AppSpacing.sm),
          const _SafetyPoint(
            icon: Icons.lock_outline,
            title: 'Protected areas',
            detail: 'Private sections such as logs, insights, and settings can sit behind the app lock flow depending on the chosen lock scope.',
          ),
          const SizedBox(height: AppSpacing.sm),
          const _SafetyPoint(
            icon: Icons.psychology_alt_outlined,
            title: 'AI is optional',
            detail: 'AI features are controlled by gates, usage labels, and safety fallbacks. Breakout Plus can still provide value without AI chat.',
          ),
          const SizedBox(height: AppSpacing.sm),
          const _SafetyPoint(
            icon: Icons.health_and_safety_outlined,
            title: 'Not emergency care',
            detail: 'Breakout can encourage, guide, and redirect, but it is not a substitute for crisis services, medical care, therapy, or emergency support.',
          ),
        ],
      ),
    );
  }
}

class _SafetyPoint extends StatelessWidget {
  const _SafetyPoint({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.section),
                const SizedBox(height: AppSpacing.sm),
                Text(detail, style: AppTypography.muted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
