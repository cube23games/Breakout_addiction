#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {
    'lib/features/home/presentation/widgets/home_hero_card.dart': [
        'class HomeHeroCard',
        'NeutralLabels.cycleWheelTitle',
        'RouteNames.cycle',
        'RouteNames.rescue',
        'Private by design',
        'Built for action',
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
    print('BA-22 verification failed:')
    for failure in failures:
        print(f' - {failure}')
    sys.exit(1)

print(
    'Breakout Addiction BA-22 modular Home hero '
    'verification passed.'
)
