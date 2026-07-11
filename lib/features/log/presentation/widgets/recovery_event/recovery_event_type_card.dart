import 'package:flutter/material.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_typography.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../../domain/recovery_event_entry.dart';

class RecoveryEventTypeCard extends StatelessWidget {
  const RecoveryEventTypeCard({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final RecoveryEventType value;
  final ValueChanged<RecoveryEventType> onChanged;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Event Type',
            style: AppTypography.section,
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<RecoveryEventType>(
            initialValue: value,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: RecoveryEventType.values
                .map(
                  (item) =>
                      DropdownMenuItem<RecoveryEventType>(
                    value: item,
                    child: Text(item.label),
                  ),
                )
                .toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
          ),
        ],
      ),
    );
  }
}
