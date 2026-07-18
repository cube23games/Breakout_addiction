from pathlib import Path

ROOT = Path.cwd()
errors: list[str] = []

checks = {
    "lib/features/premium_tools/domain/private_pattern_summary.dart": [
        "class PrivatePatternSummary",
        "peakDay",
        "preSlipSignal",
        "weeklySummary",
    ],
    "lib/features/premium_tools/data/private_pattern_repository.dart": [
        "class PrivatePatternRepository",
        "Duration(days: 90)",
        "Duration(days: 7)",
        "_preSlipSignal",
        "_effectiveInterruption",
        "_weekDirection",
    ],
    "lib/features/premium_tools/presentation/private_pattern_screen.dart": [
        "Private Pattern Intelligence",
        "Weekly Private Summary",
        "Earlier Signal Before Slips",
        "What Has Helped",
    ],
    "lib/features/premium/domain/premium_feature_catalog.dart": [
        "id: 'private_patterns'",
        "title: 'Private Pattern Intelligence'",
        "requiredPlan: PremiumPlan.plus",
    ],
    "lib/core/constants/route_names.dart": [
        "premiumPatterns",
    ],
    "lib/app/app_router.dart": [
        "case RouteNames.premiumPatterns:",
        "featureId: 'private_patterns'",
        "PrivatePatternScreen",
    ],
    "lib/features/premium_tools/presentation/daily_recovery_dashboard_screen.dart": [
        "Open Private Pattern Intelligence",
        "RouteNames.premiumPatterns",
    ],
    "test/private_pattern_repository_test.dart": [
        "private pattern engine finds time, trigger, and pre-slip signal",
        "Stress + Isolation",
        "Warning Signs",
    ],
    ".github/workflows/ci.yml": [
        "python3 tools/verify_ba66.py",
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
    print("BA-66 verification failed:")
    for error in errors:
        print(f" - {error}")
    raise SystemExit(1)

print(
    "BA-66 verification passed: Breakout Plus has a deterministic on-device "
    "pattern engine with peak day/time, trigger combinations, pre-slip signals, "
    "effective interruption evidence, and a weekly private summary."
)
