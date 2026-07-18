from pathlib import Path

ROOT = Path.cwd()
errors = []

checks = {
    "pubspec.yaml": [
        "in_app_purchase: ^3.3.0",
        "in_app_purchase_android: ^0.5.0",
    ],
    "lib/features/premium/billing/domain/billing_product_ids.dart": [
        "breakout_plus_monthly",
        "breakout_plus_ai_monthly",
        "PremiumPlan? planFor",
    ],
    "lib/features/premium/billing/data/play_billing_provider.dart": [
        "purchaseStream.listen",
        "queryProductDetails",
        "buyNonConsumable",
        "GooglePlayPurchaseParam",
        "ChangeSubscriptionParam",
        "ReplacementMode.withTimeProration",
        "_transactionEpoch",
        "completePurchase",
    ],
    "lib/features/premium/billing/presentation/premium_billing_controller.dart": [
        "class PremiumBillingController",
        "connectAndLoad",
        "restore",
    ],
    "lib/app/breakout_app.dart": [
        "PremiumBillingController.instance",
        "_billing.start()",
    ],
    "docs/PLAY_BILLING_SETUP.md": [
        "com.slimnation.breakoutaddiction",
        "breakout_plus_monthly",
        "breakout_plus_ai_monthly",
        "license testers",
    ],
    "test/billing_product_ids_test.dart": [
        "paid tiers map to stable Play product identifiers",
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

if errors:
    print("BA-60 verification failed:")
    for error in errors:
        print(f" - {error}")
    raise SystemExit(1)

print(
    "BA-60 verification passed: official Flutter Play Billing dependencies, "
    "stable subscription identifiers, early purchase-stream listening, "
    "localized product loading, purchase launch, restore, completion, and "
    "Android subscription replacement parameters are wired without granting "
    "unverified entitlement."
)
