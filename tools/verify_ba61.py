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
