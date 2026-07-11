#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {
    'lib/features/rescue/presentation/widgets/animated_delay_ring.dart': [
        'class AnimatedDelayRing extends StatefulWidget',
        'AnimationController',
        'deadline',
        'totalDuration',
        'remainingLabel',
        'DateTime.now',
    ],
    'lib/features/rescue/presentation/widgets/delay_timer_controller.dart': [
        'class DelayTimerController',
        'Timer.periodic',
        'milliseconds: 250',
        'deadline',
        'remainingLabel',
    ],
    'lib/features/rescue/presentation/widgets/active_delay_content.dart': [
        'AnimatedDelayRing',
        'deadline:',
        'totalDuration:',
    ],
    'lib/features/rescue/presentation/widgets/delay_actions_card.dart': [
        'DelayTimerController',
        'ActiveDelayContent',
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
    print('BA-49 verification failed:')
    for failure in failures:
        print(f' - {failure}')
    sys.exit(1)

print(
    'BA-49 verification passed: smooth deadline-based '
    'Rescue countdown timing is wired.'
)
