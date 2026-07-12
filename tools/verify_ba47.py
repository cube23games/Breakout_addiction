#!/usr/bin/env python3
from pathlib import Path
import sys

checks = {
    "lib/features/rescue/presentation/widgets/delay_actions_card.dart": [
        "class DelayActionsCard extends StatefulWidget",
        "DelayTimerController",
        "Delay Active",
        "Countdown Complete",
        "CompletedDelayContent",
    ],
    "lib/features/rescue/presentation/widgets/completed_delay_content.dart": [
        "Countdown is complete",
        "Did the urge subside?",
    ],
    "lib/features/rescue/presentation/widgets/breathing_card.dart": [
        "class BreathingCard extends StatefulWidget",
        "AnimationController",
        "BreathingSessionController",
        "BreathingSessionContent",
        "_handleOrbTap",
    ],
    "lib/features/rescue/presentation/widgets/breathing_session_controller.dart": [
        "Timer.periodic",
        "phaseLabel",
        "secondsLeftInPhase",
        "totalCycles = 3",
    ],
    "lib/features/rescue/presentation/widgets/breathing_session_content.dart": [
        "CosmicBreathingOrb(",
        "End exercise",
        "Tap the orb to begin.",
    ],
    "lib/features/rescue/presentation/widgets/cosmic_breathing_orb.dart": [
        "CosmicOrbPainter",
        "GestureDetector",
        "Semantics",
    ],
    "lib/features/rescue/presentation/rescue_screen.dart": [
        "DelayActionsCard(",
        "BreathingCard(key: _breathingKey)",
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

if failures:
    print("BA-47 verification failed:")
    for failure in failures:
        print(f" - {failure}")
    sys.exit(1)

print(
    "BA-47 verification passed: modular Rescue delay, "
    "countdown check-in, and breathing tools are wired."
)
