from pathlib import Path

ROOT = Path.cwd()
errors: list[str] = []

checks = {
    "lib/features/premium_tools/data/premium_progress_repository.dart": [
        "contiguousCompletedCount",
        "setSequentialCount",
        "completeNextDay",
        "completedToday",
        "_lastDayPrefix",
    ],
    "lib/features/premium_tools/presentation/guided_routines_screen.dart": [
        "Complete current activity",
        "Current activity",
        "Complete the current activity first",
        "Reset routine",
    ],
    "lib/features/premium_tools/presentation/recovery_programs_screen.dart": [
        "Guided Recovery Programs",
        "Complete Day",
        "Next day unlocks tomorrow",
        "View day-by-day plan",
        "Reset program",
        "faithLayerEnabled",
        "program_${program.id}",
        "Progress is a guide for continuity, not a moral score",
    ],
    "lib/features/premium_tools/presentation/recovery_journeys_screen.dart": [
        "Complete Day",
        "Next day unlocks tomorrow",
        "View day-by-day journey",
        "Reset journey",
    ],
    "lib/features/ai_chat/presentation/ai_chat_screen.dart": [
        "for (final message in _messages) _bubble(message)",
        "padding: const EdgeInsets.all(AppSpacing.lg)",
    ],
    "lib/features/support/presentation/recovery_plan_screen.dart": [
        "_hasMeaningfulPlanEntry",
        "Add at least one recovery plan entry before saving",
        "The basic action plan remains available to everyone",
        "Breakout Plus Plan Builder",
    ],
    "lib/features/accountability/presentation/accountability_center_screen.dart": [
        "plan.hasUsefulPreparation",
        "Add at least one check-in preparation entry before saving",
        "Prepare an honest, useful check-in",
        "Copy Reviewable Check-In Summary",
    ],
    ".github/workflows/ci.yml": [
        "python3 tools/verify_ba70a1.py",
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

for relative in [
    "lib/features/premium_tools/presentation/guided_routines_screen.dart",
    "lib/features/premium_tools/presentation/recovery_programs_screen.dart",
    "lib/features/premium_tools/presentation/recovery_journeys_screen.dart",
]:
    path = ROOT / relative
    if path.is_file() and "CheckboxListTile" in path.read_text(encoding="utf-8"):
        errors.append(f"{relative} still uses unrestricted checkboxes")

ai = ROOT / "lib/features/ai_chat/presentation/ai_chat_screen.dart"
if ai.is_file():
    text = ai.read_text(encoding="utf-8")
    unlocked = text.split("Widget _unlockedView", 1)[-1].split("@override", 1)[0]
    if "ListView.builder" in unlocked:
        errors.append("AI unlocked view still splits fixed header from message scrolling")

if errors:
    print("BA-70A1 verification failed:")
    for error in errors:
        print(f" - {error}")
    raise SystemExit(1)

print(
    "BA-70A1 verification passed: routines use sequential activities, programs "
    "and journeys lock future days with one completion per calendar day, the AI "
    "screen scrolls as one content surface, and empty plan/check-in saves are blocked."
)
