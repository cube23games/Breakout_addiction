import 'package:flutter/material.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_typography.dart';
import '../../../../../core/widgets/info_card.dart';

class RecoveryEventIntensityCard
    extends StatelessWidget {
  const RecoveryEventIntensityCard({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Intensity',
            style: AppTypography.section,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${value.round()} / 10',
            style: AppTypography.body,
          ),
          Slider(
            value: value,
            min: 0,
            max: 10,
            divisions: 10,
            label: value.round().toString(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
