#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import sys

MANIFEST = Path('android/app/src/main/AndroidManifest.xml')
SOURCE_NOTIFICATION_ICON = Path(
    'assets/branding/breakout_notification_icon.png'
)
NOTIFICATION_ICON = Path(
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


def write_notification_icon() -> None:
    if not SOURCE_NOTIFICATION_ICON.is_file():
        raise FileNotFoundError(
            f'Missing notification icon source: '
            f'{SOURCE_NOTIFICATION_ICON}'
        )

    data = SOURCE_NOTIFICATION_ICON.read_bytes()
    if not data.startswith(b'\x89PNG\r\n\x1a\n'):
        raise ValueError(
            'Breakout notification icon must be a PNG file.'
        )

    NOTIFICATION_ICON.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(
        SOURCE_NOTIFICATION_ICON,
        NOTIFICATION_ICON,
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

    try:
        write_notification_icon()
    except (FileNotFoundError, ValueError) as exc:
        print(str(exc), file=sys.stderr)
        return 1

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

    if (
        not NOTIFICATION_ICON.is_file()
        or NOTIFICATION_ICON.stat().st_size < 500
    ):
        print('Notification icon was not generated correctly.', file=sys.stderr)
        return 1

    if (
        NOTIFICATION_ICON.read_bytes()
        != SOURCE_NOTIFICATION_ICON.read_bytes()
    ):
        print('Generated notification icon does not match source.', file=sys.stderr)
        return 1

    print(
        'Android scheduled notifications and actual Breakout '
        'status-bar logo configured.'
    )
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
