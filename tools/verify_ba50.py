#!/usr/bin/env python3
from pathlib import Path
import sys

checks = {
    "lib/app/config/qa_entitlement_gate.dart": [
        "class QaEntitlementGate",
        "bool.fromEnvironment",
        "'BREAKOUT_QA_ENTITLEMENTS'",
        "defaultValue: false",
    ],
    "lib/features/premium/presentation/premium_screen.dart": [
        "import '../../../app/config/qa_entitlement_gate.dart';",
        "Widget _qaEntitlementCard()",
        "QA Entitlement Override",
        "This does not simulate billing or a purchase.",
        "Standard (Free)",
        "if (QaEntitlementGate.enabled)",
        "Normal release builds hide this entire card",
    ],
    ".github/workflows/ci.yml": [
        "Build QA entitlement APK",
        "--dart-define=BREAKOUT_QA_ENTITLEMENTS=true",
        "breakout-addiction-qa-entitlements.apk",
        "name: breakout-addiction-qa-apk",
        "flutter build apk --release",
        "flutter build appbundle --release",
    ],
    "lib/features/premium/domain/premium_plan.dart": [
        "PremiumPlan.none",
        "PremiumPlan.plus",
        "PremiumPlan.plusAi",
        "Breakout Plus",
        "Breakout Plus AI",
    ],
    "lib/features/premium/domain/premium_status.dart": [
        "bool get hasPremium",
        "bool get hasAiPremium",
    ],
    "docs/PREMIUM_QA_AND_VALUE_MATRIX.md": [
        "Standard",
        "Breakout Plus",
        "Breakout Plus AI",
        "What not to paywall",
        "Immediate Rescue access",
        "Plus needs more implemented value",
        "Google Play Billing",
        "Restore Purchases",
        "production-safe backend infrastructure",
    ],
}

banned = {
    "lib/app/config/qa_entitlement_gate.dart": [
        "static const bool enabled = true",
        "defaultValue: true",
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

for filename, needles in banned.items():
    path = Path(filename)

    if not path.exists():
        continue

    text = path.read_text(encoding="utf-8")

    for needle in needles:
        if needle in text:
            failures.append(
                f"{filename} contains unsafe public QA default: {needle}"
            )

if failures:
    print("BA-50 verification failed:")
    for failure in failures:
        print(f" - {failure}")
    sys.exit(1)

print(
    "BA-50 verification passed: "
    "QA entitlement testing is isolated from public builds "
    "and premium value is documented."
)
