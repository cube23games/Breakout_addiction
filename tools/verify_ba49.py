#!/usr/bin/env python3
from pathlib import Path
import sys

checks = {
    "lib/features/rescue/presentation/widgets/animated_delay_ring.dart": [
        "class AnimatedDelayRing extends StatelessWidget",
        "TweenAnimationBuilder<double>",
        "CustomPaint",
        "_DelayRingPainter",
        "SweepGradient",
        "drawArc",
        "MaskFilter.blur",
        "remainingLabel",
        "shouldRepaint",
    ],
    "lib/features/rescue/presentation/widgets/delay_actions_card.dart": [
        "import 'animated_delay_ring.dart';",
        "AnimatedDelayRing(",
        "progress: _progressValue()",
        "remainingLabel: _formatRemaining(_remaining)",
        "Delay Active",
        "Timer.periodic(const Duration(seconds: 1)",
    ],
}

banned = {
    "lib/features/rescue/presentation/widgets/delay_actions_card.dart": [
        "LinearProgressIndicator(value: _progressValue())",
    ],
}

failures = []

for file, needles in checks.items():
    path = Path(file)
    if not path.exists():
        failures.append(f"missing file: {file}")
        continue

    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            failures.append(f"{file} missing: {needle}")

for file, needles in banned.items():
    path = Path(file)
    if not path.exists():
        continue

    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle in text:
            failures.append(f"{file} still contains old timer UI: {needle}")

if failures:
    print("BA-49 verification failed:")
    for failure in failures:
        print(f" - {failure}")
    sys.exit(1)

print("BA-49 verification passed: animated circular Delay Active timer is wired.")
