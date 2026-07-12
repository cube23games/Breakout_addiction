#!/usr/bin/env python3
from pathlib import Path
import sys

checks = {
    "docs/ACCOUNTABILITY_MODE_PLAN.md": [
        "Support, not surveillance",
        "Accountability Partner",
        "Separate login/passcode",
        "read-only",
        "AI chat history should stay off by default",
    ],
    "lib/features/accountability/domain/accountability_scope.dart": [
        "enum AccountabilityScope",
        "progress",
        "recentUrges",
        "relapseEvents",
        "victoryEvents",
        "riskWindows",
        "recoveryPlan",
    ],
    "lib/features/accountability/domain/accountability_settings.dart": [
        "class AccountabilitySettings",
        "sharedScopes",
        "sharePrivateNotes = false",
        "shareAiChatHistory = false",
        "canUsePartnerAccess",
        "_parseScope",
    ],
    "lib/features/accountability/data/accountability_settings_repository.dart": [
        "class AccountabilitySettingsRepository",
        "FlutterSecureStorage",
        "_partnerPasscodeKey",
        "getPartnerCredentialMode",
        "verifyPartnerPasscode",
        "AccountabilitySettings.defaults",
    ],
    "lib/features/accountability/presentation/accountability_settings_screen.dart": [
        "class AccountabilitySettingsScreen",
        "Enable Accountability Mode",
        "Partner Access Credential",
        "CredentialInputMode.values",
        "Share private notes",
    ],
    "lib/features/accountability/presentation/accountability_partner_access_screen.dart": [
        "class AccountabilityPartnerAccessScreen",
        "Read-only support access",
        "Partner ${_credentialMode.label}",
        "Incorrect partner ${_credentialMode.label}. Try again.",
        "Open Accountability Summary",
        "verifyPartnerPasscode",
        "RouteNames.accountabilitySummary",
    ],
    "lib/features/accountability/presentation/accountability_summary_screen.dart": [
        "class AccountabilitySummaryScreen",
        "Approved read-only view",
        "Shared summary areas",
        "Privacy boundaries",
        "Private notes are not shared",
        "Only the selected summary areas are shown.",
    ],
    "lib/core/constants/route_names.dart": [
        "accountabilitySettings",
        "accountabilityPartnerAccess",
        "accountabilitySummary",
    ],
    "lib/app/app_router.dart": [
        "AccountabilitySettingsScreen",
        "AccountabilityPartnerAccessScreen",
        "AccountabilitySummaryScreen",
        "RouteNames.accountabilityPartnerAccess",
        "RouteNames.accountabilitySummary",
    ],
    "lib/features/support/presentation/support_screen.dart": [
        "Accountability Mode",
        "Accountability Partner Access",
        "RouteNames.accountabilityPartnerAccess",
    ],
}

forbidden = {
    "lib/features/accountability/presentation/accountability_settings_screen.dart": [
        "Share AI chat history",
    ],
    "lib/features/accountability/presentation/accountability_summary_screen.dart": [
        "AI provider access",
        "AI chat history is not shared.",
        "AI chat sharing is enabled",
    ],
}

failures = []

for filename, needles in checks.items():
    path = Path(filename)
    if not path.exists():
        failures.append(f"missing file: {filename}")
        continue

    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            failures.append(f"{filename} missing: {needle}")

for filename, needles in forbidden.items():
    path = Path(filename)
    if not path.exists():
        continue

    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle in text:
            failures.append(f"{filename} still exposes: {needle}")

if failures:
    print("BA-41 verification failed:")
    for item in failures:
        print(f" - {item}")
    sys.exit(1)

print(
    "BA-41 verification passed: separate credential-aware "
    "accountability access and read-only privacy boundaries are wired."
)
