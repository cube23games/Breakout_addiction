import 'package:flutter/material.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_typography.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../../domain/cycle_stage_log_entry.dart';
import 'stage_log_row.dart';

class RecentStageLogsCard extends StatelessWidget {
  const RecentStageLogsCard({
    required this.future,
    super.key,
  });

  final Future<List<CycleStageLogEntry>> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CycleStageLogEntry>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const InfoCard(
            child: Text(
              'Loading recent stage logs...',
              style: AppTypography.muted,
            ),
          );
        }

        final entries =
            snapshot.data ?? <CycleStageLogEntry>[];

        if (entries.isEmpty) {
          return const InfoCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Stage Logs',
                  style: AppTypography.section,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'No saved stage logs yet.',
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
                'Recent Stage Logs',
                style: AppTypography.section,
              ),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              for (final entry in entries.take(4)) ...[
                StageLogRow(entry: entry),
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
