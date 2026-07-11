#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {
    'lib/features/rescue/data/reasons_to_stop_repository.dart': [
        'Other',
    ],
    'lib/features/log/domain/recovery_event_entry.dart': [
        'reason',
        'trigger',
        'displayReason',
        'displayTrigger',
        "'trigger': trigger",
    ],
    'lib/features/log/data/recovery_event_repository.dart': [
        'reason',
        'trigger',
        'updateEntry',
        'deleteEntry',
    ],
    'lib/features/log/presentation/recovery_event_form_controller.dart': [
        "otherReason = 'Other'",
        'effectiveReason',
        'triggerController',
    ],
    'lib/features/log/presentation/recovery_event_log_screen.dart': [
        'Edit Recovery Event',
        'RecoveryEventSaveResult',
    ],
    'lib/features/log/presentation/log_hub_screen.dart': [
        '_confirmDeleteEvent',
        '_openRecoveryEventLog',
        "'Undo'",
    ],
    'lib/features/log/presentation/widgets/log_hub/recovery_event_delete_dialog.dart': [
        'showDialog',
        'Delete recovery event?',
        "Text('Delete')",
    ],
    'lib/features/log/presentation/widgets/log_hub/recovery_event_row.dart': [
        "Text('Edit')",
        "Text('Delete')",
        'displayTrigger',
    ],
    'lib/features/rescue/presentation/rescue_screen.dart': [
        'Use this as a quick gut-check',
    ],
    'lib/features/rescue/presentation/widgets/delay_actions_card.dart': [
        'SnackBarBehavior.floating',
        'backgroundColor: const Color(0xFF13212C)',
    ],
}

failures = []

for filename, needles in CHECKS.items():
    path = Path(filename)

    if not path.exists():
        failures.append(f'missing file: {filename}')
        continue

    text = path.read_text(encoding='utf-8')

    for needle in needles:
        if needle not in text:
            failures.append(
                f'{filename} missing: {needle}'
            )

if failures:
    print('BA-37 verification failed:')

    for failure in failures:
        print(f' - {failure}')

    sys.exit(1)

print('BA-37 modular logging verification passed.')
