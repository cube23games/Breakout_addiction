#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {
    'lib/features/rescue/presentation/widgets/delay_actions_card.dart': [
        'RecoveryEventSaveResult',
        'Future<void> _openRecoveryEventLog()',
        'result.message',
    ],
    'lib/features/log/presentation/log_hub_screen.dart': [
        'LogHubController',
        'LogHubQuickActionsCard',
        'RecentStageLogsCard',
        'RecentRecoveryEventsCard',
        'RecoveryEventSaveResult',
        '_confirmDeleteEvent',
    ],
    'lib/features/log/presentation/log_hub_controller.dart': [
        'class LogHubController',
        'stageEntriesFuture',
        'eventEntriesFuture',
        'deleteEvent',
        'restoreEvent',
    ],
    'lib/features/log/presentation/recovery_event_log_screen.dart': [
        'RecoveryEventFormController',
        'RecoveryEventFormContent',
        'RecoveryEventSaveResult',
        'Navigator.pop',
    ],
    'lib/features/log/presentation/widgets/log_hub/recent_stage_logs_card.dart': [
        'FutureBuilder<List<CycleStageLogEntry>>',
        'StageLogRow',
    ],
    'lib/features/log/presentation/widgets/log_hub/recent_recovery_events_card.dart': [
        'FutureBuilder<List<RecoveryEventEntry>>',
        'RecoveryEventRow',
    ],
    'lib/features/log/presentation/widgets/log_hub/recovery_event_row.dart': [
        'displayReason',
        'displayTrigger',
        "Text('Edit')",
        "Text('Delete')",
    ],
}

LIMITS = {
    'lib/features/log/presentation/log_hub_screen.dart': 180,
    'lib/features/log/presentation/log_hub_controller.dart': 80,
    'lib/features/log/presentation/recovery_event_log_screen.dart': 130,
    'lib/features/log/presentation/recovery_event_form_controller.dart': 120,
    'lib/features/log/presentation/widgets/log_hub/log_hub_intro_card.dart': 60,
    'lib/features/log/presentation/widgets/log_hub/log_hub_quick_actions_card.dart': 90,
    'lib/features/log/presentation/widgets/log_hub/recent_stage_logs_card.dart': 110,
    'lib/features/log/presentation/widgets/log_hub/stage_log_row.dart': 70,
    'lib/features/log/presentation/widgets/log_hub/recent_recovery_events_card.dart': 120,
    'lib/features/log/presentation/widgets/log_hub/recovery_event_row.dart': 110,
    'lib/features/log/presentation/widgets/log_hub/recovery_event_delete_dialog.dart': 70,
    'lib/features/log/presentation/widgets/log_hub/log_hub_bottom_navigation.dart': 90,
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

for filename, maximum in LIMITS.items():
    path = Path(filename)

    if not path.exists():
        failures.append(f'missing file: {filename}')
        continue

    lines = len(
        path.read_text(
            encoding='utf-8',
        ).splitlines()
    )

    if lines > maximum:
        failures.append(
            f'{filename} is {lines} lines; '
            f'maximum is {maximum}'
        )

if failures:
    print('BA-51 logging verification failed:')

    for failure in failures:
        print(f' - {failure}')

    sys.exit(1)

print(
    'BA-51 logging verification passed: '
    'Log Hub and recovery-event forms are modular.'
)
