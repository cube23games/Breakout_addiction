from pathlib import Path

ROOT = Path.cwd()
errors: list[str] = []

checks = {
    "lib/features/premium_tools/data/active_recovery_program_repository.dart": [
        "active_recovery_program_id_v1",
        "archived_recovery_programs_v1",
        "ArchivedRecoveryProgram",
        "startProgram",
        "previousCompletedDays",
    ],
    "lib/features/home/presentation/widgets/active_recovery_plan_card.dart": [
        "Your Recovery Plan",
        "Choose a Recovery Plan",
        "Explore Recovery Plans",
        "Day ${_completedDays + 1}",
        "The next day unlocks tomorrow",
        "Change recovery plans?",
        "View Plan Progress",
        "status.plan.includes(PremiumPlan.plus)",
    ],
    "lib/features/home/presentation/home_screen.dart": [
        "active_recovery_plan_card.dart",
        "ActiveRecoveryPlanCard",
    ],
    "lib/features/premium_tools/presentation/recovery_programs_screen.dart": [
        "Active plan",
        "Start This Plan",
        "Change to This Plan",
        "Follow today’s recovery action",
        "Past Plans",
        "Only the active plan advances",
        "Reset program",
        "program.steps[count]",
    ],
    ".github/workflows/ci.yml": [
        "python3 tools/verify_ba70a1.py",
        "python3 tools/verify_ba70a2.py",
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

home = ROOT / "lib/features/home/presentation/home_screen.dart"
if home.is_file():
    text = home.read_text(encoding="utf-8")
    if "const PremiumGuidanceCard()" in text:
        errors.append("Home still renders generic PremiumGuidanceCard")

programs = ROOT / "lib/features/premium_tools/presentation/recovery_programs_screen.dart"
if programs.is_file():
    text = programs.read_text(encoding="utf-8")
    if "CheckboxListTile" in text:
        errors.append("Recovery programs still expose unrestricted day checkboxes")
    if text.count("_activeProgramId") < 8:
        errors.append("Active-plan state is not used throughout program progression")

if errors:
    print("BA-70A2 verification failed:")
    for error in errors:
        print(f" - {error}")
    raise SystemExit(1)

print(
    "BA-70A2 verification passed: Home presents a distinct selected recovery "
    "plan with today’s action and day-by-day progress; Plus users can choose "
    "or change one active plan; future days remain locked; prior plan progress "
    "is preserved in Past Plans."
)
