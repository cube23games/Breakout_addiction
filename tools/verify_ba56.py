#!/usr/bin/env python3
from pathlib import Path
import sys

SERVICE = Path(
    'lib/features/notifications/data/'
    'breakout_notification_service.dart'
)
PATCHER = Path('tools/patch_android_notifications.py')
CI = Path('.github/workflows/ci.yml')

failures = []

for path in (SERVICE, PATCHER, CI):
    if not path.is_file():
        failures.append(f'missing file: {path}')

if SERVICE.is_file():
    service_text = SERVICE.read_text(encoding='utf-8')

    required_service_values = [
        "notificationIconName = 'ic_stat_breakout'",
        'fallbackNotificationIconName',
        'AndroidInitializationSettings(iconName)',
        'await _initializePlugin(fallbackNotificationIconName)',
        'icon: useCustomIcon ? notificationIconName : null',
        'useCustomIcon: true',
        'useCustomIcon: false',
    ]

    for value in required_service_values:
        if value not in service_text:
            failures.append(f'{SERVICE} missing: {value}')

if PATCHER.is_file():
    patcher_text = PATCHER.read_text(encoding='utf-8')

    required_patcher_values = [
        'ic_stat_breakout.xml',
        'VECTOR_ICON_XML',
        'android:fillColor="#FFFFFFFF"',
        'KEEP_RULES_XML',
        'tools:keep=',
        '@drawable/ic_stat_breakout',
        'android.permission.SCHEDULE_EXACT_ALARM',
        'LEGACY_NOTIFICATION_ICON',
        'ic_stat_breakout.png',
        'LEGACY_NOTIFICATION_ICON.unlink()',
        'monochrome icon',
    ]

    forbidden_patcher_values = [
        'import shutil',
        'shutil.copyfile',
        'SOURCE_NOTIFICATION_ICON',
        'assets/branding/breakout_notification_icon.png',
    ]

    for value in required_patcher_values:
        if value not in patcher_text:
            failures.append(f'{PATCHER} missing: {value}')

    for value in forbidden_patcher_values:
        if value in patcher_text:
            failures.append(
                f'{PATCHER} still contains obsolete PNG-copy logic: '
                f'{value}'
            )

if CI.is_file():
    ci_text = CI.read_text(encoding='utf-8')

    create_step = (
        'flutter create --platforms=android '
        '--project-name breakout_addiction .'
    )
    patch_step = 'python3 tools/patch_android_notifications.py'

    required_ci_values = [
        'Create platform folders if missing',
        create_step,
        'Configure Android scheduled notifications',
        patch_step,
    ]

    for value in required_ci_values:
        if value not in ci_text:
            failures.append(f'{CI} missing: {value}')

    create_index = ci_text.find(create_step)
    patch_index = ci_text.find(patch_step)

    if (
        create_index < 0
        or patch_index < 0
        or create_index > patch_index
    ):
        failures.append(
            'CI must generate android/ before running the '
            'notification patcher'
        )

if failures:
    print('BA-56 verification failed:')

    for failure in failures:
        print(f' - {failure}')

    sys.exit(1)

print(
    'BA-56 verification passed: notifications retain the BA-56B '
    'custom-icon fallback logic, CI generates Android before patching, '
    'and the patcher generates a monochrome vector mask.'
)
