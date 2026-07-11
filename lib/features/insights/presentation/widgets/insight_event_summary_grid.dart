import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/info_card.dart';

class InsightEventSummaryGrid extends StatelessWidget {
  const InsightEventSummaryGrid({
    required this.urgeCount,
    required this.relapseCount,
    required this.victoryCount,
    super.key,
  });

  final int urgeCount;
  final int relapseCount;
  final int victoryCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720
            ? 3
            : constraints.maxWidth >= 440
                ? 2
                : 1;

        final totalSpacing =
            AppSpacing.md * (columns - 1);

        final cardWidth =
            (constraints.maxWidth - totalSpacing) /
                columns;

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _EventSummaryCard(
              width: cardWidth,
              title: 'Urges',
              count: urgeCount,
              subtitle: 'Logged urge events',
            ),
            _EventSummaryCard(
              width: cardWidth,
              title: 'Relapses',
              count: relapseCount,
              subtitle: 'Logged slips',
            ),
            _EventSummaryCard(
              width: cardWidth,
              title: 'Victories',
              count: victoryCount,
              subtitle: 'Logged wins',
            ),
          ],
        );
      },
    );
  }
}

class _EventSummaryCard extends StatelessWidget {
  const _EventSummaryCard({
    required this.width,
    required this.title,
    required this.count,
    required this.subtitle,
  });

  final double width;
  final String title;
  final int count;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InfoCard(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.section,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '$count',
              style: AppTypography.title,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: AppTypography.muted,
            ),
          ],
        ),
      ),
    );
  }
}
