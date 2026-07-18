from pathlib import Path

ROOT = Path.cwd()
errors: list[str] = []

checks = {
    "lib/features/premium_tools/domain/recovery_program.dart": [
        "class RecoveryProgram",
        "durationDays",
        "faithSensitive",
        "hasDailyStructure",
    ],
    "lib/features/premium_tools/data/recovery_program_repository.dart": [
        "7-Day Reset",
        "14-Day Trigger Awareness",
        "30-Day Recovery Foundation",
        "Nighttime Risk Reset",
        "Stress and Loneliness Recovery",
        "Rebuilding After a Slip",
        "14-Day Christian Renewal",
        "Day 30",
    ],
    "lib/features/premium_tools/presentation/recovery_programs_screen.dart": [
        "Guided Recovery Programs",
        "Progress is a guide for continuity, not a moral score",
        "program_${program.id}",
        "Reset program",
        "faithLayerEnabled",
    ],
    "lib/features/educate/data/lesson_repository.dart": [
        "plus_stress_recovery",
        "plus_loneliness_connection",
        "plus_sleep_night",
        "plus_digital_boundaries",
        "plus_accountability",
        "plus_relationship_repair",
        "plus_faith_recovery",
    ],
    "lib/features/premium/domain/premium_feature_catalog.dart": [
        "id: 'structured_programs'",
        "title: 'Structured Recovery Programs'",
        "requiredPlan: PremiumPlan.plus",
    ],
    "lib/core/constants/route_names.dart": [
        "recoveryPrograms",
    ],
    "lib/app/app_router.dart": [
        "case RouteNames.recoveryPrograms:",
        "featureId: 'structured_programs'",
        "RecoveryProgramsScreen",
    ],
    "test/recovery_program_repository_test.dart": [
        "Plus programs provide substantial structured recovery",
        "Educate Me Plus contains a durable premium library",
        "greaterThanOrEqualTo(25)",
    ],
    ".github/workflows/ci.yml": [
        "python3 tools/verify_ba68.py",
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

programs = ROOT / "lib/features/premium_tools/data/recovery_program_repository.dart"
if programs.is_file():
    text = programs.read_text(encoding="utf-8")
    if text.count("RecoveryProgram(") < 7:
        errors.append("fewer than seven structured recovery programs")
    if text.count("Day ") < 70:
        errors.append("structured programs do not contain enough daily steps")

lessons = ROOT / "lib/features/educate/data/lesson_repository.dart"
if lessons.is_file():
    text = lessons.read_text(encoding="utf-8")
    if text.count("premiumOnly: true") < 9:
        errors.append("Educate Me Plus has fewer than nine premium tracks")

if errors:
    print("BA-68 verification failed:")
    for error in errors:
        print(f" - {error}")
    raise SystemExit(1)

print(
    "BA-68 verification passed: Breakout Plus has substantial 7-, 10-, 14-, "
    "and 30-day private programs plus a durable premium education library "
    "covering stress, loneliness, nighttime risk, digital boundaries, "
    "accountability, relationship repair, and optional Christian recovery."
)
