#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {'lib/features/ai_chat/domain/chat_provider_mode.dart': ['enum ChatProviderMode'],
 'lib/features/ai_chat/domain/ai_chat_settings.dart': ['class AiChatSettings'],
 'lib/features/ai_chat/data/ai_chat_settings_repository.dart': ['class '
                                                                'AiChatSettingsRepository'],
 'lib/features/ai_chat/data/gemini_prototype_provider.dart': ['class '
                                                              'GeminiPrototypeProvider'],
 'lib/features/ai_chat/data/chat_provider_factory.dart': ['class ChatProviderFactory'],
 'lib/features/ai_chat/presentation/ai_chat_screen.dart': ['Current Provider',
                                                           'ChatProviderFactory.create'],
 'lib/features/premium/presentation/premium_screen.dart': ['ChatProviderMode '
                                                           '_providerMode']}

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
    print('BA24 verification failed:')

    for failure in failures:
        print(f' - {failure}')

    sys.exit(1)

print('BA-24 AI provider abstraction verification passed.')
