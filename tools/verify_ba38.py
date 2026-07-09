#!/usr/bin/env python3
from pathlib import Path
import sys

checks = {
    "lib/app/theme/app_theme.dart": [
        "snackBarTheme: const SnackBarThemeData",
        "behavior: SnackBarBehavior.floating",
        "backgroundColor: Color(0xFF13212C)",
    ],
    "lib/app/config/internal_surface_gate.dart": [
        "class InternalSurfaceGate",
        "static bool get showDevSurfaces => false",
    ],
    "lib/features/home/presentation/home_screen.dart": [
        "InternalSurfaceGate.showDevSurfaces",
        "const DemoReadinessCard()",
        "About Breakout for app details",
    ],
    "lib/features/support/presentation/support_screen.dart": [
        "String _maskedTrustedContactPhone",
        "_maskedTrustedContactPhone(_trustedContact!.phone)",
        "Choose the support tools, privacy options",
        "InternalSurfaceGate.showDevSurfaces",
        "label: 'Release Readiness'",
        "label: 'Open Widget Preview'",
        "label: 'Open Feature Controls'",
    ],
    "lib/features/premium/presentation/premium_screen.dart": [
        "InternalSurfaceGate.showDevSurfaces",
        "Breakout Plus adds deeper local guidance",
    ],
    "test/widget_test.dart": [
        "expect(find.text('Demo Readiness'), findsNothing)",
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
    print("BA-38 verification failed:")
    for item in missing:
        print(f" - {item}")
    sys.exit(1)

print("BA-38 verification passed: public polish and internal dev surface gating are wired.")
