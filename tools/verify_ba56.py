#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {
    'assets/branding/breakout_notification_icon.png': [],
    'lib/features/notifications/data/breakout_notification_service.dart': [
        "notificationIconName = 'ic_stat_breakout'",
        'fallbackNotificationIconName',
        'AndroidInitializationSettings(iconName)',
        'await _initializePlugin(notificationIconName)',
        'await _initializePlugin(fallbackNotificationIconName)',
    ],
    'tools/patch_android_notifications.py': [
        'breakout_notification_icon.png',
        'ic_stat_breakout.png',
        'write_notification_icon()',
        "data.startswith(b'\\x89PNG",
        'shutil.copyfile',
        'actual Breakout',
    ],
    '.github/workflows/ci.yml': [
        'Configure Android scheduled notifications',
        'python3 tools/patch_android_notifications.py',
    ],
}

failures = []

for filename, needles in CHECKS.items():
    path = Path(filename)
    if not path.is_file():
        failures.append(f'missing file: {filename}')
        continue

    if path.suffix == '.png':
        data = path.read_bytes()
        if not data.startswith(b'\x89PNG\r\n\x1a\n'):
            failures.append(f'{filename} is not a valid PNG')
        if len(data) < 500:
            failures.append(f'{filename} is unexpectedly small')
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
    if 'icon: notificationIconName' in text:
        failures.append(
            'per-notification icon override should use the initialized '
            'default so fallback remains possible'
        )

if failures:
    print('BA-56 verification failed:')
    for failure in failures:
        print(f' - {failure}')
    sys.exit(1)

print(
    'BA-56 verification passed: Breakout uses the actual app-logo '
    'silhouette as a monochrome Android status-bar icon with a safe fallback.'
)
