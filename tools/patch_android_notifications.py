#!/usr/bin/env python3
from pathlib import Path
import re
import sys

MANIFEST = Path('android/app/src/main/AndroidManifest.xml')

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
            + '\\n    '
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

    print('Android scheduled-notification manifest configured.')
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
