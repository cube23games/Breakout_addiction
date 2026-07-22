#!/usr/bin/env python3
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def req(path,*needles):
  text=(ROOT/path).read_text()
  for n in needles:
    if n not in text: raise SystemExit(f'BA-70A12 missing {n!r} in {path}')
workflow=(ROOT/'.github/workflows/ci.yml').read_text()
if workflow.count('python3 tools/patch_android_widget.py')!=2: raise SystemExit('BA-70A12 widget patch must run for QA and public')
req('tools/patch_android_widget.py','BreakoutWidgetProvider','android.appwidget.action.APPWIDGET_UPDATE','com.slimnation.breakoutaddiction/widget')
req('android_widget_overlay/app/src/main/kotlin/com/slimnation/breakoutaddiction/BreakoutWidgetProvider.kt','Your next step is ready','FlutterSharedPreferences','updateAll')
req('lib/features/widget/data/widget_snapshot_repository.dart','syncToHomeScreenWidget','MissingPluginException','breakout_widget_title')
req('lib/features/widget/presentation/widget_preview_screen.dart','Update Real Home-Screen Widget')
req('tools/patch_android_widget.py', 'android:exported="true"')
print('BA-70A12 verifier passed.')
