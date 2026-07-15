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
# - refined thinner brand silhouette proportions
VECTOR_ICON_XML = """<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">

    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M6.2,18.0
            C4.7,16.5 3.8,14.3 3.8,11.8
            C3.8,7.8 6.4,4.4 10.2,3.4
            L10.6,4.9
            C7.6,5.8 5.6,8.5 5.6,11.8
            C5.6,13.3 6.0,14.6 6.8,15.7
            L7.8,14.9
            L8.3,17.0
            C7.6,17.6 6.9,18.0 6.2,18.0
            Z" />

    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M17.8,18.0
            C19.3,16.5 20.2,14.3 20.2,11.8
            C20.2,7.8 17.6,4.4 13.8,3.4
            L13.4,4.9
            C16.4,5.8 18.4,8.5 18.4,11.8
            C18.4,13.3 18.0,14.6 17.2,15.7
            L16.2,14.9
            L15.7,17.0
            C16.4,17.6 17.1,18.0 17.8,18.0
            Z" />

    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M11.4,20.6
            L9.2,19.3
            L10.6,14.4
            C10.9,13.4 11.0,12.6 10.8,11.8
            C10.5,10.7 9.8,9.8 9.0,9.0
            L10.4,6.9
            C12.0,8.1 13.4,9.6 13.8,11.5
            C14.2,13.4 13.4,15.2 12.8,16.8
            L14.2,16.8
            L11.2,21.0
            Z" />

    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M9.4,2.4
            L8.3,3.7
            L9.6,4.2
            L10.1,3.1
            Z" />

    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M12.0,1.9
            L11.6,4.2
            L12.4,4.2
            Z" />

    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M14.6,2.4
            L13.9,3.1
            L14.4,4.2
            L15.7,3.7
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
