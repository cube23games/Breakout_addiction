#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {
    'lib/features/home/presentation/widgets/home_hero_card.dart': [
        'NeutralLabels.cycleWheelTitle',
        'RouteNames.cycle',
    ],
    'lib/features/cycle/presentation/cycle_screen.dart': [
        'class CycleScreen',
    ],
    'lib/core/constants/route_names.dart': [
        'static const cycle',
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
    print('BA-02 verification failed:')
    for failure in failures:
        print(f' - {failure}')
    sys.exit(1)

print(
    'Breakout Addiction BA-02 cycle entry '
    'verification passed.'
)
