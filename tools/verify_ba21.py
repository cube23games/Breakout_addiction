#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {'lib/core/constants/route_names.dart': ["static const premium = '/premium';"],
 'lib/features/premium/domain/premium_status.dart': ['class PremiumStatus'],
 'lib/features/premium/data/premium_access_repository.dart': ['class '
                                                              'PremiumAccessRepository'],
 'lib/features/premium/presentation/widgets/premium_badge.dart': ['class PremiumBadge'],
 'lib/features/premium/presentation/premium_screen.dart': ['Breakout Plus',
                                                           'Breakout Plus AI'],
 'lib/features/educate/presentation/educate_screen.dart': ['Educate Me Plus'],
 'lib/features/support/presentation/support_screen.dart': ['Open Premium'],
 'lib/app/app_router.dart': ['case RouteNames.premium:']}

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
    print('BA21 verification failed:')

    for failure in failures:
        print(f' - {failure}')

    sys.exit(1)

print('BA-21 premium hooks verification passed.')
