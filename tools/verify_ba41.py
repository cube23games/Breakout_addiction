#!/usr/bin/env python3
from pathlib import Path
import sys

checks = {
    "docs/ACCOUNTABILITY_MODE_PLAN.md": [
        "Support, not surveillance",
        "Recovery User",
        "Accountability Partner",
        "Separate login/passcode",
        "read-only",
        "MVP local-device version",
        "Share scopes",
        "AI chat history should stay off by default",
        "Partner access must never reveal API keys",
        "Let someone support you without giving them your whole private world",
    ],
    "lib/features/accountability/domain/accountability_scope.dart": [
        "enum AccountabilityScope",
        "progress",
        "recentUrges",
        "relapseEvents",
        "victoryEvents",
        "moodTrends",
        "riskWindows",
        "recoveryPlan",
        "reasonsToStop",
        "supportNeeded",
    ],
    "lib/features/accountability/domain/accountability_settings.dart": [
        "class AccountabilitySettings",
        "enabled",
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
        "savePartnerPasscode",
        "verifyPartnerPasscode",
        "clearPartnerPasscode",
        "AccountabilitySettings.defaults",
    ],
    "lib/features/accountability/presentation/accountability_settings_screen.dart": [
        "class AccountabilitySettingsScreen",
        "Support, not surveillance",
        "Enable Accountability Mode",
        "Partner Passcode",
        "Save Partner Passcode",
        "What can they see?",
        "Private by default",
        "Share AI chat history",
    ],
    "lib/core/constants/route_names.dart": [
        "accountabilitySettings",
        "/accountability-settings",
    ],
    "lib/app/app_router.dart": [
        "AccountabilitySettingsScreen",
        "RouteNames.accountabilitySettings",
    ],
    "lib/features/support/presentation/support_screen.dart": [
        "Accountability Mode",
        "RouteNames.accountabilitySettings",
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

print("BA-41 verification passed: Accountability Mode settings UI is wired.")
