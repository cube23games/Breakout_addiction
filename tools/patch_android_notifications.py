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

# Android notification small icons are monochrome system-tinted masks.
# This drawable restores the actual Breakout Addiction brand mark as a
# simplified silhouette:
# - broken circular barrier
# - bold center path breaking through
# - a few large breakout shards at the top
# - white artwork only
# - no dark square background
# - no gradients, shadows, or tiny detail
VECTOR_ICON_XML = """<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">

    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M6.0,18.1
            C4.2,16.5 3.2,14.3 3.2,11.8
            C3.2,7.4 6.1,3.8 10.3,2.8
            L10.9,5.5
            C8.1,6.2 6.1,8.7 6.1,11.8
            C6.1,13.0 6.4,14.0 7.0,15.0
            L8.2,14.0
            L8.9,17.7
            C7.9,18.2 6.9,18.3 6.0,18.1
            Z" />

    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M18.0,18.1
            C19.8,16.5 20.8,14.3 20.8,11.8
            C20.8,7.4 17.9,3.8 13.7,2.8
            L13.1,5.5
            C15.9,6.2 17.9,8.7 17.9,11.8
            C17.9,13.0 17.6,14.0 17.0,15.0
            L15.8,14.0
            L15.1,17.7
            C16.1,18.2 17.1,18.3 18.0,18.1
            Z" />

    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M11.2,21.0
            L8.7,19.5
            L10.2,14.3
            C10.5,13.3 10.7,12.5 10.5,11.6
            C10.2,10.4 9.4,9.5 8.5,8.6
            L10.3,6.1
            C12.1,7.5 13.8,9.1 14.3,11.2
            C14.8,13.5 13.8,15.5 13.2,17.2
            L14.8,17.2
            L11.2,21.0
            Z" />

    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M9.3,2.0
            L7.9,3.8
            L9.5,4.5
            L10.2,3.0
            Z" />

    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M12.0,1.4
            L11.4,4.5
            L12.6,4.5
            Z" />

    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M14.7,2.0
            L13.8,3.0
            L14.5,4.5
            L16.1,3.8
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
        'Android exact Rescue alarms, notification receivers, '
        'brand-faithful monochrome icon, and release keep rules configured.'
    )
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
