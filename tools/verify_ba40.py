#!/usr/bin/env python3
from pathlib import Path
import sys

checks = {
    "lib/features/ai_chat/domain/ai_recovery_coach_policy.dart": [
        "class AiRecoveryCoachPolicy",
        "recentMessageLimit = 8",
        "maxOutputTokens = 240",
        "systemInstruction",
        "Do not provide sexual content",
        "Do not claim to be therapy",
    ],
    "lib/features/ai_chat/data/gemini_http_transport.dart": [
        "AiRecoveryCoachPolicy",
        "systemInstruction",
        "AiRecoveryCoachPolicy.temperature",
        "AiRecoveryCoachPolicy.maxOutputTokens",
        "AiRecoveryCoachPolicy.recentMessageLimit",
    ],
    "docs/AI_INTEGRATION_PLAN.md": [
        "must not ship a public hardcoded AI API key",
        "Breakout app -> Breakout backend/proxy -> AI provider",
        "fair-use AI support",
        "Remote AI remains optional",
    ],
}

missing = []

for file, needles in checks.items():
    path = Path(file)
    if not path.exists():
        missing.append(f"missing file: {file}")
        continue

    text = path.read_text()
    for needle in needles:
        if needle not in text:
            missing.append(f"{file} missing: {needle}")

if missing:
    print("BA-40 verification failed:")
    for item in missing:
        print(f" - {item}")
    sys.exit(1)

print("BA-40 verification passed: AI safety policy and integration plan are wired.")
