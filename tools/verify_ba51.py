#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {
    'lib/features/rescue/presentation/rescue_screen.dart': [
        '_delayActionsKey',
        'DelayActionsCard(',
        'key: _delayActionsKey',
        'onOpenBreathing:',
        'onReviewReasons:',
    ],
    'lib/features/rescue/presentation/widgets/delay_actions_card.dart': [
        'class DelayActionsCard',
        'ActiveDelayContent',
        'CompletedDelayContent',
        'DelayTimerController',
    ],
    'lib/features/rescue/presentation/widgets/breathing_card.dart': [
        'BreathingSessionController',
        'BreathingSessionContent',
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
    print('BA-51 verification failed:')
    for failure in failures:
        print(f' - {failure}')
    sys.exit(1)

print(
    'BA-51 verification passed: coordinated modular '
    'Rescue navigation is wired.'
)
