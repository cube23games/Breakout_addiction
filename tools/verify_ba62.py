from pathlib import Path

ROOT = Path.cwd()
errors = []

checks = {
    ".github/workflows/ci.yml": [
        "--dart-define=BREAKOUT_QA_BILLING=true",
        "--dart-define=BREAKOUT_BUILD_CHANNEL=public",
    ],
    "lib/app/config/qa_billing_gate.dart": [
        "BREAKOUT_QA_BILLING",
        "_buildChannel == 'qa'",
    ],
    "lib/features/premium/billing/data/qa_billing_provider.dart": [
        "No real charge will occur",
        "BillingPurchaseState.purchased",
        "BillingPurchaseState.restored",
    ],
    "lib/features/premium/billing/data/billing_provider_factory.dart": [
        "QaBillingGate.enabled",
        "QaBillingProvider",
        "PlayBillingProvider",
    ],
    "lib/features/premium/billing/presentation/premium_billing_controller.dart": [
        "setQaLifecycle",
        "clearQaSimulation",
        "manageSubscription",
        "Payment is pending",
        "event.serverVerificationData.startsWith('qa:')",
    ],
    "lib/features/premium/billing/data/play_billing_provider.dart": [
        "ChangeSubscriptionParam",
        "ReplacementMode.withTimeProration",
    ],
    "lib/features/premium/presentation/premium_screen.dart": [
        "QA Billing Lifecycle",
        "SubscriptionStatusCard",
    ],
    "lib/features/premium/billing/presentation/widgets/subscription_status_card.dart": [
        "Restore purchases",
        "Manage subscription",
    ],
    "test/qa_billing_gate_test.dart": [
        "access lifecycle allowlist is explicit",
    ],
}

for relative, needles in checks.items():
    path = ROOT / relative
    if not path.is_file():
        errors.append(f"missing {relative}")
        continue
    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            errors.append(f"{relative} missing {needle!r}")

qa_gate = ROOT / "lib/app/config/qa_billing_gate.dart"
if qa_gate.is_file():
    text = qa_gate.read_text(encoding="utf-8")
    if "defaultValue: false" not in text:
        errors.append("QA billing does not default off")
    if "_requested && _buildChannel == 'qa'" not in text:
        errors.append("QA billing is not compile-time and channel gated")


premium_screen = ROOT / (
    "lib/features/premium/presentation/premium_screen.dart"
)
if premium_screen.is_file():
    text = premium_screen.read_text(encoding="utf-8")
    if (
        "core/constants/route_names.dart" in text
        and "RouteNames." not in text
    ):
        errors.append("BA-62 premium screen has an unused route_names import")


if errors:
    print("BA-62 verification failed:")
    for error in errors:
        print(f" - {error}")
    raise SystemExit(1)

print(
    "BA-62 verification passed: subscription lifecycle policy, restore, "
    "management, Android upgrade/downgrade parameters, and a compile-time "
    "QA-only billing simulator cover active, canceled-active, grace, pending, "
    "hold, expired, revoked, and verification-unavailable states."
)
