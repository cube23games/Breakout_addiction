import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/release_checklist_repository.dart';
import '../domain/release_checklist_item.dart';

class ReleaseReadinessScreen extends StatelessWidget {
  const ReleaseReadinessScreen({super.key});

  static const ReleaseChecklistRepository _repository = ReleaseChecklistRepository();

  @override
  Widget build(BuildContext context) {
    final items = _repository.loadItems();
    final readyCount = _repository.readyCount();

    return Scaffold(
      appBar: AppBar(title: const Text('Release Readiness')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Demo-to-store checklist', style: AppTypography.section),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '$readyCount of ${items.length} release areas are marked ready. The rest are intentionally visible so the team can review them before store submission.',
                  style: AppTypography.muted,
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Open Privacy & Safety Center',
                  icon: Icons.privacy_tip_outlined,
                  onPressed: () => Navigator.pushNamed(
                    context,
                    RouteNames.privacySafetyCenter,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      RouteNames.aboutBreakout,
                    ),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('About Breakout'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final item in items) ...[
            _ChecklistTile(item: item),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({required this.item});

  final ReleaseChecklistItem item;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_iconFor(item.status)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTypography.section),
                const SizedBox(height: 4),
                Text(item.status.label, style: AppTypography.muted),
                const SizedBox(height: AppSpacing.sm),
                Text(item.detail, style: AppTypography.muted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(ReleaseChecklistStatus status) {
    switch (status) {
      case ReleaseChecklistStatus.ready:
        return Icons.check_circle_outline;
      case ReleaseChecklistStatus.needsReview:
        return Icons.rate_review_outlined;
      case ReleaseChecklistStatus.later:
        return Icons.pending_actions_outlined;
    }
  }
}
