#!/usr/bin/env python3
from pathlib import Path
import sys

checks = {
    "lib/features/rescue/presentation/widgets/urge_support_guidance_card.dart": [
        "class UrgeSupportGuidanceCard extends StatelessWidget",
        "required this.intensity",
        "bool get _needsStrongerSupport => intensity >= 9",
        "This urge is running high",
        "This is an intense moment",
        "Choose a delay",
        "Breathe now",
        "Review my reasons",
        "Open Support",
        "FilledButton.icon",
        "OutlinedButton.icon",
    ],
    "lib/features/rescue/presentation/rescue_screen.dart": [
        "import 'widgets/urge_support_guidance_card.dart';",
        "final GlobalKey _delayActionsKey",
        "final GlobalKey _breathingKey",
        "final GlobalKey _reasonsKey",
        "Scrollable.ensureVisible",
        "if (_urgeIntensity >= 7)",
        "UrgeSupportGuidanceCard(",
        "intensity: _urgeIntensity.round()",
        "onChooseDelay: () => _scrollTo(_delayActionsKey)",
        "onBreathe: () => _scrollTo(_breathingKey)",
        "onReviewReasons: () => _scrollTo(_reasonsKey)",
        "DelayActionsCard(key: _delayActionsKey)",
        "BreathingCard(key: _breathingKey)",
        "ReasonsToStopCard(key: _reasonsKey)",
        "Breakout will suggest stronger next steps",
    ],
}

banned = {
    "lib/features/rescue/presentation/rescue_screen.dart": [
        "If the number is high, change location, breathe, or contact support now.",
        "Text Someone Safe",
    ],
}

failures = []

for filename, needles in checks.items():
    path = Path(filename)

    if not path.exists():
        failures.append(f"missing file: {filename}")
        continue

    text = path.read_text(encoding="utf-8")

    for needle in needles:
        if needle not in text:
            failures.append(f"{filename} missing: {needle}")

for filename, needles in banned.items():
    path = Path(filename)

    if not path.exists():
        continue

    text = path.read_text(encoding="utf-8")

    for needle in needles:
        if needle in text:
            failures.append(
                f"{filename} contains unsupported or obsolete behavior: {needle}"
            )

if failures:
    print("BA-51 verification failed:")
    for failure in failures:
        print(f" - {failure}")
    sys.exit(1)

print(
    "BA-51 verification passed: "
    "urge intensity 7-10 now reveals real Rescue guidance and actions."
)
