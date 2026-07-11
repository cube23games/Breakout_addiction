import 'package:flutter/material.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_typography.dart';
import '../../../../cycle/domain/cycle_stage.dart';
import '../../../domain/cycle_stage_log_entry.dart';

class StageLogRow extends StatelessWidget {
  const StageLogRow({
    required this.entry,
    super.key,
  });

  final CycleStageLogEntry entry;

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
            entry.stage.title,
            style: AppTypography.section,
          ),
          const SizedBox(height: 4),
          Text(
            'Intensity: ${entry.intensity}/10',
            style: AppTypography.muted,
          ),
          const SizedBox(height: 4),
          Text(
            note,
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}
