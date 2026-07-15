#!/usr/bin/env python3
from pathlib import Path
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]

SERVICE = ROOT / (
    'lib/features/notifications/data/'
    'breakout_notification_service.dart'
)

COORDINATOR = ROOT / (
    'lib/features/rescue/presentation/widgets/'
    'delay_completion_notification_coordinator.dart'
)

CARD = ROOT / (
    'lib/features/rescue/presentation/widgets/'
    'delay_actions_card.dart'
)

PATCHER = ROOT / 'tools/patch_android_notifications.py'
CI = ROOT / '.github/workflows/ci.yml'

ANDROID_NS = '{http://schemas.android.com/apk/res/android}'
TOOLS_NS = '{http://schemas.android.com/tools}'

failures = []


def require(path: Path, text: str, values: list[str]) -> None:
    for value in values:
        if value not in text:
            failures.append(f'{path} missing: {value}')


paths = (
    SERVICE,
    COORDINATOR,
    CARD,
    PATCHER,
    CI,
)

for path in paths:
    if not path.is_file():
        failures.append(f'missing file: {path}')

if SERVICE.is_file():
    service = SERVICE.read_text(encoding='utf-8')

    require(
        SERVICE,
        service,
        [
            'class DelayNotificationScheduleOutcome',
            'requestExactAlarmsPermission()',
            'AndroidScheduleMode.exactAllowWhileIdle',
            'AndroidScheduleMode.inexactAllowWhileIdle',
            'pendingNotificationRequests()',
            'preferExact',
            'scheduleMode: scheduleMode',
            'useCustomIcon: true',
            'useCustomIcon: false',
        ],
    )

    daily_start = service.find(
        'Future<void> _scheduleDailyReminder'
    )
    delay_start = service.find(
        'scheduleDelayCompletion('
    )

    if daily_start < 0 or delay_start < 0:
        failures.append(
            'could not isolate daily and Rescue scheduling sections'
        )
    else:
        daily_section = service[daily_start:delay_start]

        if (
            'AndroidScheduleMode.inexactAllowWhileIdle'
            not in daily_section
        ):
            failures.append(
                'daily reminders must remain inexact'
            )

        if (
            'AndroidScheduleMode.exactAllowWhileIdle'
            in daily_section
        ):
            failures.append(
                'daily reminders must not require exact alarms'
            )

if COORDINATOR.is_file():
    coordinator = COORDINATOR.read_text(encoding='utf-8')

    require(
        COORDINATOR,
        coordinator,
        [
            'required this.exact',
            'final bool exact;',
            'requestExactAlarmPermission()',
            'package:shared_preferences/shared_preferences.dart',
            '_exactAlarmPromptedKey',
            'rescue_exact_alarm_prompted_v1',
            'SharedPreferences.getInstance()',
            'preferences.setBool(',
            'preferExact: preferExact',
            'exact: outcome.exact',
        ],
    )

if CARD.is_file():
    card = CARD.read_text(encoding='utf-8')

    require(
        CARD,
        card,
        [
            '_usesExactCompletionAlert',
            '_completionCleanupStarted',
            'unawaited(_notifications.cancel())',
            'Android may delay the',
            'precise alarms are off',
            'Alarms & reminders',
        ],
    )

if PATCHER.is_file():
    patcher = PATCHER.read_text(encoding='utf-8')

    require(
        PATCHER,
        patcher,
        [
            'android.permission.SCHEDULE_EXACT_ALARM',
            'KEEP_RULES_XML',
            'tools:keep=',
            '@drawable/ic_stat_breakout',
            '@mipmap/ic_launcher',
            'brand-faithful monochrome icon',
            'refined thinner brand silhouette proportions',
            'android:fillColor="#FFFFFFFF"',
            'M6.2,18.0',
            'C4.7,16.5 3.8,14.3 3.8,11.8',
            'M17.8,18.0',
            'M11.4,20.6',
            'M12.0,1.9',
        ],
    )

    forbidden = [
        'android:strokeColor=',
        'android:strokeWidth=',
        'import shutil',
        'shutil.copyfile',
        'M6.0,18.1',
        'M18.0,18.1',
        'M11.2,21.0',
    ]

    for value in forbidden:
        if value in patcher:
            failures.append(
                f'{PATCHER} contains forbidden value: {value}'
            )

if CI.is_file():
    ci = CI.read_text(encoding='utf-8')

    require(
        CI,
        ci,
        [
            'Verify notification icon in release APK',
            "archive.read('resources.arsc')",
            "resource_name = 'ic_stat_breakout'",
            'Release APK stripped @drawable/ic_stat_breakout',
        ],
    )

if not failures:
    with tempfile.TemporaryDirectory(
        prefix='ba56f_'
    ) as directory:
        temp_root = Path(directory)

        manifest = (
            temp_root
            / 'android/app/src/main/AndroidManifest.xml'
        )

        drawable = (
            temp_root
            / 'android/app/src/main/res/drawable'
        )

        raw = (
            temp_root
            / 'android/app/src/main/res/raw'
        )

        icon = drawable / 'ic_stat_breakout.xml'
        legacy_icon = drawable / 'ic_stat_breakout.png'
        keep_rules = raw / 'keep.xml'

        manifest.parent.mkdir(parents=True, exist_ok=True)
        drawable.mkdir(parents=True, exist_ok=True)

        manifest.write_text(
            (
                '<manifest '
                'xmlns:android='
                '"http://schemas.android.com/apk/res/android" '
                'package="com.example.breakout">\n'
                '    <application '
                'android:label="Breakout Addiction">\n'
                '    </application>\n'
                '</manifest>\n'
            ),
            encoding='utf-8',
        )

        legacy_icon.write_bytes(b'legacy-png')

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
                    f'patcher run {run_number} failed: '
                    f'{result.stdout}{result.stderr}'
                )
                break

        manifest_text = manifest.read_text(
            encoding='utf-8'
        )

        for value in (
            'android.permission.RECEIVE_BOOT_COMPLETED',
            'android.permission.SCHEDULE_EXACT_ALARM',
            'ScheduledNotificationReceiver',
            'ScheduledNotificationBootReceiver',
        ):
            if value not in manifest_text:
                failures.append(
                    f'patched manifest missing: {value}'
                )

        if legacy_icon.exists():
            failures.append(
                'legacy notification PNG was not removed'
            )

        if not icon.is_file():
            failures.append(
                'brand notification vector was not generated'
            )
        else:
            try:
                vector_root = ET.fromstring(
                    icon.read_text(encoding='utf-8')
                )
            except ET.ParseError as exc:
                failures.append(
                    f'notification vector is invalid XML: {exc}'
                )
            else:
                vector_paths = list(vector_root.findall('path'))

                if len(vector_paths) != 6:
                    failures.append(
                        'notification vector must contain exactly six '
                        'filled brand-shape paths'
                    )

                for index, path in enumerate(vector_paths, start=1):
                    fill = path.attrib.get(
                        f'{ANDROID_NS}fillColor'
                    )

                    data = path.attrib.get(
                        f'{ANDROID_NS}pathData',
                        '',
                    )

                    if fill != '#FFFFFFFF':
                        failures.append(
                            f'notification path {index} must be '
                            'solid white'
                        )

                    if not data.strip():
                        failures.append(
                            f'notification path {index} has empty pathData'
                        )

                    for attribute in (
                        'strokeColor',
                        'strokeWidth',
                    ):
                        if (
                            f'{ANDROID_NS}{attribute}'
                            in path.attrib
                        ):
                            failures.append(
                                'notification glyph must not use '
                                f'{attribute}'
                            )

        if not keep_rules.is_file():
            failures.append(
                'release resource keep.xml was not generated'
            )
        else:
            try:
                keep_root = ET.fromstring(
                    keep_rules.read_text(encoding='utf-8')
                )
            except ET.ParseError as exc:
                failures.append(
                    f'keep.xml is invalid XML: {exc}'
                )
            else:
                keep_value = keep_root.attrib.get(
                    f'{TOOLS_NS}keep',
                    '',
                )

                for resource in (
                    '@drawable/ic_stat_breakout',
                    '@mipmap/ic_launcher',
                ):
                    if resource not in keep_value:
                        failures.append(
                            f'keep.xml does not protect {resource}'
                        )

if failures:
    print('BA-56F verification failed:')

    for failure in failures:
        print(f' - {failure}')

    sys.exit(1)

print(
    'BA-56F verification passed: Rescue completion prefers an exact '
    'alarm, retains an honest inexact fallback, verifies its pending '
    'request, cancels late foreground fallbacks, restores a '
    'thinner brand-faithful notification silhouette, protects it from '
    'resource shrinking, and makes CI inspect the release APK.'
)
