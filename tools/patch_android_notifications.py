#!/usr/bin/env python3
from pathlib import Path
import re
import sys

MANIFEST = Path('android/app/src/main/AndroidManifest.xml')
NOTIFICATION_ICON = Path(
    'android/app/src/main/res/drawable/ic_stat_breakout.xml'
)

PERMISSION = (
    '<uses-permission '
    'android:name="android.permission.RECEIVE_BOOT_COMPLETED" />'
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

# Android status-bar icons are monochrome alpha masks. This compact B/O
# monogram is the notification-sized version of the Breakout logo.
NOTIFICATION_ICON_XML = """<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#00000000"
        android:pathData="M12,2.75 C17.11,2.75 21.25,6.89 21.25,12 C21.25,17.11 17.11,21.25 12,21.25 C6.89,21.25 2.75,17.11 2.75,12 C2.75,6.89 6.89,2.75 12,2.75"
        android:strokeColor="#FFFFFFFF"
        android:strokeLineCap="round"
        android:strokeLineJoin="round"
        android:strokeWidth="2.2" />
    <path
        android:fillColor="#00000000"
        android:pathData="M7.75,6 L7.75,18 M7.75,6 L12.1,6 C14.25,6 15.6,7.1 15.6,8.8 C15.6,10.5 14.25,11.6 12.1,11.6 L7.75,11.6 M7.75,11.6 L12.55,11.6 C14.85,11.6 16.3,12.85 16.3,14.8 C16.3,16.75 14.85,18 12.55,18 L7.75,18"
        android:strokeColor="#FFFFFFFF"
        android:strokeLineCap="round"
        android:strokeLineJoin="round"
        android:strokeWidth="2.1" />
</vector>
"""


def write_notification_icon() -> None:
    NOTIFICATION_ICON.parent.mkdir(parents=True, exist_ok=True)
    NOTIFICATION_ICON.write_text(
        NOTIFICATION_ICON_XML,
        encoding='utf-8',
    )


def main() -> int:
    if not MANIFEST.is_file():
        print(f'Missing generated manifest: {MANIFEST}', file=sys.stderr)
        return 1

    text = MANIFEST.read_text(encoding='utf-8')

    if PERMISSION not in text:
        match = re.search(r'<manifest\b[^>]*>', text, flags=re.DOTALL)
        if match is None:
            print('Could not find <manifest> element.', file=sys.stderr)
            return 1
        text = (
            text[:match.end()]
            + '\n    '
            + PERMISSION
            + text[match.end():]
        )

    receiver_name = (
        'com.dexterous.flutterlocalnotifications.'
        'ScheduledNotificationReceiver'
    )
    if receiver_name not in text:
        marker = '    </application>'
        if marker not in text:
            print('Could not find </application> marker.', file=sys.stderr)
            return 1
        text = text.replace(
            marker,
            RECEIVERS + marker,
            1,
        )

    MANIFEST.write_text(text, encoding='utf-8')
    write_notification_icon()

    required = [
        PERMISSION,
        'ScheduledNotificationReceiver',
        'ScheduledNotificationBootReceiver',
        'android.intent.action.BOOT_COMPLETED',
    ]
    missing = [item for item in required if item not in text]
    if missing:
        print(f'Manifest patch incomplete: {missing}', file=sys.stderr)
        return 1

    if not NOTIFICATION_ICON.is_file():
        print('Notification icon was not generated.', file=sys.stderr)
        return 1

    icon_text = NOTIFICATION_ICON.read_text(encoding='utf-8')
    icon_required = [
        'android:viewportWidth="24"',
        'android:strokeColor="#FFFFFFFF"',
        'M7.75,6 L7.75,18',
    ]
    icon_missing = [
        item for item in icon_required if item not in icon_text
    ]
    if icon_missing:
        print(
            f'Notification icon is incomplete: {icon_missing}',
            file=sys.stderr,
        )
        return 1

    print(
        'Android scheduled notifications and branded '
        'status-bar icon configured.'
    )
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
