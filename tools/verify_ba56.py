#!/usr/bin/env python3
from pathlib import Path
import hashlib
import sys

ICON_SHA256 = (
    '7cb24c5125c7dc32a1ddc5fe22a0f3a4'
    'b85c05c1efbd89e930232661ea6d94d3'
)

CHECKS = {
    'assets/branding/breakout_notification_icon.png': [],
    'lib/features/notifications/data/breakout_notification_service.dart': [
        "notificationIconName = 'ic_stat_breakout'",
        'fallbackNotificationIconName',
        'AndroidInitializationSettings(iconName)',
        'await _initializePlugin(fallbackNotificationIconName)',
        'icon: useCustomIcon ? notificationIconName : null',
        'useCustomIcon: true',
        'useCustomIcon: false',
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
        if hashlib.sha256(data).hexdigest() != ICON_SHA256:
            failures.append(
                f'{filename} does not match the bold actual-logo asset'
            )
        continue

    text = path.read_text(encoding='utf-8')
    for needle in needles:
        if needle not in text:
            failures.append(f'{filename} missing: {needle}')

if failures:
    print('BA-56 verification failed:')
    for failure in failures:
        print(f' - {failure}')
    sys.exit(1)

print(
    'BA-56 verification passed: Breakout explicitly applies the bold '
    'actual-logo silhouette to notifications with a safe fallback.'
)
