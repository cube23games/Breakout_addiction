import 'package:flutter/material.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_typography.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../recovery_event_form_controller.dart';

class RecoveryEventReasonCard extends StatelessWidget {
  const RecoveryEventReasonCard({
    required this.value,
    required this.customController,
    required this.onChanged,
    super.key,
  });

  final String value;
  final TextEditingController customController;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reason / Trigger',
            style: AppTypography.section,
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            initialValue: value,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: RecoveryEventFormController
                .reasonOptions
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ),
                )
                .toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
          ),
          if (value ==
              RecoveryEventFormController.otherReason) ...[
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: customController,
              minLines: 1,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText:
                    'Name your reason in your own words...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
