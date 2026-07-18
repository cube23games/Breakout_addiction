from pathlib import Path

ROOT = Path.cwd()
errors: list[str] = []

checks = {
    "lib/features/support/domain/recovery_plan.dart": [
        "warningSigns",
        "highRiskTimes",
        "postSlipPlan",
        "morningCommitment",
        "eveningCommitment",
        "reviewDate",
        "completedSections",
        "completion",
        "LocalDataSafety.stringList(map['warningSigns'])",
    ],
    "lib/features/support/presentation/recovery_plan_screen.dart": [
        "The basic action plan remains available to everyone",
        "Breakout Plus Plan Builder",
        "Early Warning Signs",
        "Primary Triggers",
        "High-Risk Times",
        "Morning Commitment",
        "Evening Commitment",
        "Post-Slip Rebuild Plan",
        "Plan Readiness",
        "Open Breakout Plus",
    ],
    "lib/features/premium_tools/data/premium_report_repository.dart": [
        "Warning signs:",
        "Post-slip rebuild:",
        "Plan readiness:",
    ],
    "lib/features/accountability/data/accountability_summary_repository.dart": [
        "Warning signs:",
        "Morning commitment:",
        "Plan readiness:",
    ],
    "lib/features/premium/domain/premium_feature_catalog.dart": [
        "title: 'Advanced Recovery Plan Builder'",
        "around the free core action plan",
    ],
    "test/recovery_plan_builder_test.dart": [
        "legacy recovery plan data remains readable",
        "advanced recovery plan reports meaningful readiness",
        "expect(plan.completion, 1)",
    ],
    ".github/workflows/ci.yml": [
        "python3 tools/verify_ba67.py",
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

screen = ROOT / "lib/features/support/presentation/recovery_plan_screen.dart"
if screen.is_file():
    text = screen.read_text(encoding="utf-8")
    if "if (!_hasPlus)" not in text:
        errors.append("advanced plan fields are not tier gated")
    if "RouteNames.rescue" in text:
        errors.append("recovery plan screen should not redirect core Rescue")

if errors:
    print("BA-67 verification failed:")
    for error in errors:
        print(f" - {error}")
    raise SystemExit(1)

print(
    "BA-67 verification passed: the free core recovery action plan remains "
    "available while Breakout Plus adds warning signs, triggers, high-risk "
    "times, daily commitments, post-slip rebuilding, review dates, readiness, "
    "and richer private reports."
)
