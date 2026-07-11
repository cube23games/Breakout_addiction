import 'package:flutter/material.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_typography.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../../domain/recovery_event_entry.dart';
import 'recovery_event_row.dart';

class RecentRecoveryEventsCard
    extends StatelessWidget {
  const RecentRecoveryEventsCard({
    required this.future,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Future<List<RecoveryEventEntry>> future;
  final ValueChanged<RecoveryEventEntry> onEdit;
  final ValueChanged<RecoveryEventEntry> onDelete;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RecoveryEventEntry>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const InfoCard(
            child: Text(
              'Loading recent recovery events...',
              style: AppTypography.muted,
            ),
          );
        }

        final entries =
            snapshot.data ?? <RecoveryEventEntry>[];

        if (entries.isEmpty) {
          return const InfoCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Recovery Events',
                  style: AppTypography.section,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'No urge, relapse, or victory '
                  'logs yet.',
                  style: AppTypography.muted,
                ),
              ],
            ),
          );
        }

        return InfoCard(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Recovery Events',
                style: AppTypography.section,
              ),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              for (final entry in entries.take(5)) ...[
                RecoveryEventRow(
                  entry: entry,
                  onEdit: () => onEdit(entry),
                  onDelete: () => onDelete(entry),
                ),
                const SizedBox(
                  height: AppSpacing.sm,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
