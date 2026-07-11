import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../../core/widgets/selectable_option_tile.dart';

class RelockTimingCard extends StatelessWidget {
  const RelockTimingCard({
    required this.selectedMinutes,
    required this.enabled,
    required this.onSelected,
    super.key,
  });

  static const List<(int, String)> _options = <(int, String)>[
    (0, 'Immediately'),
    (1, '1 minute'),
    (2, '2 minutes'),
    (5, '5 minutes'),
    (10, '10 minutes'),
  ];

  final int selectedMinutes;
  final bool enabled;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Relock Timing', style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'After one successful unlock, all protected areas stay open while you use the app. Choose how long they remain open after the app is minimized.',
            style: AppTypography.muted,
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = AppSpacing.sm;
              final columns = constraints.maxWidth >= 420 ? 2 : 1;
              final tileWidth = columns == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - spacing) / 2;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final option in _options)
                    SizedBox(
                      width: tileWidth,
                      child: SelectableOptionTile(
                        label: option.$2,
                        selected: selectedMinutes == option.$1,
                        onTap: enabled
                            ? () => onSelected(option.$1)
                            : null,
                      ),
                    ),
                ],
              );
            },
          ),
          if (!enabled) ...[
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Set a passcode first to choose relock timing.',
              style: AppTypography.muted,
            ),
          ],
        ],
      ),
    );
  }
}
