from pathlib import Path

ROOT = Path.cwd()
errors: list[str] = []

checks = {
    "lib/features/premium_tools/domain/daily_recovery_dashboard.dart": [
        "class DailyRecoveryDashboard",
        "riskScore",
        "weeklyVictories",
        "todayFocus",
    ],
    "lib/features/premium_tools/data/daily_recovery_dashboard_repository.dart": [
        "class DailyRecoveryDashboardRepository",
        "Duration(days: 7)",
        "Duration(days: 30)",
        "_recommendedRoutine",
        "_nextWindow",
        "RecoveryPlanRepository",
    ],
    "lib/features/premium_tools/presentation/daily_recovery_dashboard_screen.dart": [
        "Daily Recovery Dashboard",
        "Today’s Focus",
        "Private Pattern Snapshot",
        "Open Rescue",
        "This Week",
    ],
    "lib/features/premium/domain/premium_feature_catalog.dart": [
        "id: 'daily_dashboard'",
        "title: 'Daily Recovery Dashboard'",
        "requiredPlan: PremiumPlan.plus",
    ],
    "lib/core/constants/route_names.dart": [
        "premiumDashboard",
    ],
    "lib/app/app_router.dart": [
        "case RouteNames.premiumDashboard:",
        "featureId: 'daily_dashboard'",
        "DailyRecoveryDashboardScreen",
    ],
    "lib/features/premium_tools/presentation/premium_tools_screen.dart": [
        "title: 'Daily Recovery Dashboard'",
        "RouteNames.premiumDashboard",
    ],
    "test/daily_recovery_dashboard_repository_test.dart": [
        "daily dashboard combines local risk, plan, and weekly activity",
        "risk_window_prep",
    ],
    ".github/workflows/ci.yml": [
        "python3 tools/verify_ba65.py",
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

router = ROOT / "lib/app/app_router.dart"
if router.is_file():
    text = router.read_text(encoding="utf-8")
    rescue_case = text.split("case RouteNames.rescue:", 1)[-1].split(
        "case RouteNames.cycle:", 1
    )[0]
    if "PremiumToolGate" in rescue_case:
        errors.append("core Rescue is incorrectly premium gated")

if errors:
    print("BA-65 verification failed:")
    for error in errors:
        print(f" - {error}")
    raise SystemExit(1)

print(
    "BA-65 verification passed: Breakout Plus has a private daily recovery "
    "dashboard with a risk snapshot, first action, risk window, recommended "
    "routine, and weekly activity while core Rescue remains free."
)
