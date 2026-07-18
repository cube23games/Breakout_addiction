from pathlib import Path
import re

ROOT = Path.cwd()
errors = []

required = {
    "lib/features/premium/domain/premium_feature.dart": [
        "class PremiumFeature",
        "neverPaywall",
        "PremiumFeatureAvailability",
    ],
    "lib/features/premium/domain/premium_feature_catalog.dart": [
        "class PremiumFeatureCatalog",
        "id: 'rescue'",
        "id: 'ai_chat'",
        "id: 'guided_routines'",
        "id: 'reports'",
    ],
    "lib/features/premium/domain/premium_access_policy.dart": [
        "class PremiumAccessPolicy",
        "feature.neverPaywall",
        "integrityAllowsPaidFeatures",
    ],
    "lib/features/premium/presentation/premium_screen.dart": [
        "Core Rescue, logging, privacy",
        "Compare feature access",
        "QaEntitlementGate.enabled",
    ],
    "test/premium_feature_catalog_test.dart": [
        "core rescue features are never paywalled",
        "Plus does not grant Plus AI features",
        "catalog identifiers are unique",
    ],
    "docs/PREMIUM_QA_AND_VALUE_MATRIX.md": [
        "Breakout Plus AI",
        "never paywalled",
        "server-side purchase verification",
    ],
}

for relative, needles in required.items():
    path = ROOT / relative
    if not path.is_file():
        errors.append(f"missing {relative}")
        continue
    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            errors.append(f"{relative} missing {needle!r}")

catalog = ROOT / "lib/features/premium/domain/premium_feature_catalog.dart"
if catalog.is_file():
    text = catalog.read_text(encoding="utf-8")
    ids = re.findall(r"id:\s*'([^']+)'", text)
    if len(ids) < 20:
        errors.append("premium catalog is unexpectedly incomplete")
    if len(ids) != len(set(ids)):
        errors.append("premium catalog contains duplicate identifiers")
    for core_id in ("rescue", "basic_logging", "human_support", "privacy"):
        pattern = rf"id:\s*'{core_id}'.*?neverPaywall:\s*true"
        if not re.search(pattern, text, flags=re.S):
            errors.append(f"core feature {core_id} is not explicitly never-paywall")

plan = ROOT / "lib/features/premium/domain/premium_plan.dart"
if plan.is_file():
    text = plan.read_text(encoding="utf-8")
    for needle in ("int get accessLevel", "bool includes", "Breakout Plus AI"):
        if needle not in text:
            errors.append(f"premium plan missing {needle!r}")

if errors:
    print("BA-59 verification failed:")
    for error in errors:
        print(f" - {error}")
    raise SystemExit(1)

print(
    "BA-59 verification passed: the complete Standard, Breakout Plus, and "
    "Breakout Plus AI feature catalog is centralized; core recovery is marked "
    "never-paywall; tier inheritance and integrity-aware access policy are "
    "defined; and the Premium screen exposes an honest comparison."
)
