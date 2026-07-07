from pathlib import Path

checks = {
    'lib/core/constants/route_names.dart': [
        'privacySafetyCenter',
        'releaseReadiness',
        '/privacy-safety-center',
        '/release-readiness',
    ],
    'lib/app/app_router.dart': [
        'PrivacySafetyCenterScreen',
        'ReleaseReadinessScreen',
        'RouteNames.privacySafetyCenter',
        'RouteNames.releaseReadiness',
    ],
    'lib/features/privacy/presentation/privacy_safety_center_screen.dart': [
        'Privacy & Safety Center',
        'Private by default',
        'AI is optional',
        'Not emergency care',
    ],
    'lib/features/release/presentation/release_readiness_screen.dart': [
        'Release Readiness',
        'Demo-to-store checklist',
        'Open Privacy & Safety Center',
    ],
    'lib/features/release/data/release_checklist_repository.dart': [
        'Core recovery loop',
        'Privacy-first positioning',
        'Play Store listing',
    ],
    'lib/features/support/presentation/support_screen.dart': [
        'Privacy & Safety Center',
        'Release Readiness',
        'RouteNames.privacySafetyCenter',
        'RouteNames.releaseReadiness',
    ],
    'docs/PLAY_STORE_PREP.md': [
        'Breakout Addiction Play Store Prep',
        'Store review checklist',
        'AI language',
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

if missing:
    print('BA-36 verification failed:')
    for item in missing:
        print(f'- {item}')
    raise SystemExit(1)

print('BA-36 verification passed: release readiness and privacy safety center are wired.')
