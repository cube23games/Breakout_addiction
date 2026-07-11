import 'package:flutter/material.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/widgets/primary_button.dart';

class RecoveryEventFormActions extends StatelessWidget {
  const RecoveryEventFormActions({
    required this.editing,
    required this.saving,
    required this.onSave,
    required this.onCancel,
    super.key,
  });

  final bool editing;
  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(
          label: saving
              ? 'Saving...'
              : editing
                  ? 'Update Recovery Event'
                  : 'Save Recovery Event',
          icon: Icons.save_outlined,
          onPressed: saving ? () {} : onSave,
        ),
        if (editing) ...[
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.close_outlined),
              label: const Text('Cancel Edit'),
            ),
          ),
        ],
      ],
    );
  }
}
