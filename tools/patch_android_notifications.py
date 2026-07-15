#!/usr/bin/env python3
from pathlib import Path
import re
import sys

MANIFEST = Path('android/app/src/main/AndroidManifest.xml')

NOTIFICATION_ICON = Path(
    'android/app/src/main/res/drawable/ic_stat_breakout.xml'
)

LEGACY_NOTIFICATION_ICON = Path(
    'android/app/src/main/res/drawable/ic_stat_breakout.png'
)

KEEP_RULES = Path(
    'android/app/src/main/res/raw/keep.xml'
)

BOOT_PERMISSION = (
    '<uses-permission '
    'android:name="android.permission.RECEIVE_BOOT_COMPLETED" />'
)

EXACT_ALARM_PERMISSION = (
    '<uses-permission '
    'android:name="android.permission.SCHEDULE_EXACT_ALARM" />'
)

PERMISSIONS = (
    BOOT_PERMISSION,
    EXACT_ALARM_PERMISSION,
)

RECEIVERS = """        <receiver
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"
            android:exported="false" />
        <receiver
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
            android:exported="false">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON" />
            </intent-filter>
        </receiver>
"""

# Android supplies the colored circular badge around a notification small icon.
# The drawable therefore contains one large solid breakout bolt only:
# - no duplicate outer ring
# - no strokes
# - no tiny interior detail
# - white monochrome mask artwork
VECTOR_ICON_XML = """<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">

    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M14.5,1.5
            L5.2,13.0
            L10.7,13.0
            L9.0,22.5
            L19.0,9.7
            L13.5,9.7
            Z" />

</vector>
"""

KEEP_RULES_XML = """<?xml version="1.0" encoding="utf-8"?>
<resources xmlns:tools="http://schemas.android.com/tools"
    tools:keep="@drawable/ic_stat_breakout,@mipmap/ic_launcher" />
"""


def insert_permission(text: str, permission: str) -> str:
    if permission in text:
        return text

    match = re.search(r'<manifest\b[^>]*>', text, flags=re.DOTALL)

    if match is None:
        raise ValueError('Could not find <manifest> element.')

    return (
        text[:match.end()]
        + '\n    '
        + permission
        + text[match.end():]
    )


def write_notification_resources() -> None:
    NOTIFICATION_ICON.parent.mkdir(parents=True, exist_ok=True)
    KEEP_RULES.parent.mkdir(parents=True, exist_ok=True)

    if LEGACY_NOTIFICATION_ICON.exists():
        LEGACY_NOTIFICATION_ICON.unlink()

    NOTIFICATION_ICON.write_text(
        VECTOR_ICON_XML,
        encoding='utf-8',
    )

    KEEP_RULES.write_text(
        KEEP_RULES_XML,
        encoding='utf-8',
    )


def main() -> int:
    if not MANIFEST.is_file():
        print(
            f'Missing generated manifest: {MANIFEST}',
            file=sys.stderr,
        )
        return 1

    text = MANIFEST.read_text(encoding='utf-8')

    try:
        for permission in PERMISSIONS:
            text = insert_permission(text, permission)
    except ValueError as exc:
        print(str(exc), file=sys.stderr)
        return 1

    receiver_name = (
        'com.dexterous.flutterlocalnotifications.'
        'ScheduledNotificationReceiver'
    )

    if receiver_name not in text:
        marker = '    </application>'

        if marker not in text:
            print(
                'Could not find </application> marker.',
                file=sys.stderr,
            )
            return 1

        text = text.replace(
            marker,
            RECEIVERS + marker,
            1,
        )

    MANIFEST.write_text(text, encoding='utf-8')
    write_notification_resources()

    required_manifest_values = [
        BOOT_PERMISSION,
        EXACT_ALARM_PERMISSION,
        'ScheduledNotificationReceiver',
        'ScheduledNotificationBootReceiver',
        'android.intent.action.BOOT_COMPLETED',
    ]

    missing_manifest_values = [
        item
        for item in required_manifest_values
        if item not in text
    ]

    if missing_manifest_values:
        print(
            f'Manifest patch incomplete: {missing_manifest_values}',
            file=sys.stderr,
        )
        return 1

    if NOTIFICATION_ICON.read_text(
        encoding='utf-8',
    ) != VECTOR_ICON_XML:
        print(
            'Generated notification vector does not match its source.',
            file=sys.stderr,
        )
        return 1

    if KEEP_RULES.read_text(
        encoding='utf-8',
    ) != KEEP_RULES_XML:
        print(
            'Generated notification keep rules do not match their source.',
            file=sys.stderr,
        )
        return 1

    if LEGACY_NOTIFICATION_ICON.exists():
        print(
            'Legacy notification PNG still exists.',
            file=sys.stderr,
        )
        return 1

    print(
        'Android exact Rescue alarms, notification receivers, bold '
        'monochrome icon, and release keep rules configured.'
    )
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
