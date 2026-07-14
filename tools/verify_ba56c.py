#!/usr/bin/env python3
from pathlib import Path
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]

SERVICE = (
    ROOT
    / 'lib/features/notifications/data/'
    / 'breakout_notification_service.dart'
)

PATCHER = ROOT / 'tools/patch_android_notifications.py'

ANDROID_NS = '{http://schemas.android.com/apk/res/android}'

failures = []

for path in (SERVICE, PATCHER):
    if not path.is_file():
        failures.append(f'missing file: {path}')

if SERVICE.is_file():
    service_text = SERVICE.read_text(encoding='utf-8')

    required_service_values = [
        "notificationIconName = 'ic_stat_breakout'",
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
        'android:fillColor="@android:color/transparent"',
        'android:strokeColor="#FFFFFFFF"',
        'android:fillColor="#FFFFFFFF"',
        'LEGACY_NOTIFICATION_ICON.unlink()',
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
                f'{PATCHER} still depends on full-color PNG logic: '
                f'{value}'
            )

if not failures:
    with tempfile.TemporaryDirectory(prefix='ba56c_') as directory:
        temp_root = Path(directory)

        manifest = (
            temp_root
            / 'android/app/src/main/AndroidManifest.xml'
        )

        drawable = (
            temp_root
            / 'android/app/src/main/res/drawable'
        )

        icon = drawable / 'ic_stat_breakout.xml'
        legacy_icon = drawable / 'ic_stat_breakout.png'

        manifest.parent.mkdir(parents=True, exist_ok=True)
        drawable.mkdir(parents=True, exist_ok=True)

        manifest.write_text(
            (
                '<manifest '
                'xmlns:android="http://schemas.android.com/apk/res/android" '
                'package="com.example.breakout">\n'
                '    <application android:label="Breakout Addiction">\n'
                '    </application>\n'
                '</manifest>\n'
            ),
            encoding='utf-8',
        )

        legacy_icon.write_bytes(
            b'legacy-full-color-png-placeholder'
        )

        # Run twice to prove the patch is idempotent as well as functional.
        for run_number in (1, 2):
            result = subprocess.run(
                [sys.executable, str(PATCHER)],
                cwd=temp_root,
                text=True,
                capture_output=True,
                check=False,
            )

            if result.returncode != 0:
                failures.append(
                    f'patcher run {run_number} failed with '
                    f'exit {result.returncode}: '
                    f'{result.stdout}{result.stderr}'
                )
                break

        if not icon.is_file():
            failures.append(
                f'patcher did not generate: {icon}'
            )
        else:
            icon_text = icon.read_text(encoding='utf-8')

            try:
                root = ET.fromstring(icon_text)
            except ET.ParseError as exc:
                failures.append(
                    f'generated icon is not valid XML: {exc}'
                )
            else:
                if root.tag != 'vector':
                    failures.append(
                        'generated icon root must be vector, '
                        f'got: {root.tag}'
                    )

                paths = list(root.findall('path'))

                if len(paths) < 2:
                    failures.append(
                        'generated icon must contain at least '
                        'two paths'
                    )

                paint_values = []

                for index, path in enumerate(paths, start=1):
                    path_data = path.attrib.get(
                        f'{ANDROID_NS}pathData',
                        '',
                    )

                    if not path_data.strip():
                        failures.append(
                            f'generated icon path {index} '
                            'has no pathData'
                        )

                    for attribute in (
                        'fillColor',
                        'strokeColor',
                    ):
                        value = path.attrib.get(
                            f'{ANDROID_NS}{attribute}'
                        )

                        if value is not None:
                            paint_values.append(value)

                allowed_paints = {
                    '#FFFFFFFF',
                    '@android:color/transparent',
                }

                unexpected_paints = sorted(
                    set(paint_values) - allowed_paints
                )

                if unexpected_paints:
                    failures.append(
                        'generated icon contains non-mask colors: '
                        f'{unexpected_paints}'
                    )

                if '#FFFFFFFF' not in paint_values:
                    failures.append(
                        'generated icon has no white mask artwork'
                    )

                if (
                    '@android:color/transparent'
                    not in paint_values
                ):
                    failures.append(
                        'generated icon does not preserve '
                        'transparency'
                    )

        if legacy_icon.exists():
            failures.append(
                'patcher did not remove legacy '
                'ic_stat_breakout.png'
            )

        manifest_text = manifest.read_text(
            encoding='utf-8'
        )

        required_manifest_values = [
            'android.permission.RECEIVE_BOOT_COMPLETED',
            'ScheduledNotificationReceiver',
            'ScheduledNotificationBootReceiver',
            'android.intent.action.BOOT_COMPLETED',
        ]

        for value in required_manifest_values:
            if value not in manifest_text:
                failures.append(
                    f'patched manifest missing: {value}'
                )

if failures:
    print('BA-56C verification failed:')

    for failure in failures:
        print(f' - {failure}')

    sys.exit(1)

print(
    'BA-56C verification passed: the real patcher succeeds in a '
    'temporary generated-Android workspace, writes a transparent '
    'white vector mask, removes the legacy PNG, and patches the '
    'manifest.'
)
