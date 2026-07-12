#!/usr/bin/env python3
from pathlib import Path
import sys

checks = {
    "lib/features/onboarding/presentation/home_entry_screen.dart": [
        "ProtectedRouteGate(",
        "scope: LockScope.app",
        "const HomeScreen()",
        "WelcomeBannerOverlay(",
    ],
    "lib/features/privacy/data/lock_settings_repository.dart": [
        "LockScope? _parseScope",
        ".map(_parseScope)",
        ".whereType<LockScope>()",
    ],
    "lib/features/privacy/domain/lock_settings.dart": [
        "enabledScopes.contains(LockScope.app)",
        "enabledScopes.contains(scope)",
    ],
}

missing = []

for file, needles in checks.items():
    path = Path(file)
    if not path.exists():
        missing.append(f"missing file: {file}")
        continue

    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            missing.append(f"{file} missing: {needle}")

if missing:
    print("BA-39 verification failed:")
    for item in missing:
        print(f" - {item}")
    sys.exit(1)

print(
    "BA-39 verification passed: app-level home locking, "
    "welcome overlay placement, and safe scope parsing are wired."
)
