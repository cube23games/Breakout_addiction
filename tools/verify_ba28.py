#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {'lib/core/constants/route_names.dart': ['static const featureControls = '
                                         "'/feature-controls';"],
 'lib/features/premium/domain/premium_plan.dart': ['Breakout Plus AI'],
 'lib/features/premium/domain/premium_status.dart': ['bool get hasAiPremium'],
 'lib/features/premium/data/premium_access_repository.dart': ['setPlan(PremiumPlan '
                                                              'plan)'],
 'lib/features/settings/domain/feature_control_settings.dart': ['showStartupNotice'],
 'lib/features/settings/data/feature_control_settings_repository.dart': ['feature_remote_ai_enabled'],
 'lib/features/settings/presentation/feature_controls_screen.dart': ['Choose your '
                                                                     'comfort level.'],
 'lib/features/home/presentation/widgets/startup_notice_sheet.dart': ['Welcome to '
                                                                      'Breakout'],
 'lib/features/home/presentation/home_screen.dart': ['_startupNoticeHandledThisSession'],
 'lib/features/ai_chat/presentation/ai_chat_screen.dart': ['Breakout Plus AI is '
                                                           'required for AI chat.'],
 'lib/features/premium/presentation/premium_screen.dart': ['Breakout Plus AI'],
 'lib/features/support/presentation/support_screen.dart': ['Open Premium'],
 'lib/app/app_router.dart': ['case RouteNames.featureControls:']}

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
    print('BA28 verification failed:')

    for failure in failures:
        print(f' - {failure}')

    sys.exit(1)

print('BA-28 notice, tiers, and controls verification passed.')
