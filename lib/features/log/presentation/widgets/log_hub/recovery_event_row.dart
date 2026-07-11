import 'package:flutter/material.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_typography.dart';
import '../../../domain/recovery_event_entry.dart';

class RecoveryEventRow extends StatelessWidget {
  const RecoveryEventRow({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final RecoveryEventEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final note = entry.note.isEmpty
        ? 'No note added.'
        : entry.note;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF263041),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.type.label,
            style: AppTypography.section,
          ),
          const SizedBox(height: 4),
          Text(
            'Reason: ${entry.displayReason}',
            style: AppTypography.muted,
          ),
          const SizedBox(height: 4),
          Text(
            'Trigger: ${entry.displayTrigger}',
            style: AppTypography.muted,
          ),
          const SizedBox(height: 4),
          Text(
            'Intensity: ${entry.intensity}/10',
            style: AppTypography.muted,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            note,
            style: AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit_outlined,
                ),
                label: const Text('Edit'),
              ),
              OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                ),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
