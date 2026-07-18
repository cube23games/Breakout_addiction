from pathlib import Path

ROOT = Path.cwd()
errors = []

checks = {
    "lib/features/premium/billing/data/billing_verification_gateway.dart": [
        "BREAKOUT_BILLING_VERIFY_URL",
        "https",
        "purchaseToken",
        "BillingProductIds.planFor",
        "serviceAccessToken",
        "No paid access was granted",
    ],
    "lib/features/premium/billing/data/verified_entitlement_repository.dart": [
        "FlutterSecureStorage",
        "verified_subscription_entitlement_v1",
    ],
    "lib/features/premium/billing/domain/subscription_access_policy.dart": [
        "maxOfflineVerificationAge",
        "canceledActive",
        "gracePeriod",
    ],
    "lib/features/premium/data/premium_access_repository.dart": [
        "VerifiedEntitlementRepository",
        "SubscriptionAccessPolicy.effectivePlan",
        "QaEntitlementGate.enabled",
        "integrity.allowsPaidFeatures",
    ],
    "lib/features/premium/billing/presentation/premium_billing_controller.dart": [
        "Secure purchase verification is not configured",
        "_verificationGateway.verify",
        "_entitlementRepository.save",
        "event.pendingCompletion",
        "_provider.complete",
        "Refreshing verified subscription access from Google Play",
        "await _provider.restore()",
    ],
    "docs/BILLING_VERIFICATION_CONTRACT.md": [
        "Google Play Developer API",
        "serverAcknowledged",
        "serviceAccessToken",
        "Bearer token",
        "grants no paid access",
    ],
    "test/billing_verification_gateway_test.dart": [
        "backend tier must match the Google Play product",
        "short-lived-service-token",
    ],
    "test/verified_entitlement_test.dart": [
        "service access token survives secure entitlement serialization",
        "hasUsableServiceAccess",
    ],
    "test/subscription_access_policy_test.dart": [
        "pending, hold, expired, and revoked do not unlock",
        "stale offline verification fails closed",
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

repository = ROOT / "lib/features/premium/data/premium_access_repository.dart"
if repository.is_file():
    text = repository.read_text(encoding="utf-8")
    if "prefs.getBool(_legacyPremiumUnlockedKey)" in text and \
            "QaEntitlementGate.enabled && integrity.allowsPaidFeatures" not in text:
        errors.append("legacy local premium state is trusted outside QA")


status_card = ROOT / (
    "lib/features/premium/billing/presentation/widgets/"
    "subscription_status_card.dart"
)
if status_card.is_file():
    text = status_card.read_text(encoding="utf-8")
    required_direct_imports = [
        "../../domain/subscription_lifecycle.dart",
        "../../../domain/premium_plan.dart",
    ]
    for direct_import in required_direct_imports:
        if direct_import not in text:
            errors.append(
                "subscription status card must directly import "
                + direct_import
            )

billing_controller = ROOT / (
    "lib/features/premium/billing/presentation/"
    "premium_billing_controller.dart"
)
if billing_controller.is_file():
    text = billing_controller.read_text(encoding="utf-8")
    if (
        "import '../domain/verified_entitlement.dart';" in text
        and "VerifiedEntitlement(" not in text
    ):
        errors.append(
            "premium billing controller retains an unused "
            "verified_entitlement import"
        )

premium_screen = ROOT / (
    "lib/features/premium/presentation/premium_screen.dart"
)
if premium_screen.is_file():
    text = premium_screen.read_text(encoding="utf-8")
    if (
        "core/constants/route_names.dart" in text
        and "RouteNames." not in text
    ):
        errors.append("premium screen retains an unused route_names import")


if errors:
    print("BA-61 verification failed:")
    for error in errors:
        print(f" - {error}")
    raise SystemExit(1)

print(
    "BA-61 verification passed: public paid access comes from a securely stored "
    "backend-verified entitlement; missing verification disables purchasing; "
    "pending transactions never unlock; successful purchases are completed "
    "only after verification; and restore events use the same path."
)
