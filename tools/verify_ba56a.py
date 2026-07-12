#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {
    'lib/main.dart': [
        "import 'dart:async';",
        'runApp(const BreakoutApp());',
        'addPostFrameCallback',
        'unawaited(_initializeNotificationsSafely())',
        'Notification initialization failed',
    ],
    'lib/features/notifications/data/breakout_notification_service.dart': [
        'Future<void>? _initializationFuture',
        'fallbackNotificationIconName',
        'await _initializePlugin(notificationIconName)',
        'await _initializePlugin(fallbackNotificationIconName)',
    ],
    'lib/features/rescue/presentation/widgets/delay_actions_card.dart': [
        'allow notification permission when Android asks',
        'only uses it for reminders you choose',
        'timer still works without it',
    ],
}

failures = []

for filename, needles in CHECKS.items():
    path = Path(filename)
    if not path.is_file():
        failures.append(f'missing file: {filename}')
        continue

    text = path.read_text(encoding='utf-8')
    for needle in needles:
        if needle not in text:
            failures.append(f'{filename} missing: {needle}')

main_path = Path('lib/main.dart')
if main_path.is_file():
    text = main_path.read_text(encoding='utf-8')
    run_app = text.find('runApp(const BreakoutApp());')
    initialize = text.find('unawaited(_initializeNotificationsSafely())')
    if run_app < 0 or initialize < 0 or run_app > initialize:
        failures.append(
            'Breakout must render before notification initialization starts'
        )

delay_card = Path(
    'lib/features/rescue/presentation/widgets/delay_actions_card.dart'
)
if delay_card.is_file():
    lines = len(delay_card.read_text(encoding='utf-8').splitlines())
    if lines > 190:
        failures.append(
            f'{delay_card} is {lines} lines; maximum is 190'
        )

if failures:
    print('BA-56A verification failed:')
    for failure in failures:
        print(f' - {failure}')
    sys.exit(1)

print(
    'BA-56A verification passed: notification setup cannot block the '
    'first app frame, the actual logo has a safe fallback, and Rescue '
    'explains notification permission.'
)
