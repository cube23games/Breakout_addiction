#!/usr/bin/env python3
from pathlib import Path
import sys

path = Path("lib/features/rescue/presentation/rescue_screen.dart")

failures = []

if not path.exists():
    failures.append("missing rescue_screen.dart")
else:
    text = path.read_text()

    required = [
        "class RescueScreen extends StatefulWidget",
        "class _RescueScreenState extends State<RescueScreen>",
        "double _urgeIntensity = 4",
        "value: _urgeIntensity",
        "divisions: 10",
        "label: _urgeIntensity.round().toString()",
        "setState(()",
        "_urgeIntensity = value",
        "Current intensity: ${_urgeIntensity.round()}/10",
    ]

    banned = [
        "Slider(value: 4, min: 0, max: 10, onChanged: null)",
        "onChanged: null",
    ]

    for needle in required:
        if needle not in text:
            failures.append(f"rescue_screen.dart missing: {needle}")

    for needle in banned:
        if needle in text:
            failures.append(f"rescue_screen.dart still contains disabled placeholder: {needle}")

if failures:
    print("BA-46B verification failed:")
    for failure in failures:
        print(f" - {failure}")
    sys.exit(1)

print("BA-46B verification passed: Rescue urge intensity slider is interactive.")
