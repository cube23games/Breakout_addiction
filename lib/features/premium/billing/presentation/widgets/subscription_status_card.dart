import 'package:flutter/material.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_typography.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../../domain/premium_status.dart';

class SubscriptionStatusCard extends StatelessWidget {
  final PremiumStatus status;
  final String operationMessage;
  final bool busy;
  final VoidCallback? onRestore;
  final VoidCallback? onManage;

  const SubscriptionStatusCard({
    super.key,
    required this.status,
    required this.operationMessage,
    required this.busy,
    this.onRestore,
    this.onManage,
  });

  String _expirationLabel() {
    final expiresAt = status.expiresAt;
    if (expiresAt == null) {
      return 'No verified expiration is stored.';
    }
    final local = expiresAt.toLocal();
    return 'Verified through ${local.month}/${local.day}/${local.year}.';
  }

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Subscription status', style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          Text(status.plan.label, style: AppTypography.title),
          const SizedBox(height: 6),
          Text(status.lifecycle.label, style: AppTypography.body),
          const SizedBox(height: 6),
          Text(status.statusMessage, style: AppTypography.muted),
          const SizedBox(height: 6),
          Text(_expirationLabel(), style: AppTypography.muted),
          const SizedBox(height: AppSpacing.sm),
          Text(operationMessage, style: AppTypography.muted),
          if (busy) ...[
            const SizedBox(height: AppSpacing.sm),
            const LinearProgressIndicator(),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              OutlinedButton.icon(
                onPressed: busy ? null : onRestore,
                icon: const Icon(Icons.restore),
                label: const Text('Restore purchases'),
              ),
              if (onManage != null)
                OutlinedButton.icon(
                  onPressed: onManage,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Manage subscription'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
