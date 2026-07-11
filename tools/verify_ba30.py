#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {'pubspec.yaml': ['http: ^1.2.2'],
 'lib/features/ai_chat/data/ai_backend_config_repository.dart': ['Future<String?> '
                                                                 'getApiKey() async'],
 'lib/features/ai_chat/data/gemini_http_transport.dart': ['x-goog-api-key',
                                                          'class GeminiHttpTransport'],
 'lib/features/ai_chat/data/gemini_prototype_provider.dart': ['live prototype path is '
                                                              'not armed yet'],
 'lib/features/ai_chat/data/chat_provider_factory.dart': ['transport: '
                                                          'GeminiHttpTransport()'],
 'lib/features/ai_chat/data/ai_backend_preflight_service.dart': ['Gemini prototype '
                                                                 'remote path is '
                                                                 'armed.'],
 'lib/features/ai_chat/presentation/ai_chat_screen.dart': ['final livePrototype ='],
 'lib/features/premium/presentation/premium_screen.dart': ['Gemini Prototype can make '
                                                           'a real cloud prototype '
                                                           'call']}

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
    print('BA30 verification failed:')

    for failure in failures:
        print(f' - {failure}')

    sys.exit(1)

print('BA-30 Gemini prototype transport verification passed.')
