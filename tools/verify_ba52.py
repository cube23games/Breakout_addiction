#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {
    'lib/app/breakout_app.dart': [
        'class BreakoutApp extends StatefulWidget',
        'LockSessionController.instance',
        '_lockSession.start()',
        '_lockSession.stop()',
    ],
    'lib/features/privacy/domain/lock_settings.dart': [
        'backgroundGraceMinutes',
        'supportedGraceMinutes',
        '<int>{0, 1, 2, 5, 10}',
    ],
    'lib/features/privacy/data/lock_settings_repository.dart': [
        'privacy_background_grace_minutes',
        'LockSettings.normalizeGraceMinutes',
        'getCredentialInputMode',
    ],
    'lib/features/privacy/presentation/lock_session_controller.dart': [
        'class LockSessionController extends ChangeNotifier',
        'static final LockSessionController instance',
        'AppLifecycleState.hidden',
        'AppLifecycleState.paused',
        'void unlock()',
        'void lockNow()',
    ],
    'lib/features/privacy/presentation/protected_route_gate.dart': [
        'LockSessionController.instance',
        '_session.isUnlocked',
        'credentialMode: _credentialMode',
        'onUnlockSuccess: _session.unlock',
    ],
    'lib/features/privacy/presentation/lock_gate_screen.dart': [
        'AccountabilitySettingsRepository',
        'settings.canUsePartnerAccess && hasPasscode',
        'Open Partner View',
        'RouteNames.accountabilityPartnerAccess',
    ],
    'lib/features/privacy/presentation/widgets/relock_timing_card.dart': [
        'Relock Timing',
        "(0, 'Immediately')",
        "(10, '10 minutes')",
        'SelectableOptionTile',
    ],
    'lib/features/privacy/presentation/privacy_settings_screen.dart': [
        'RelockTimingCard(',
        'backgroundGraceMinutes',
        'LockSessionController.instance',
        'App Lock Credential',
    ],
    'lib/features/support/presentation/support_screen.dart': [
        'PopScope(',
        '_leaveSupport',
        'SupportBottomNavigation',
        'SelectableOptionTile',
        'LayoutBuilder(',
    ],
    'lib/features/support/presentation/widgets/support_bottom_navigation.dart': [
        'currentIndex: 4',
        'RouteNames.home',
        'RouteNames.insights',
    ],
    'lib/features/accountability/presentation/accountability_settings_screen.dart': [
        'SelectableOptionTile',
        'LayoutBuilder(',
        'sharedScopes.contains(scope)',
        'Partner Access Credential',
    ],
    'lib/features/home/presentation/widgets/startup_notice_sheet.dart': [
        'AppColors.surface.withValues(alpha: 0.98)',
        'elevation: 24',
        'SingleChildScrollView',
    ],
    'lib/features/rescue/presentation/widgets/breathing_session_content.dart': [
        "Text('End exercise')",
    ],
    'lib/features/rescue/presentation/widgets/delay_duration_selector.dart': [
        'class DelayDurationSelector',
        'SelectableOptionTile',
        'selectedMinutes == minutes',
    ],
    'lib/features/rescue/presentation/widgets/delay_actions_card.dart': [
        'DelayDurationSelector(',
        'selectedMinutes: selectedDuration?.inMinutes',
        'The active choice stays highlighted.',
    ],
    'lib/core/widgets/selectable_option_tile.dart': [
        'class SelectableOptionTile',
        'selected: selected',
        'AnimatedContainer',
        'AppColors.accent',
    ],
}

FORBIDDEN = {
    'lib/features/support/presentation/support_screen.dart': [
        "'$label ✓'",
    ],
    'lib/features/rescue/presentation/widgets/breathing_session_content.dart': [
        'Stop breathing',
    ],
    'lib/features/privacy/presentation/protected_route_gate.dart': [
        '_sessionUnlocked',
    ],
}

LIMITS = {
    'lib/features/privacy/presentation/lock_session_controller.dart': 150,
    'lib/features/privacy/presentation/protected_route_gate.dart': 130,
    'lib/features/privacy/presentation/lock_gate_screen.dart': 200,
    'lib/features/privacy/presentation/widgets/relock_timing_card.dart': 110,
    'lib/features/support/presentation/widgets/support_bottom_navigation.dart': 90,
    'lib/features/rescue/presentation/widgets/delay_duration_selector.dart': 80,
    'lib/core/widgets/selectable_option_tile.dart': 140,
}

failures = []

for filename, needles in CHECKS.items():
    path = Path(filename)
    if not path.exists():
        failures.append(f'missing file: {filename}')
        continue

    text = path.read_text(encoding='utf-8')
    for needle in needles:
        if needle not in text:
            failures.append(f'{filename} missing: {needle}')

for filename, needles in FORBIDDEN.items():
    path = Path(filename)
    if not path.exists():
        continue

    text = path.read_text(encoding='utf-8')
    for needle in needles:
        if needle in text:
            failures.append(f'{filename} still contains: {needle}')

for filename, maximum in LIMITS.items():
    path = Path(filename)
    if not path.exists():
        continue

    lines = len(path.read_text(encoding='utf-8').splitlines())
    if lines > maximum:
        failures.append(
            f'{filename} is {lines} lines; maximum is {maximum}'
        )

if failures:
    print('BA-52 verification failed:')
    for failure in failures:
        print(f' - {failure}')
    sys.exit(1)

print(
    'BA-52 verification passed: session-wide locking, credential-aware '
    'partner access, navigation, highlighted tiles, startup contrast, '
    'and safer Rescue wording are wired.'
)
