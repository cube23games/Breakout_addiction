import 'package:flutter/material.dart';

import '../domain/recovery_event_entry.dart';

class RecoveryEventFormController {
  RecoveryEventFormController({
    RecoveryEventEntry? initialEntry,
  }) : initialEntry = initialEntry,
       triggerController = TextEditingController(
         text: initialEntry?.displayTrigger == 'No trigger added.'
             ? ''
             : initialEntry?.displayTrigger ?? '',
       ),
       noteController = TextEditingController(
         text: initialEntry?.note ?? '',
       ),
       customReasonController = TextEditingController() {
    if (initialEntry == null) {
      return;
    }

    type = initialEntry.type;
    intensity = initialEntry.intensity.toDouble();

    final cleanedReason = initialEntry.reason.trim();

    if (reasonOptions.contains(cleanedReason)) {
      reason = cleanedReason;
    } else {
      reason = otherReason;
      customReasonController.text = cleanedReason;
    }
  }

  static const String otherReason = 'Other';

  static const List<String> reasonOptions = [
    'Stress',
    'Loneliness',
    'Boredom',
    'Anger',
    'Late night',
    'Social media',
    otherReason,
  ];

  final RecoveryEventEntry? initialEntry;
  final TextEditingController triggerController;
  final TextEditingController noteController;
  final TextEditingController customReasonController;

  RecoveryEventType type = RecoveryEventType.urge;
  double intensity = 5;
  String reason = 'Stress';

  bool get isEditing => initialEntry != null;

  String get effectiveReason {
    if (reason != otherReason) {
      return reason;
    }

    final custom = customReasonController.text.trim();
    return custom.isEmpty ? otherReason : custom;
  }

  RecoveryEventEntry buildEntry() {
    final trigger = triggerController.text.trim();

    return RecoveryEventEntry(
      timestamp:
          initialEntry?.timestamp ?? DateTime.now(),
      type: type,
      intensity: intensity.round(),
      reason: effectiveReason,
      trigger: trigger,
      context: trigger,
      note: noteController.text.trim(),
    );
  }

  void dispose() {
    triggerController.dispose();
    noteController.dispose();
    customReasonController.dispose();
  }
}
