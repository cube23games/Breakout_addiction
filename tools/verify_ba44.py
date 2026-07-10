#!/usr/bin/env python3
from pathlib import Path
import sys

checks = {
    "docs/LIFELINE_WIDGET_PLAN.md": [
        "Fast help, private wording",
        "Discreet Mode",
        "Recovery Mode",
        "Small",
        "Medium",
        "Large",
        "Rescue",
        "Recovery Event Log / Quick Log",
        "Reasons to Stop",
        "No sensitive log counts by default",
        "No AI chat content",
        "real Android home screen widget",
        "native Android app widget provider files",
        "commit Android platform files",
        "re-apply native widget files in CI",
        "Breakout Lifeline Widget",
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
    print("BA-44 verification failed:")
    for item in missing:
        print(f" - {item}")
    sys.exit(1)

print("BA-44 verification passed: Lifeline Widget plan is documented.")
