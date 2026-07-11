#!/usr/bin/env python3
from pathlib import Path
import sys

checks = {
    "docs/PLAY_STORE_READINESS_PACK.md": [
        "Short description",
        "Full description",
        "Health & Fitness",
        "Privacy policy notes",
        "Data Safety draft",
        "App access instructions",
        "Closed/internal tester instructions",
        "Screenshot checklist",
        "Launch readiness checklist",
        "AAB downloaded from GitHub Actions",
        "Breakout Addiction is not a medical device",
        "not a medical device, therapy provider, emergency service, or crisis hotline",
        "public hardcoded AI API keys",
        "VPN/Shield excluded from first release",
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
    print("BA-45 verification failed:")
    for item in missing:
        print(f" - {item}")
    sys.exit(1)

print("BA-45 verification passed: Play Store readiness pack draft is documented.")
