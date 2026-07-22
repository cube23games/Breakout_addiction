#!/usr/bin/env python3
from pathlib import Path

android = Path('android')
source_root = android / 'app/src/main/kotlin'
candidates = list(source_root.rglob('MainActivity.kt')) if source_root.exists() else []
if len(candidates) != 1:
    raise SystemExit(
        f'Expected exactly one generated MainActivity.kt, found {len(candidates)}.'
    )

path = candidates[0]
text = path.read_text(encoding='utf-8')
if 'WindowManager.LayoutParams.FLAG_SECURE' in text:
    print('Android screen protection already configured.')
    raise SystemExit(0)

import_anchor = 'import android.os.Build\n'
if import_anchor not in text:
    raise SystemExit('MainActivity Build import anchor was not found.')
text = text.replace(
    import_anchor,
    import_anchor + 'import android.os.Bundle\nimport android.view.WindowManager\n',
    1,
)

class_anchor = 'class MainActivity : FlutterActivity() {\n'
if class_anchor not in text:
    raise SystemExit('MainActivity class anchor was not found.')
protection = '''class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
    }

'''
text = text.replace(class_anchor, protection, 1)
path.write_text(text, encoding='utf-8')
print(f'Enabled screenshot and recent-app-preview protection in {path}.')
