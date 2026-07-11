#!/usr/bin/env python3
from pathlib import Path
import sys

checks = {
    "lib/features/rescue/presentation/widgets/cosmic_breathing_orb.dart": [
        "class CosmicBreathingOrb extends StatelessWidget",
        "CosmicOrbPainter",
        "CustomPaint",
        "GestureDetector",
        "Semantics",
        "Transform.scale",
    ],
    "lib/features/rescue/presentation/widgets/cosmic_orb_painter.dart": [
        "class CosmicOrbPainter extends CustomPainter",
        "drawCosmicOrbBackdrop",
        "drawCosmicOrbForeground",
        "Color.lerp",
        "shouldRepaint",
    ],
    "lib/features/rescue/presentation/widgets/cosmic_orb_backdrop.dart": [
        "drawCosmicOrbBackdrop",
        "drawCosmicOrbCore",
        "RadialGradient",
        "canvas.drawOval",
    ],
    "lib/features/rescue/presentation/widgets/cosmic_orb_core.dart": [
        "drawCosmicOrbCore",
        "RadialGradient",
        "MaskFilter.blur",
        "highlightCenter",
    ],
    "lib/features/rescue/presentation/widgets/cosmic_orb_foreground.dart": [
        "drawCosmicOrbForeground",
        "MaskFilter.blur",
        "canvas.drawPath",
    ],
    "lib/features/rescue/presentation/widgets/breathing_card.dart": [
        "BreathingSessionController",
        "BreathingSessionContent",
        "HapticFeedback.lightImpact",
        "_handleOrbTap",
    ],
    "lib/features/rescue/presentation/widgets/breathing_session_content.dart": [
        "CosmicBreathingOrb(",
        "onTap: running ? null : onOrbTap",
        "semanticLabel:",
        "Stop breathing",
        "Tap the orb to begin.",
    ],
}

failures = []

for filename, needles in checks.items():
    path = Path(filename)

    if not path.exists():
        failures.append(f"missing file: {filename}")
        continue

    text = path.read_text(encoding="utf-8")

    for needle in needles:
        if needle not in text:
            failures.append(f"{filename} missing: {needle}")

if failures:
    print("BA-48 verification failed:")

    for failure in failures:
        print(f" - {failure}")

    sys.exit(1)

print(
    "BA-48 verification passed: modular tappable "
    "cosmic breathing is wired."
)
