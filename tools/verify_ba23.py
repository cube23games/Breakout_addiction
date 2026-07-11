#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {'lib/core/constants/route_names.dart': ["static const aiChat = '/ai-chat';"],
 'lib/features/ai_chat/domain/chat_message.dart': ['class ChatMessage'],
 'lib/features/ai_chat/domain/chat_provider.dart': ['abstract class ChatProvider'],
 'lib/features/ai_chat/data/ai_chat_repository.dart': ['class AiChatRepository'],
 'lib/features/ai_chat/data/mock_recovery_coach_provider.dart': ['Prototype response:'],
 'lib/features/ai_chat/presentation/ai_chat_screen.dart': ['Current Provider',
                                                           'prototype coach'],
 'lib/features/support/presentation/support_screen.dart': ['Open AI Recovery Coach'],
 'lib/app/app_router.dart': ['case RouteNames.aiChat:']}

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
    print('BA23 verification failed:')

    for failure in failures:
        print(f' - {failure}')

    sys.exit(1)

print('BA-23 AI chat shell verification passed.')
