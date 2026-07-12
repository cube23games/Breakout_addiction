#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path.cwd()

REQUIRED_FILES = [
    'lib/core/security/credential_input_mode.dart',
    'lib/features/accountability/data/accountability_settings_repository.dart',
    'lib/features/accountability/presentation/accountability_settings_screen.dart',
    'lib/features/accountability/presentation/accountability_partner_access_screen.dart',
    'lib/features/accountability/presentation/accountability_summary_screen.dart',
    'lib/features/privacy/data/lock_settings_repository.dart',
    'lib/features/privacy/presentation/privacy_settings_screen.dart',
    'lib/features/privacy/presentation/protected_route_gate.dart',
    'lib/features/privacy/presentation/lock_gate_screen.dart',
    'lib/features/rescue/data/delay_session_repository.dart',
    'lib/features/rescue/presentation/rescue_screen.dart',
    'lib/features/rescue/presentation/widgets/delay_actions_card.dart',
    'lib/features/rescue/presentation/widgets/delay_duration_selector.dart',
    'lib/features/rescue/presentation/widgets/delay_timer_controller.dart',
    'lib/features/rescue/presentation/widgets/completed_delay_content.dart',
    'lib/features/onboarding/data/welcome_banner_repository.dart',
    'lib/features/onboarding/domain/welcome_message.dart',
    'lib/features/onboarding/presentation/home_entry_screen.dart',
    'lib/features/onboarding/presentation/widgets/welcome_banner_overlay.dart',
    'lib/features/risk/data/risk_window_repository.dart',
    'lib/features/risk/domain/risk_window.dart',
    'lib/features/risk/presentation/risk_windows_screen.dart',
    'lib/features/risk/presentation/widgets/risk_window_editor_sheet.dart',
]


def read(relative: str) -> str:
    return (ROOT / relative).read_text(encoding='utf-8')


def require(
    failures: list[str],
    relative: str,
    needles: list[str],
) -> None:
    content = read(relative)
    for needle in needles:
        if needle not in content:
            failures.append(f'{relative} missing: {needle}')


def forbid(
    failures: list[str],
    relative: str,
    needles: list[str],
) -> None:
    content = read(relative)
    for needle in needles:
        if needle in content:
            failures.append(f'{relative} still contains: {needle}')


def main() -> int:
    failures: list[str] = []

    for relative in REQUIRED_FILES:
        if not (ROOT / relative).is_file():
            failures.append(f'missing file: {relative}')

    modular_limits = {
        'lib/features/rescue/presentation/widgets/delay_actions_card.dart': 190,
        'lib/features/rescue/presentation/widgets/delay_timer_controller.dart': 150,
    }
    for relative, maximum in modular_limits.items():
        lines = len(read(relative).splitlines())
        if lines > maximum:
            failures.append(
                f'{relative} is {lines} lines; maximum is {maximum}'
            )

    require(
        failures,
        'lib/features/rescue/presentation/rescue_screen.dart',
        [
            'onOpenBreathing: () => _scrollTo(_breathingKey)',
            'onReviewReasons: () => _scrollTo(_reasonsKey)',
        ],
    )

    if failures:
        print('BA-54 verification failed:')
        for failure in failures:
            print(f' - {failure}')
        return 1

    require(
        failures,
        'lib/core/security/credential_input_mode.dart',
        [
            'enum CredentialInputMode',
            'pin,',
            'password;',
            "RegExp(r'^\\d+$')",
        ],
    )

    require(
        failures,
        'lib/features/privacy/data/lock_settings_repository.dart',
        [
            'privacy_credential_mode',
            'getCredentialInputMode',
            'CredentialInputMode? mode',
            'resolvedMode.name',
        ],
    )
    require(
        failures,
        'lib/features/accountability/data/accountability_settings_repository.dart',
        [
            'accountability_partner_credential_mode',
            'getPartnerCredentialMode',
            'CredentialInputMode? mode',
            'resolvedMode.name',
        ],
    )

    require(
        failures,
        'lib/features/privacy/presentation/privacy_settings_screen.dart',
        [
            'Choose a numeric PIN or a password.',
            'FilteringTextInputFormatter.digitsOnly',
            'App Lock Credential',
            'Save App Lock ${mode.label}',
        ],
    )
    require(
        failures,
        'lib/features/privacy/presentation/lock_gate_screen.dart',
        [
            'credentialMode',
            'Incorrect app lock ${widget.credentialMode.label}. Try again.',
            'Open Partner View',
            'Partner access uses its own PIN or password',
        ],
    )
    forbid(
        failures,
        'lib/features/privacy/presentation/lock_gate_screen.dart',
        ['That code does not match.'],
    )

    require(
        failures,
        'lib/features/accountability/presentation/accountability_settings_screen.dart',
        [
            'Partner Access Credential',
            'CredentialInputMode.values',
            'FilteringTextInputFormatter.digitsOnly',
            'Save Partner ${_partnerCredentialMode.label}',
        ],
    )
    forbid(
        failures,
        'lib/features/accountability/presentation/accountability_settings_screen.dart',
        ['Share AI chat history'],
    )

    require(
        failures,
        'lib/features/accountability/presentation/accountability_partner_access_screen.dart',
        [
            'Incorrect partner ${_credentialMode.label}. Try again.',
            'FilteringTextInputFormatter.digitsOnly',
            'Accountability Partner access has not been set up.',
        ],
    )
    forbid(
        failures,
        'lib/features/accountability/presentation/accountability_partner_access_screen.dart',
        ['not enabled or the passcode is incorrect'],
    )
    forbid(
        failures,
        'lib/features/accountability/presentation/accountability_summary_screen.dart',
        [
            'AI provider access',
            'AI chat history is not shared.',
            'AI chat sharing is enabled',
        ],
    )


    require(
        failures,
        'lib/features/rescue/presentation/widgets/delay_duration_selector.dart',
        [
            'static const List<int> _durations = <int>[3, 5, 15];',
        ],
    )

    require(
        failures,
        'lib/features/rescue/data/delay_session_repository.dart',
        [
            'rescue_delay_selected_duration_ms',
            'rescue_delay_deadline_ms',
            'hasRestorableSession',
            'markCompleted',
        ],
    )
    require(
        failures,
        'lib/features/rescue/presentation/widgets/delay_timer_controller.dart',
        [
            'DateTime.now().add(duration)',
            'await _repository.saveActive',
            'Future<void> restore()',
            'didChangeAppLifecycleState',
            'unawaited(_repository.markCompleted(selected))',
        ],
    )
    require(
        failures,
        'lib/features/rescue/presentation/rescue_screen.dart',
        [
            'hasRestorableSession',
            '_scrollTo(_delayActionsKey)',
        ],
    )
    require(
        failures,
        'lib/features/rescue/presentation/widgets/completed_delay_content.dart',
        [
            'Countdown is complete',
            'Did the urge subside?',
        ],
    )
    forbid(
        failures,
        'lib/features/rescue/presentation/widgets/completed_delay_content.dart',
        [
            "Text('Delay complete'",
            "'How is the urge now?'",
        ],
    )

    require(
        failures,
        'lib/features/onboarding/data/welcome_banner_repository.dart',
        [
            'Welcome to Breakout',
            'Welcome back',
            'welcome_banner_remaining_quote_indexes',
            'remaining.shuffle',
        ],
    )
    require(
        failures,
        'lib/features/onboarding/presentation/home_entry_screen.dart',
        [
            '_completedEntryResolvedThisProcess',
            'hasRestorableSession',
            'WelcomeBannerOverlay',
            'RouteNames.rescue',
        ],
    )
    require(
        failures,
        'lib/features/onboarding/presentation/widgets/welcome_banner_overlay.dart',
        [
            'FadeTransition',
            'SlideTransition',
            'disableAnimations',
            'Duration(milliseconds: 1700)',
            'Timer? _holdTimer',
            'Completer<void>()',
            '_holdTimer?.cancel()',
        ],
    )
    forbid(
        failures,
        'lib/features/onboarding/presentation/widgets/welcome_banner_overlay.dart',
        ['Future<void>.delayed'],
    )

    require(
        failures,
        'lib/features/risk/data/risk_window_repository.dart',
        [
            'risk_window_use_24_hour_time',
            'getUse24HourTime',
            'saveUse24HourTime',
        ],
    )
    require(
        failures,
        'lib/features/risk/domain/risk_window.dart',
        [
            'formattedRange',
            'crossesMidnight',
            "'PM' : 'AM'",
        ],
    )
    require(
        failures,
        'lib/features/risk/presentation/widgets/risk_window_editor_sheet.dart',
        [
            'showTimePicker',
            'TimePickerEntryMode.dial',
            'alwaysUse24HourFormat',
            'clock face',
            'keyboard option',
        ],
    )
    require(
        failures,
        'lib/features/risk/presentation/risk_windows_screen.dart',
        [
            'Use 24-hour time',
            'Ends the next day',
            'SupportBottomNavigation',
            'RiskWindowEditorSheet',
        ],
    )
    forbid(
        failures,
        'lib/features/risk/presentation/risk_windows_screen.dart',
        [
            "labelText: 'Start Hour'",
            "labelText: 'Start Min'",
            "labelText: 'End Hour'",
            "labelText: 'End Min'",
            "label: 'Learn'",
        ],
    )

    if failures:
        print('BA-54 verification failed:')
        for failure in failures:
            print(f' - {failure}')
        return 1

    print('BA-54 verification passed.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
