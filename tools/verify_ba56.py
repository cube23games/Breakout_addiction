#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {
    'lib/features/notifications/data/breakout_notification_service.dart': [
        "notificationIconName = 'ic_stat_breakout'",
        'AndroidInitializationSettings(notificationIconName)',
        'icon: notificationIconName',
    ],
    'tools/patch_android_notifications.py': [
        'ic_stat_breakout.xml',
        'NOTIFICATION_ICON_XML',
        'android:viewportWidth="24"',
        'android:strokeColor="#FFFFFFFF"',
        'M7.75,6 L7.75,18',
        'write_notification_icon()',
    ],
    '.github/workflows/ci.yml': [
        'Configure Android scheduled notifications',
        'python3 tools/patch_android_notifications.py',
    ],
}

FORBIDDEN = {
    'lib/features/notifications/data/breakout_notification_service.dart': [
        "@mipmap/ic_launcher",
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

service = Path(
    'lib/features/notifications/data/breakout_notification_service.dart'
)
if service.is_file():
    text = service.read_text(encoding='utf-8')
    if text.count('icon: notificationIconName') < 2:
        failures.append(
            'notification icon must be set on both Android channels'
        )

for filename, needles in FORBIDDEN.items():
    path = Path(filename)
    if not path.is_file():
        continue

    text = path.read_text(encoding='utf-8')
    for needle in needles:
        if needle in text:
            failures.append(f'{filename} still contains: {needle}')

if failures:
    print('BA-56 verification failed:')
    for failure in failures:
        print(f' - {failure}')
    sys.exit(1)

print(
    'BA-56 verification passed: Breakout notifications use a dedicated '
    'monochrome B/O status-bar icon instead of the launcher square.'
)
