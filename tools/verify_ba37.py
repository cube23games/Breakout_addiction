#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

def read(rel):
    path = ROOT / rel
    if not path.exists():
        print(f"FAIL missing file: {rel}")
        sys.exit(1)
    return path.read_text()

checks = [
    ("lib/features/rescue/data/reasons_to_stop_repository.dart", ["Other"]),
    (
        "lib/features/log/domain/recovery_event_entry.dart",
        ["reason", "trigger", "displayReason", "displayTrigger", "'trigger': trigger"],
    ),
    (
        "lib/features/log/data/recovery_event_repository.dart",
        ["reason", "trigger", "updateEntry", "deleteEntry"],
    ),
    (
        "lib/features/log/presentation/recovery_event_log_screen.dart",
        ["Other", "Edit Recovery Event", "reason", "trigger"],
    ),
    (
        "lib/features/log/presentation/log_hub_screen.dart",
        ["_confirmDeleteEvent", "_editEvent", "Delete", "showDialog", "Undo"],
    ),
    (
        "lib/features/rescue/presentation/rescue_screen.dart",
        ["Use this as a quick gut-check"],
    ),
    (
        "lib/features/rescue/presentation/widgets/delay_actions_card.dart",
        ["SnackBarBehavior.floating", "backgroundColor: const Color(0xFF13212C)"],
    ),
]

failures = []

for rel, needles in checks:
    text = read(rel)
    for needle in needles:
        if needle not in text:
            failures.append(f"{rel} missing: {needle}")

if failures:
    print("BA-37 verification failed:")
    for failure in failures:
        print(f" - {failure}")
    sys.exit(1)

print("BA-37 verification passed.")
