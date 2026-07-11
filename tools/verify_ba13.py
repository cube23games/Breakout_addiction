#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {
    'lib/features/rescue/presentation/widgets/breathing_card.dart': [
        'class BreathingCard',
        'BreathingSessionController',
        'BreathingSessionContent',
    ],
    'lib/features/rescue/presentation/widgets/breathing_session_controller.dart': [
        'class BreathingSessionController',
        'Timer.periodic',
    ],
    'lib/features/rescue/presentation/widgets/breathing_session_content.dart': [
        'class BreathingSessionContent',
        'CosmicBreathingOrb',
    ],
    'lib/features/rescue/presentation/widgets/cosmic_breathing_orb.dart': [
        'class CosmicBreathingOrb',
        'Semantics',
        'GestureDetector',
    ],
}

failures = []

for filename, needles in CHECKS.items():
    path = Path(filename)

    if not path.exists():
        failures.append(f'missing file: {filename}')
        continue

    text = path.read_text(encoding='utf-8')

    for needle in needles:
        if needle not in text:
            failures.append(
                f'{filename} missing: {needle}'
            )

if failures:
    print('BA-13 verification failed:')
    for failure in failures:
        print(f' - {failure}')
    sys.exit(1)

print(
    'Breakout Addiction BA-13 modular breathing '
    'verification passed.'
)
