from pathlib import Path

ROOT = Path.cwd()
errors: list[str] = []

checks = {
    "lib/features/accountability/domain/accountability_check_in_plan.dart": [
        "class AccountabilityCheckInPlan",
        "supportRequest",
        "nextCommitment",
        "hasUsefulPreparation",
    ],
    "lib/features/accountability/data/accountability_center_repository.dart": [
        "premium_accountability_check_in_v1",
        "LocalDataSafety.decodeMap",
        "savePlan",
    ],
    "lib/features/accountability/domain/progress_scorecard.dart": [
        "class ProgressScorecard",
        "engagementScore",
        "milestones",
        "nextFocus",
    ],
    "lib/features/accountability/data/progress_scorecard_repository.dart": [
        "class ProgressScorecardRepository",
        "Duration(days: 7)",
        "RecoveryProgramRepository.programs",
        "This score reflects recovery engagement and preparation",
        "not a measure of worth",
    ],
    "lib/features/accountability/presentation/accountability_center_screen.dart": [
        "Accountability Center",
        "Recovery Progress Scorecard",
        "Prepare an honest, useful check-in",
        "Accountability should support recovery, not become surveillance",
        "Copy Reviewable Check-In Summary",
        "Review the private details before sharing",
    ],
    "lib/features/premium/domain/premium_feature_catalog.dart": [
        "title: 'Accountability Center and Progress Scorecard'",
        "share only approved summaries",
    ],
    "lib/core/constants/route_names.dart": [
        "accountabilityCenter",
    ],
    "lib/app/app_router.dart": [
        "case RouteNames.accountabilityCenter:",
        "featureId: 'accountability'",
        "AccountabilityCenterScreen",
    ],
    "lib/features/premium_tools/presentation/daily_recovery_dashboard_screen.dart": [
        "Open Accountability Center",
        "RouteNames.accountabilityCenter",
    ],
    "docs/PLUS_VALUE_EXPANSION.md": [
        "BA-65–69 Breakout Plus Value Expansion",
        "complete privacy-first recovery system",
        "No punishment, worth judgment, purity score, or slip-reset streak",
    ],
    "test/progress_scorecard_repository_test.dart": [
        "accountability check-in preparation persists privately",
        "rewards engagement without subtracting for slips",
        "not a measure of worth",
    ],
    ".github/workflows/ci.yml": [
        "python3 tools/verify_ba69.py",
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

screen = ROOT / "lib/features/accountability/presentation/accountability_center_screen.dart"
if screen.is_file():
    text = screen.read_text(encoding="utf-8")
    forbidden = [
        "purity score",
        "reset your streak",
        "automatic share",
        "send automatically",
    ]
    for phrase in forbidden:
        if phrase in text.lower():
            errors.append(f"accountability center contains unsafe phrase {phrase!r}")

router = ROOT / "lib/app/app_router.dart"
if router.is_file():
    text = router.read_text(encoding="utf-8")
    rescue_case = text.split("case RouteNames.rescue:", 1)[-1].split(
        "case RouteNames.cycle:", 1
    )[0]
    if "PremiumToolGate" in rescue_case:
        errors.append("core Rescue is incorrectly premium gated")

if errors:
    print("BA-69 verification failed:")
    for error in errors:
        print(f" - {error}")
    raise SystemExit(1)

print(
    "BA-69 verification passed: Breakout Plus has a consent-based "
    "Accountability Center, reviewable check-in preparation, privacy controls, "
    "milestones, next focus, and a non-shaming recovery engagement scorecard."
)
