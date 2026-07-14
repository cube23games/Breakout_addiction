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

# Android notification small icons are monochrome masks. Android supplies
# their final color. A full-color launcher logo becomes a white or black blob.
#
# This vector uses:
# - no background
# - one thick open ring
# - one bold center bolt
# - white artwork only
#
# Android will tint this mask correctly in the status bar, notification shade,
# lock screen, light mode, and dark mode.
VECTOR_ICON_XML = """<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">

    <path
        android:fillColor="@android:color/transparent"
        android:strokeColor="#FFFFFFFF"
        android:strokeWidth="3.2"
        android:strokeLineCap="round"
        android:strokeLineJoin="round"
        android:pathData="M18.36,5.64
            C14.85,2.13 9.15,2.13 5.64,5.64
            C2.13,9.15 2.13,14.85 5.64,18.36
            C9.15,21.87 14.85,21.87 18.36,18.36
            C19.30,17.42 20.00,16.35 20.48,15.20" />

    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M13.10,5.20
            L7.40,12.90
            L11.00,12.90
            L10.20,18.80
            L16.70,10.50
            L13.00,10.50
            Z" />

</vector>
"""


def write_notification_icon() -> None:
    NOTIFICATION_ICON.parent.mkdir(parents=True, exist_ok=True)

    # Remove the old PNG so Android never has two drawable resources with
    # the same name and so the full-color badge cannot return accidentally.
    if LEGACY_NOTIFICATION_ICON.exists():
        LEGACY_NOTIFICATION_ICON.unlink()

    NOTIFICATION_ICON.write_text(
        VECTOR_ICON_XML,
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

    required_manifest_values = [
        PERMISSION,
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

    if not NOTIFICATION_ICON.is_file():
        print(
            f'Notification icon was not generated: {NOTIFICATION_ICON}',
            file=sys.stderr,
        )
        return 1

    generated_icon = NOTIFICATION_ICON.read_text(encoding='utf-8')

    if generated_icon != VECTOR_ICON_XML:
        print(
            'Generated notification vector does not match its source.',
            file=sys.stderr,
        )
        return 1

    if LEGACY_NOTIFICATION_ICON.exists():
        print(
            'Legacy full-color notification PNG still exists.',
            file=sys.stderr,
        )
        return 1

    print(
        'Android scheduled notifications and monochrome Breakout '
        'status-bar icon configured.'
    )
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
