#!/usr/bin/env python3
from pathlib import Path
import tempfile, subprocess
ROOT=Path(__file__).resolve().parents[1]
workflow=(ROOT/'.github/workflows/ci.yml').read_text()
if workflow.count('python3 tools/patch_android_screen_protection.py')!=2: raise SystemExit('BA-70A10 screen patch must run for QA and public generation')
privacy=(ROOT/'lib/features/privacy/presentation/privacy_settings_screen.dart').read_text()
for n in ('Screen Capture Protection','recent-app preview are blocked','explicit confirmation'):
  if n not in privacy: raise SystemExit(f'BA-70A10 missing {n}')
script=(ROOT/'tools/patch_android_screen_protection.py').read_text()
for n in ('FLAG_SECURE','onCreate','WindowManager'):
  if n not in script: raise SystemExit(f'BA-70A10 patch missing {n}')
print('BA-70A10 verifier passed.')
