from pathlib import Path
import sys

REQUIRED_TEXT = {
    'lib/core/constants/route_names.dart':
        "static const recoveryEventLog = "
        "'/log/recovery-event';",
    'lib/features/log/domain/recovery_event_entry.dart':
        'enum RecoveryEventType',
    'lib/features/log/data/recovery_event_repository.dart':
        'class RecoveryEventRepository',
    'lib/features/log/presentation/recovery_event_log_screen.dart':
        'RecoveryEventFormContent',
    'lib/features/log/presentation/widgets/recovery_event/recovery_event_form_actions.dart':
        'Save Recovery Event',
    'lib/features/log/presentation/widgets/log_hub/log_hub_quick_actions_card.dart':
        'Log Urge / Relapse / Victory',
    'lib/features/log/presentation/log_hub_screen.dart':
        '_openRecoveryEventLog',
    'lib/app/app_router.dart':
        'case RouteNames.recoveryEventLog:',
}

failures = []

for filename, needle in REQUIRED_TEXT.items():
    path = Path(filename)

    if not path.exists():
        failures.append(f'missing file: {filename}')
        continue

    if needle not in path.read_text(encoding='utf-8'):
        failures.append(
            f'{filename} missing: {needle}'
        )

if failures:
    print('BA-18 verification failed:')

    for failure in failures:
        print(f' - {failure}')

    sys.exit(1)

print(
    'Breakout Addiction BA-18 modular logging '
    'verification passed.'
)
