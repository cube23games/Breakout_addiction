#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {'lib/core/constants/route_names.dart': ["static const riskWindows = '/risk-windows';"],
 'lib/features/risk/domain/risk_window.dart': ['class RiskWindow'],
 'lib/features/risk/domain/reminder_settings.dart': ['class ReminderSettings'],
 'lib/features/risk/data/risk_window_repository.dart': ['class RiskWindowRepository'],
 'lib/features/risk/presentation/risk_windows_screen.dart': ['Add Risk Window'],
 'lib/features/support/presentation/support_screen.dart': ['Open Risk Windows'],
 'lib/app/app_router.dart': ['case RouteNames.riskWindows:']}

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
    print('BA15 verification failed:')

    for failure in failures:
        print(f' - {failure}')

    sys.exit(1)

print('BA-15 risk windows verification passed.')
