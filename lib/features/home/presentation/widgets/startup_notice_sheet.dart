import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../../core/widgets/primary_button.dart';

class StartupNoticeSheet extends StatelessWidget {
  final bool showOnStartup;
  final ValueChanged<bool> onShowOnStartupChanged;
  final VoidCallback onContinue;
  final VoidCallback onOpenFeatureChoices;
  final VoidCallback onOpenSupport;

  const StartupNoticeSheet({
    super.key,
    required this.showOnStartup,
    required this.onShowOnStartupChanged,
    required this.onContinue,
    required this.onOpenFeatureChoices,
    required this.onOpenSupport,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.98),
      elevation: 24,
      shadowColor: Colors.black.withValues(alpha: 0.55),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        side: BorderSide(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.92,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                InfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to Breakout',
                        style: AppTypography.title,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'This app is designed to help you interrupt patterns earlier, not make you feel worse.',
                        style: AppTypography.body,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You are not expected to use every feature. You can keep things simple, private, and low-pressure.',
                        style: AppTypography.muted,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'AI features are optional and can be turned off or avoided entirely.',
                        style: AppTypography.muted,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'If you feel discouraged, come back to the smallest next step — not the perfect one.',
                        style: AppTypography.muted,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: showOnStartup,
                        onChanged: onShowOnStartupChanged,
                        title: const Text('Show this on startup'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Continue',
                  icon: Icons.arrow_forward_outlined,
                  onPressed: onContinue,
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onOpenFeatureChoices,
                    icon: const Icon(Icons.tune_outlined),
                    label: const Text('Privacy & Feature Choices'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onOpenSupport,
                    icon: const Icon(Icons.support_agent_outlined),
                    label: const Text('Support'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
