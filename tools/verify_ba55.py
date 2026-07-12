#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {
    'lib/features/onboarding/presentation/widgets/welcome_banner_overlay.dart': [
        'Duration(milliseconds: 4500)',
        'onTap: _dismiss',
        'AppTypography.body',
        'surfaceContainerHighest',
    ],
    'lib/features/notifications/data/breakout_notification_service.dart': [
        'delayChannelId',
        'delayCompletionNotificationId',
        'Future<bool> requestPermissions()',
        'scheduleDelayCompletion',
        'Countdown is complete',
        'AndroidScheduleMode.inexactAllowWhileIdle',
    ],
    'lib/features/rescue/presentation/widgets/delay_completion_notification_coordinator.dart': [
        'class DelayCompletionNotificationCoordinator',
        'requestPermissions',
        'scheduleDelayCompletion',
        'cancelDelayCompletion',
    ],
    'lib/features/rescue/presentation/widgets/delay_actions_card.dart': [
        'Breakout will notify you when it ends.',
        'Countdown canceled.',
        'SnackBarBehavior.floating',
        'backgroundColor: const Color(0xFF13212C)',
        'onCancel: _cancelDelay',
        'onFinish: _finishDelay',
    ],
    'tools/patch_android_notifications.py': [
        'android.permission.RECEIVE_BOOT_COMPLETED',
        'ScheduledNotificationReceiver',
        'ScheduledNotificationBootReceiver',
    ],
    '.github/workflows/ci.yml': [
        'Configure Android scheduled notifications',
        'python3 tools/patch_android_notifications.py',
    ],
    'lib/features/accountability/domain/accountability_summary_item.dart': [
        'enum AccountabilityDataStatus',
        'available',
        'empty',
        'unavailable',
    ],
    'lib/features/accountability/data/accountability_summary_repository.dart': [
        'buildItems',
        'No recovery activity has been recorded yet.',
        'No urge events have been recorded yet.',
        'A recovery plan has not been completed yet.',
        'This is a simple local signal, not a clinical assessment.',
    ],
    'lib/features/accountability/presentation/widgets/accountability_summary_item_card.dart': [
        'Shared data',
        'No data yet',
        'Unavailable',
    ],
    'lib/features/accountability/presentation/accountability_summary_screen.dart': [
        'AccountabilitySummaryRepository',
        'Refresh shared data',
        'Shared summary areas',
        'AccountabilitySummaryItemCard',
        'Private notes are not shared.',
    ],
}

FORBIDDEN = {
    'lib/features/onboarding/presentation/widgets/welcome_banner_overlay.dart': [
        'Duration(milliseconds: 1700)',
        'Duration(milliseconds: 1500)',
    ],
}

failures = []

for filename, needles in CHECKS.items():
    path = Path(filename)
    if not path.is_file():
        failures.append(f'missing file: {filename}')
        continue
    text = path.read_text(encoding='utf-8')
    for needle in needles:
        if needle not in text:
            failures.append(f'{filename} missing: {needle}')

for filename, needles in FORBIDDEN.items():
    path = Path(filename)
    if not path.is_file():
        continue
    text = path.read_text(encoding='utf-8')
    for needle in needles:
        if needle in text:
            failures.append(f'{filename} still contains: {needle}')

delay_card = Path(
    'lib/features/rescue/presentation/widgets/delay_actions_card.dart'
)
if delay_card.is_file():
    lines = len(delay_card.read_text(encoding='utf-8').splitlines())
    if lines > 190:
        failures.append(
            f'{delay_card} is {lines} lines; maximum is 190'
        )

if failures:
    print('BA-55 verification failed:')
    for failure in failures:
        print(f' - {failure}')
    sys.exit(1)

print(
    'BA-55 verification passed: welcome readability, Rescue completion '
    'alerts, cancellation feedback, and real accountability data are wired.'
)
