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
        "verifyPartnerPasscode",
        "AccountabilitySettings.defaults",
    ],
    "lib/features/accountability/presentation/accountability_settings_screen.dart": [
        "class AccountabilitySettingsScreen",
        "Enable Accountability Mode",
        "Partner Passcode",
        "Share AI chat history",
    ],
    "lib/features/accountability/presentation/accountability_partner_access_screen.dart": [
        "class AccountabilityPartnerAccessScreen",
        "Read-only support access",
        "Partner passcode",
        "Open Accountability Summary",
        "verifyPartnerPasscode",
        "RouteNames.accountabilitySummary",
        "onPressed: _checking ? () {} : _verify",
    ],
    "lib/features/accountability/presentation/accountability_summary_screen.dart": [
        "class AccountabilitySummaryScreen",
        "Approved read-only view",
        "Shared summary areas",
        "Privacy boundaries",
        "Private notes are not shared",
        "AI chat history is not shared",
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

missing = []

for file, needles in checks.items():
    path = Path(file)
    if not path.exists():
        missing.append(f"missing file: {file}")
        continue

    text = path.read_text()
    for needle in needles:
        if needle not in text:
            missing.append(f"{file} missing: {needle}")

if missing:
    print("BA-41 verification failed:")
    for item in missing:
        print(f" - {item}")
    sys.exit(1)

print("BA-41 verification passed: Accountability partner access and read-only summary are wired.")
