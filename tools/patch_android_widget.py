#!/usr/bin/env python3
from pathlib import Path
import shutil

root = Path('.')
android = root / 'android'
overlay = root / 'android_widget_overlay/app/src/main'
if not android.is_dir():
    raise SystemExit('android/ must be generated before widget patching.')

for relative in (
    'res/layout/breakout_widget_compact.xml',
    'res/xml/breakout_widget_info.xml',
    'kotlin/com/slimnation/breakoutaddiction/BreakoutWidgetProvider.kt',
):
    source = overlay / relative
    target = android / 'app/src/main' / relative
    if not source.is_file():
        raise SystemExit(f'Missing widget overlay file: {source}')
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)

manifest = android / 'app/src/main/AndroidManifest.xml'
text = manifest.read_text(encoding='utf-8')
receiver = '''
        <receiver
            android:name=".BreakoutWidgetProvider"
            android:exported="true">
            <intent-filter>
                <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
            </intent-filter>
            <meta-data
                android:name="android.appwidget.provider"
                android:resource="@xml/breakout_widget_info" />
        </receiver>
'''
if 'android:name=".BreakoutWidgetProvider"' not in text:
    anchor = '    </application>'
    if anchor not in text:
        raise SystemExit('Android application closing tag missing.')
    manifest.write_text(text.replace(anchor, receiver + anchor, 1), encoding='utf-8')

strings = android / 'app/src/main/res/values/strings.xml'
widget_string = (
    '    <string name="breakout_widget_description">'
    'A discreet daily recovery shortcut</string>\n'
)
if strings.is_file():
    value = strings.read_text(encoding='utf-8')
    if 'name="breakout_widget_description"' not in value:
        value = value.replace('</resources>', widget_string + '</resources>', 1)
        strings.write_text(value, encoding='utf-8')
else:
    strings.parent.mkdir(parents=True, exist_ok=True)
    strings.write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<resources>\n' + widget_string + '</resources>\n',
        encoding='utf-8',
    )

activities = list((android / 'app/src/main/kotlin').rglob('MainActivity.kt'))
if len(activities) != 1:
    raise SystemExit(f'Expected one MainActivity.kt, found {len(activities)}')
activity = activities[0]
value = activity.read_text(encoding='utf-8')
if 'com.slimnation.breakoutaddiction/widget' not in value:
    anchor = '''        }
    }

    private fun isDebuggable'''
    block = '''        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.slimnation.breakoutaddiction/widget"
        ).setMethodCallHandler { call, result ->
            if (call.method == "refresh") {
                BreakoutWidgetProvider.updateAll(applicationContext)
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun isDebuggable'''
    if anchor not in value:
        raise SystemExit('MainActivity widget channel anchor missing.')
    activity.write_text(value.replace(anchor, block, 1), encoding='utf-8')

print('Installed real Android home-screen widget resources and provider.')
