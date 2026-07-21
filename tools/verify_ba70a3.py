from pathlib import Path

ROOT = Path.cwd()
errors: list[str] = []

checks = {
    "lib/core/privacy/neutral_labels.dart": [
        "return neutralMode ? 'Open Rescue' : 'I feel an urge';",
        "return 'Open Rescue';",
    ],
    "lib/features/log/presentation/mood_log_screen.dart": [
        "'Other',",
        "_otherMoodController",
        "Describe this moment before saving.",
        "Other — $otherMood",
        "if (_moodLabel == 'Other')",
        "labelText: 'Describe this moment'",
    ],
    ".github/workflows/ci.yml": [
        "python3 tools/verify_ba70a3.py",
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

neutral = ROOT / "lib/core/privacy/neutral_labels.dart"
if neutral.is_file():
    text = neutral.read_text(encoding="utf-8")
    if "'Daily Reset'" in text:
        errors.append("Neutral Rescue labels still misuse 'Daily Reset'")

quick = ROOT / "lib/features/home/presentation/widgets/quick_actions_row.dart"
if quick.is_file():
    text = quick.read_text(encoding="utf-8")
    if "NeutralLabels.rescuePrimary" in text or "RouteNames.rescue" in text:
        errors.append("Home Quick Actions still duplicates the Rescue action")
    if text.count("_fullButton(") != 3:
        errors.append("Quick Actions helper/button structure changed unexpectedly")

mood = ROOT / "lib/features/log/presentation/mood_log_screen.dart"
if mood.is_file():
    text = mood.read_text(encoding="utf-8")
    if text.count("'Other'") < 4:
        errors.append("Mood Other path is incomplete")
    save_section = text.split("Future<void> _saveMood()", 1)[-1].split(
        "Widget _buildSlider", 1
    )[0]
    if "otherMood.isEmpty" not in save_section:
        errors.append("Empty custom mood is not blocked before saving")

if errors:
    print("BA-70A3 verification failed:")
    for error in errors:
        print(f" - {error}")
    raise SystemExit(1)

print(
    "BA-70A3 verification passed: Rescue is no longer mislabeled as Daily Reset, "
    "Home no longer duplicates the Rescue action, and Mood Log supports a "
    "validated custom Other label. Startup layering is verified by BA-70A4."
)
