#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {
    'lib/features/onboarding/presentation/home_entry_screen.dart': [
        'class HomeEntryScreen',
    ],
    'lib/features/onboarding/presentation/onboarding_screen.dart': [
        'class OnboardingScreen',
    ],
    'lib/features/onboarding/data/onboarding_repository.dart': [
        'class OnboardingRepository',
    ],
    'lib/features/onboarding/domain/onboarding_state.dart': [
        'class OnboardingState',
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
    print('BA-10 verification failed:')
    for failure in failures:
        print(f' - {failure}')
    sys.exit(1)

print(
    'Breakout Addiction BA-10 onboarding entry '
    'verification passed.'
)
