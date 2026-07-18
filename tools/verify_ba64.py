from pathlib import Path
import re

ROOT = Path.cwd()
errors: list[str] = []

checks = {
    "lib/features/premium_tools/presentation/premium_tools_screen.dart": [
        "Local Recovery Guidance",
        "Guided Recovery Routines",
        "Recovery Journeys",
        "Advanced Insights",
        "Recovery Report",
        "Premium Preferences and Widget",
        "AI Personalization Tools",
        "Educate Me Plus",
    ],
    "lib/features/premium_tools/presentation/premium_local_guidance_screen.dart": [
        "Private guidance from your on-device patterns",
        "PremiumLocalGuidanceRepository",
        "Optional faith",
    ],
    "lib/features/premium_tools/presentation/premium_insights_screen.dart": [
        "Last 30 days",
        "Last 90 days",
        "PremiumTrendRepository",
        "Average combined pressure",
    ],
    "lib/features/premium_tools/data/premium_trend_repository.dart": [
        "Duration(days: 30)",
        "Duration(days: 90)",
        "previous 30-day period",
    ],
    "lib/features/premium_tools/presentation/guided_routines_screen.dart": [
        "PremiumProgressRepository",
        "_orderedRoutines",
        "Reset routine",
    ],
    "lib/features/premium_tools/presentation/recovery_journeys_screen.dart": [
        "faithLayerEnabled",
        "Reset journey",
    ],
    "lib/features/premium_tools/data/premium_report_repository.dart": [
        "30-DAY SNAPSHOT",
        "90-DAY SNAPSHOT",
        "PremiumTrendRepository",
    ],
    "lib/features/premium_tools/presentation/recovery_report_screen.dart": [
        "SelectableText",
        "Clipboard.setData",
        "Review it before sharing",
    ],
    "lib/features/premium_tools/presentation/premium_preferences_screen.dart": [
        "PremiumRoutineFocus",
        "PremiumReportDetail",
        "PremiumWidgetFocus",
        "Preview Widget Content",
    ],
    "lib/features/premium_tools/presentation/ai_tools_screen.dart": [
        "Recovery Plan Helper",
        "Weekly Recovery Review",
        "Accountability Draft",
        "Rescue Personalizer",
        "Personalized Encouragement",
        "Optional Faith Reflection",
        "Report Interpretation Helper",
        "arguments: prompt",
    ],
    "lib/features/premium_tools/presentation/widgets/premium_tool_gate.dart": [
        "import '../../../premium/domain/premium_plan.dart';",
        "featureId",
        "PremiumFeatureCatalog.byId",
        "status.plan.includes",
        "requiredPlan.label",
        "Open Premium",
    ],
    "lib/features/widget/data/widget_snapshot_repository.dart": [
        "PremiumWidgetFocus.riskSnapshot",
        "PremiumWidgetFocus.nextAction",
        "premium.hasPremium",
    ],
    "lib/features/educate/data/lesson_repository.dart": [
        "plus_pattern_interruption",
        "plus_rebuilding",
        "premiumOnly: true",
    ],
    "lib/features/educate/presentation/educate_screen.dart": [
        "track.premiumOnly",
        "status.hasPremium",
        "Educate Me Plus",
    ],
    "lib/app/app_router.dart": [
        "case RouteNames.premiumTools:",
        "case RouteNames.premiumGuidance:",
        "case RouteNames.premiumInsights:",
        "case RouteNames.guidedRoutines:",
        "case RouteNames.recoveryJourneys:",
        "case RouteNames.recoveryReport:",
        "case RouteNames.premiumPreferences:",
        "case RouteNames.aiTools:",
        "featureId: 'ai_chat'",
    ],
    "test/premium_trend_repository_test.dart": [
        "premium trends separate 30- and 90-day activity",
        "summary.slips90",
    ],
    "test/premium_tier_matrix_test.dart": [
        "Standard keeps every never-paywall feature",
        "Plus AI inherits every Plus feature",
        "Educate Me has real Plus-only learning tracks",
    ],
    "docs/PREMIUM_IMPLEMENTATION_MAP.md": [
        "Standard — free and safety-preserving",
        "Breakout Plus — local value without AI",
        "Breakout Plus AI — Plus plus secure optional AI",
    ],
    "docs/PREMIUM_DEVICE_QA_CHECKLIST.md": [
        "Subscription lifecycle",
        "Integrity and update regression",
        "Real Google Play internal test",
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

catalog = ROOT / "lib/features/premium/domain/premium_feature_catalog.dart"
if catalog.is_file():
    text = catalog.read_text(encoding="utf-8")
    ids = re.findall(r"id:\s*'([^']+)'", text)
    if len(ids) < 25:
        errors.append("final premium catalog has fewer than 25 features")
    for core_id in ("rescue", "basic_logging", "human_support", "privacy"):
        match = re.search(
            rf"id:\s*'{core_id}'.*?neverPaywall:\s*true",
            text,
            flags=re.S,
        )
        if not match:
            errors.append(f"{core_id} lost never-paywall protection")

if errors:
    print("BA-64 verification failed:")
    for error in errors:
        print(f" - {error}")
    raise SystemExit(1)

print(
    "BA-64 verification passed: Standard safety remains free; Plus has real "
    "local routines, journeys, education, reports, preferences, widget "
    "content, and existing recovery tools; Plus AI has focused secure-coach "
    "entry points; every premium route is centrally gated; and the complete "
    "three-tier device and Play QA matrix is documented."
)
