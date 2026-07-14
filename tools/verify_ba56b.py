#!/usr/bin/env python3
from pathlib import Path
import sys

SERVICE = Path(
    'lib/features/notifications/data/'
    'breakout_notification_service.dart'
)

REQUIRED = [
    'Future<bool> notificationsEnabled()',
    'areNotificationsEnabled()',
    'final alreadyEnabled =',
    'final refreshed =',
    'return refreshed ?? requested ?? false;',
    'icon: useCustomIcon ? notificationIconName : null',
    '_scheduleDailyReminder(',
    '_scheduleDelayCompletion(',
    'useCustomIcon: true',
    'useCustomIcon: false',
]

failures = []

if not SERVICE.is_file():
    failures.append(f'missing file: {SERVICE}')
else:
    text = SERVICE.read_text(encoding='utf-8')

    for needle in REQUIRED:
        if needle not in text:
            failures.append(f'{SERVICE} missing: {needle}')

    first_read = text.find('final alreadyEnabled =')
    request = text.find('requestNotificationsPermission()')
    second_read = text.find('final refreshed =')

    if not (
        first_read >= 0
        and request > first_read
        and second_read > request
    ):
        failures.append(
            'Android permission must be read before and after the request'
        )

    if text.count('areNotificationsEnabled()') < 3:
        failures.append(
            'Android live notification status is not checked often enough'
        )

    if text.count('useCustomIcon: true') < 2:
        failures.append(
            'Both reminder types must try the Breakout icon'
        )

    if text.count('useCustomIcon: false') < 2:
        failures.append(
            'Both reminder types must retain a safe fallback'
        )

if failures:
    print('BA-56B verification failed:')
    for failure in failures:
        print(f' - {failure}')
    sys.exit(1)

print(
    'BA-56B verification passed: Android notification permission is '
    're-read from the OS and both reminder types explicitly use the '
    'visible Breakout status-bar icon with fallback.'
)
