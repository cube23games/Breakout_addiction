from pathlib import Path

checks = {
    'lib/features/rescue/data/reasons_to_stop_repository.dart': [
        "'Other'",
    ],
    'lib/features/rescue/presentation/rescue_screen.dart': [
        'Use this as a quick gut-check',
        'SnackBarBehavior.floating',
        'backgroundColor: const Color(0xFF13212C)',
    ],
    'lib/features/home/presentation/widgets/demo_readiness_card.dart': [
        'Checking demo readiness...',
    ],
}

missing = []

for file_name, needles in checks.items():
    path = Path(file_name)
    if not path.exists():
        missing.append(f'Missing file: {file_name}')
        continue

    text = path.read_text(encoding='utf-8')
    for needle in needles:
        if needle not in text:
            missing.append(f'Missing {needle!r} in {file_name}')

for path in Path('lib').rglob('*.dart'):
    text = path.read_text(encoding='utf-8')
    if 'A live slider will be wired in next.' in text:
        missing.append(f'Rescue placeholder still present in {path}')
    if 'Loading app state...' in text:
        missing.append(f'Demo loading placeholder still present in {path}')

if missing:
    print('BA-37A verification failed:')
    for item in missing:
        print(f'- {item}')
    raise SystemExit(1)

print('BA-37A verification passed: Rescue placeholder polish and Other reason are wired.')
