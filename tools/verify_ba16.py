#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {'lib/core/constants/route_names.dart': ['static const recoveryPlan = '
                                         "'/recovery-plan';"],
 'lib/features/support/domain/recovery_plan.dart': ['class RecoveryPlan'],
 'lib/features/support/data/recovery_plan_repository.dart': ['class '
                                                             'RecoveryPlanRepository'],
 'lib/features/support/presentation/recovery_plan_screen.dart': ['Save Recovery Plan'],
 'lib/app/app_router.dart': ['case RouteNames.recoveryPlan:']}

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
    print('BA16 verification failed:')

    for failure in failures:
        print(f' - {failure}')

    sys.exit(1)

print('BA-16 recovery plan verification passed.')
