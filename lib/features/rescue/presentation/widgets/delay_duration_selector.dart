import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/selectable_option_tile.dart';

class DelayDurationSelector extends StatelessWidget {
  const DelayDurationSelector({
    required this.selectedMinutes,
    required this.onSelected,
    super.key,
  });

  static const List<int> _durations = <int>[3, 5, 15];

  final int? selectedMinutes;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.sm;
        final columns = constraints.maxWidth >= 420 ? 3 : 1;
        final tileWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - (spacing * 2)) / 3;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final minutes in _durations)
              SizedBox(
                width: tileWidth,
                child: SelectableOptionTile(
                  label: '$minutes minutes',
                  selected: selectedMinutes == minutes,
                  onTap: () => onSelected(minutes),
                ),
              ),
          ],
        );
      },
    );
  }
}
