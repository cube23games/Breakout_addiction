#!/usr/bin/env python3
from pathlib import Path
import sys

checks = {
    ".github/workflows/ci.yml": [
        "flutter build apk --release",
        "flutter build appbundle --release",
        "breakout-addiction-apk",
        "breakout-addiction-aab",
        "build/app/outputs/**/*.apk",
        "build/app/outputs/**/*.aab",
    ],
    "docs/ANDROID_PLAY_STORE_REALITY.md": [
        "does not currently commit a full Android platform folder",
        "breakout-addiction-apk",
        "breakout-addiction-aab",
        "The AAB is the Play Store upload artifact",
        "version: 0.1.0+1",
        "Widget Preview is an in-app preview/demo concept",
        "real Android home screen widget",
        "Delay VPN/Shield until after first release",
    ],
    "pubspec.yaml": [
        "name: breakout_addiction",
        "version: 0.1.0+1",
    ],
}

missing = []

for file, needles in checks.items():
    path = Path(file)
    if not path.exists():
        missing.append(f"missing file: {file}")
        continue

    text = path.read_text()
    for needle in needles:
        if needle not in text:
            missing.append(f"{file} missing: {needle}")

if missing:
    print("BA-43 verification failed:")
    for item in missing:
        print(f" - {item}")
    sys.exit(1)

print("BA-43 verification passed: Android Play Store artifact reality is documented and AAB CI output is wired.")
