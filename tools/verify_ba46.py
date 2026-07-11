#!/usr/bin/env python3
from pathlib import Path
import sys

checks = {
    "docs/CLOSED_TESTING_RELEASE_QA_PACK.md": [
        "Closed Testing / Release QA Pack",
        "breakout-addiction-aab",
        "Android App Bundle / AAB",
        "12 Android testers",
        "14 continuous days",
        "Android 15 / API level 35",
        "Fresh install smoke test",
        "Rescue urge intensity slider is interactive",
        "Reasons to Stop",
        "Recovery Event Log",
        "Accountability Mode",
        "Partner Access is read-only",
        "No public hardcoded API key",
        "Privacy & Safety Center",
        "Tester recruitment target",
        "Founder / publisher handoff checklist",
        "Play Console release notes draft",
        "Manual QA signoff template",
        "Stop-ship issues",
        "not therapy, medical treatment, emergency care, or a crisis service",
        "Do not upload to closed testing",
    ],
    "docs/PLAY_STORE_READINESS_PACK.md": [
        "Play Store Readiness Pack",
        "Data Safety draft",
        "App access instructions",
        "Screenshot checklist",
    ],
    "docs/ANDROID_PLAY_STORE_REALITY.md": [
        "breakout-addiction-aab",
        "The AAB is the Play Store upload artifact",
    ],
}

missing = []

for file, needles in checks.items():
    path = Path(file)
    if not path.exists():
        missing.append(f"missing file: {file}")
        continue

    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            missing.append(f"{file} missing: {needle}")

if missing:
    print("BA-46 verification failed:")
    for item in missing:
        print(f" - {item}")
    sys.exit(1)

print("BA-46 verification passed: closed testing and release QA pack is documented.")
