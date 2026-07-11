#!/usr/bin/env python3
from pathlib import Path
import sys

checks = {
    "lib/features/rescue/presentation/widgets/delay_actions_card.dart": [
        "class DelayActionsCard extends StatefulWidget",
        "Timer? _timer",
        "Duration? _selectedDuration",
        "void _startDelay(int minutes)",
        "Timer.periodic(const Duration(seconds: 1)",
        "Delay Active",
        "_formatRemaining(_remaining)",
        "LinearProgressIndicator(value: _progressValue())",
        "Delay complete.",
        "Delay 3 more",
        "Log this",
        "Navigator.pushNamed(context, RouteNames.recoveryEventLog)",
        "Navigator.pushNamed(context, RouteNames.support)",
        "Cancel timer",
    ],
    "lib/features/rescue/presentation/widgets/breathing_card.dart": [
        "class BreathingCard extends StatefulWidget",
        "with SingleTickerProviderStateMixin",
        "AnimationController",
        "static const int _inhaleSeconds = 4",
        "static const int _holdSeconds = 4",
        "static const int _exhaleSeconds = 6",
        "static const int _totalCycles = 3",
        "void _startBreathing()",
        "_orbScale",
        "CosmicBreathingOrb(",
        "animation: _controller",
        "running: _running",
        "label: _phaseLabel",
        "scaleFor: _orbScale",
        "Cycle $_currentCycle of $_totalCycles",
        "Start breathing",
        "Session complete",
        "Good. You slowed the moment down.",
    ],
    "lib/features/rescue/presentation/widgets/cosmic_breathing_orb.dart": [
        "class CosmicBreathingOrb extends StatelessWidget",
        "AnimatedBuilder",
        "RadialGradient",
        "Transform.scale",
        "CustomPaint",
        "_CosmicOrbPainter",
    ],
    "lib/features/rescue/presentation/rescue_screen.dart": [
        "const DelayActionsCard()",
        "const BreathingCard()",
    ],
}

banned = {
    "lib/features/rescue/presentation/widgets/delay_actions_card.dart": [
        "class DelayActionsCard extends StatelessWidget",
        "_announce(BuildContext context, int minutes)",
        "Good call. Delay for $minutes minutes and re-check your state.",
        "TODO",
        "placeholder",
    ],
    "lib/features/rescue/presentation/widgets/breathing_card.dart": [
        "class BreathingCard extends StatelessWidget",
        "return const InfoCard(",
        "You are trying to slow the cycle down, not solve your whole life in one minute.",
        "TODO",
        "placeholder",
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
            failures.append(f"{file} contains old/static behavior: {needle}")

if failures:
    print("BA-47 verification failed:")
    for failure in failures:
        print(f" - {failure}")
    sys.exit(1)

print(
    "BA-47 verification passed: "
    "Rescue delay timer and extracted breathing animation are functional."
)
