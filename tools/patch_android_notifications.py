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
# - visibly broken circular barrier with asymmetric arc endings
# - wider, more decisive center path breaking through
# - two larger detached breakout shards
# - clearer negative space through the top opening
# - white artwork only
# - no dark square background
# - no gradients, shadows, strokes, or tiny detail
# - recognition-focused brand silhouette geometry
VECTOR_ICON_XML = """<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">

    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M6.3,18.1
            C4.8,16.7 3.9,14.5 3.9,11.9
            C3.9,8.0 6.2,4.9 9.5,3.9
            L10.0,5.4
            C7.6,6.2 5.7,8.7 5.7,11.9
            C5.7,13.5 6.2,14.9 7.0,15.9
            L8.0,15.0
            L8.4,17.2
            C7.7,17.7 7.0,18.1 6.3,18.1
            Z" />

    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M17.5,18.4
            C19.1,16.9 20.0,14.6 20.0,11.8
            C20.0,8.0 17.9,5.1 14.6,3.9
            L14.0,5.4
            C16.4,6.3 18.1,8.7 18.1,11.8
            C18.1,13.5 17.7,14.9 16.8,16.1
            L15.8,15.1
            L15.4,17.4
            C16.1,18.0 16.9,18.4 17.5,18.4
            Z" />

    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M11.4,20.8
            L9.0,19.2
            L10.4,14.2
            C10.8,13.1 10.9,12.3 10.6,11.3
            C10.3,10.1 9.4,9.2 8.7,8.5
            L10.2,6.3
            C12.2,7.7 13.8,9.4 14.3,11.5
            C14.8,13.6 13.9,15.5 13.2,17.1
            L14.8,17.0
            L11.4,20.8
            Z" />

    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M9.0,1.6
            L7.8,2.9
            L9.5,3.5
            L10.2,2.2
            Z" />

    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M14.8,1.5
            L13.6,2.6
            L14.7,3.6
            L16.1,2.6
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
