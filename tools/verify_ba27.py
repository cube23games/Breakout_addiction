#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {'lib/features/ai_chat/domain/ai_preflight_status.dart': ['class AiPreflightStatus'],
 'lib/features/ai_chat/data/ai_runtime_gate_repository.dart': ['getRemotePathEnabled'],
 'lib/features/ai_chat/data/ai_backend_preflight_service.dart': ['class '
                                                                 'AiBackendPreflightService'],
 'lib/features/ai_chat/data/ai_remote_transport.dart': ['abstract class '
                                                        'AiRemoteTransport'],
 'lib/features/ai_chat/data/vertex_transport_stub.dart': ['Vertex transport stub only'],
 'lib/features/ai_chat/data/vertex_private_ready_provider.dart': ['required '
                                                                  'this.transport'],
 'lib/features/ai_chat/presentation/ai_chat_screen.dart': ['AI request stopped by '
                                                           'safety/preflight checks.'],
 'lib/features/premium/presentation/premium_screen.dart': ['Remote backend path '
                                                           'enabled, but still '
                                                           'stubbed.']}

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
    print('BA27 verification failed:')

    for failure in failures:
        print(f' - {failure}')

    sys.exit(1)

print('BA-27 live cutover gate verification passed.')
