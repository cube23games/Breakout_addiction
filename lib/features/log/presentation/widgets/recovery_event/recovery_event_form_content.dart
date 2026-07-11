import 'package:flutter/material.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_typography.dart';
import '../../../domain/recovery_event_entry.dart';
import '../../recovery_event_form_controller.dart';
import 'recovery_event_form_actions.dart';
import 'recovery_event_intensity_card.dart';
import 'recovery_event_reason_card.dart';
import 'recovery_event_text_card.dart';
import 'recovery_event_type_card.dart';

class RecoveryEventFormContent extends StatelessWidget {
  const RecoveryEventFormContent({
    required this.controller,
    required this.saving,
    required this.onTypeChanged,
    required this.onReasonChanged,
    required this.onIntensityChanged,
    required this.onSave,
    required this.onCancel,
    super.key,
  });

  final RecoveryEventFormController controller;
  final bool saving;
  final ValueChanged<RecoveryEventType> onTypeChanged;
  final ValueChanged<String> onReasonChanged;
  final ValueChanged<double> onIntensityChanged;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          controller.isEditing
              ? 'Correct the log honestly.'
              : 'Capture the moment honestly.',
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Urges, slips, and wins all teach you '
          'something when you name them clearly.',
          style: AppTypography.muted,
        ),
        const SizedBox(height: AppSpacing.lg),
        RecoveryEventTypeCard(
          value: controller.type,
          onChanged: onTypeChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        RecoveryEventReasonCard(
          value: controller.reason,
          customController:
              controller.customReasonController,
          onChanged: onReasonChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        RecoveryEventIntensityCard(
          value: controller.intensity,
          onChanged: onIntensityChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        RecoveryEventTextCard(
          title: 'Trigger',
          hintText:
              'Example: alone late at night, stressed '
              'after work, or bored on the couch...',
          controller: controller.triggerController,
          minLines: 2,
          maxLines: 3,
        ),
        const SizedBox(height: AppSpacing.md),
        RecoveryEventTextCard(
          title: 'Notes',
          hintText:
              'What happened? What did you notice? '
              'What helped or failed?',
          controller: controller.noteController,
          minLines: 3,
          maxLines: 5,
        ),
        const SizedBox(height: AppSpacing.lg),
        RecoveryEventFormActions(
          editing: controller.isEditing,
          saving: saving,
          onSave: onSave,
          onCancel: onCancel,
        ),
      ],
    );
  }
}
