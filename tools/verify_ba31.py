#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {'lib/features/ai_chat/domain/ai_usage_snapshot.dart': ['class AiUsageSnapshot'],
 'lib/features/ai_chat/data/ai_usage_repository.dart': ['recordSuccessfulReply'],
 'lib/features/ai_chat/presentation/widgets/ai_mode_clarity_card.dart': ['Current AI '
                                                                         'State'],
 'lib/features/ai_chat/presentation/widgets/ai_usage_meter_card.dart': ['AI Usage '
                                                                        'Meter'],
 'lib/features/ai_chat/presentation/widgets/emergency_fallback_card.dart': ['Emergency '
                                                                            'Fallback'],
 'lib/features/ai_chat/presentation/ai_chat_screen.dart': ['AI usage meter reset.'],
 'lib/features/premium/presentation/premium_screen.dart': ['Breakout Plus AI is '
                                                           'optional and should never '
                                                           'replace human support in '
                                                           'an emergency.'],
 'lib/features/support/presentation/support_screen.dart': ['Open AI Recovery Coach']}

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
    print('BA31 verification failed:')

    for failure in failures:
        print(f' - {failure}')

    sys.exit(1)

print('BA-31 AI clarity, usage meter, and emergency fallback verification passed.')
