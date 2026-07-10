#!/usr/bin/env python3
from pathlib import Path
import sys

required_checks = {
    "lib/core/storage/local_data_safety.dart": [
        "class LocalDataSafety",
        "decodeList",
        "decodeMap",
        "decodeMappedList",
        "enumByName",
        "dateTime",
        "intValue",
        "stringList",
    ],
    "lib/features/ai_chat/data/ai_chat_repository.dart": [
        "LocalDataSafety.decodeMappedList<ChatMessage>",
    ],
    "lib/features/log/data/cycle_stage_log_repository.dart": [
        "LocalDataSafety.decodeMappedList<CycleStageLogEntry>",
    ],
    "lib/features/log/data/mood_log_repository.dart": [
        "LocalDataSafety.decodeMappedList<MoodEntry>",
    ],
    "lib/features/log/data/recovery_event_repository.dart": [
        "LocalDataSafety.decodeMappedList<RecoveryEventEntry>",
    ],
    "lib/features/risk/data/risk_window_repository.dart": [
        "LocalDataSafety.decodeMappedList<RiskWindow>",
    ],
    "lib/features/support/data/recovery_plan_repository.dart": [
        "LocalDataSafety.decodeMap",
        "RecoveryPlan.defaults",
    ],
    "lib/features/support/data/support_contact_repository.dart": [
        "LocalDataSafety.decodeMap",
    ],
    "lib/features/widget/data/app_entry_repository.dart": [
        "LocalDataSafety.decodeMap",
        "await prefs.remove(_pendingKey)",
    ],
    "lib/features/ai_chat/data/ai_chat_settings_repository.dart": [
        "LocalDataSafety.enumByName",
        "ChatProviderMode.mock",
    ],
    "lib/features/onboarding/data/onboarding_repository.dart": [
        "LocalDataSafety.enumByName",
        "QuoteMode.recovery",
    ],
    "lib/features/premium/data/premium_access_repository.dart": [
        "LocalDataSafety.enumByName",
        "fallbackPlan",
    ],
    "lib/features/quotes/data/quote_preferences_repository.dart": [
        "LocalDataSafety.enumByName",
        "QuoteMode.recovery",
    ],
    "lib/features/log/domain/cycle_stage_log_entry.dart": [
        "LocalDataSafety.dateTime",
        "LocalDataSafety.enumByName",
        "LocalDataSafety.intValue",
    ],
    "lib/features/log/domain/mood_entry.dart": [
        "LocalDataSafety.dateTime",
        "LocalDataSafety.intValue",
    ],
    "lib/features/support/domain/recovery_plan.dart": [
        "LocalDataSafety.stringList",
    ],
}

bad_patterns = [
    "jsonDecode(raw) as List<dynamic>",
    "jsonDecode(raw) as Map<String, dynamic>",
    "DateTime.parse(",
    ".values.byName(",
]

failures = []

for file, needles in required_checks.items():
    path = Path(file)
    if not path.exists():
        failures.append(f"missing file: {file}")
        continue

    text = path.read_text()
    for needle in needles:
        if needle not in text:
            failures.append(f"{file} missing: {needle}")

for path in Path("lib").rglob("*.dart"):
    text = path.read_text()
    for bad in bad_patterns:
        if bad in text:
            failures.append(f"{path} still contains crash-prone pattern: {bad}")

if failures:
    print("BA-42 verification failed:")
    for failure in failures:
        print(f" - {failure}")
    sys.exit(1)

print("BA-42 verification passed: local data parsing is crash-hardened.")
