#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {'lib/features/ai_chat/domain/chat_provider_mode.dart': ['vertexPrivateReady'],
 'lib/features/ai_chat/domain/ai_backend_config.dart': ['class AiBackendConfig'],
 'lib/features/ai_chat/data/ai_backend_config_repository.dart': ['class '
                                                                 'AiBackendConfigRepository'],
 'lib/features/ai_chat/data/vertex_private_ready_provider.dart': ['class '
                                                                  'VertexPrivateReadyProvider',
                                                                  'required '
                                                                  'this.transport'],
 'lib/features/ai_chat/data/chat_provider_factory.dart': ['case '
                                                          'ChatProviderMode.vertexPrivateReady:'],
 'lib/features/premium/presentation/premium_screen.dart': ['AiBackendConfigRepository '
                                                           '_backendRepository']}

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
    print('BA26 verification failed:')

    for failure in failures:
        print(f' - {failure}')

    sys.exit(1)

print('BA-26 paid config verification passed.')
