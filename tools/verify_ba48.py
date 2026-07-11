#!/usr/bin/env python3
from pathlib import Path
import sys

checks = {
    "lib/features/rescue/presentation/widgets/cosmic_breathing_orb.dart": [
        "class CosmicBreathingOrb extends StatelessWidget",
        "CustomPaint",
        "_CosmicOrbPainter",
        "_drawAura",
        "_drawOrbitLines",
        "_drawOrb",
        "_drawOrbitingLights",
        "_drawCenterStar",
        "RadialGradient",
        "Transform.scale",
        "Color.lerp",
        "MaskFilter.blur",
        "shouldRepaint",
    ],
    "lib/features/rescue/presentation/widgets/breathing_card.dart": [
        "import 'cosmic_breathing_orb.dart';",
        "CosmicBreathingOrb(",
        "animation: _controller",
        "running: _running",
        "label: _phaseLabel",
        "scaleFor: _orbScale",
        "void _startBreathing()",
        "static const int _totalCycles = 3",
    ],
}

banned = {
    "lib/features/rescue/presentation/widgets/breathing_card.dart": [
        "final glow = _running",
        "math.sin(_controller.value",
        "child: Container(\n                    width: 148",
    ],
}

failures = []

for file, needles in checks.items():
    path = Path(file)
    if not path.exists():
        failures.append(f"missing file: {file}")
        continue

    text = path.read_text()

    for needle in needles:
        if needle not in text:
            failures.append(f"{file} missing: {needle}")

for file, needles in banned.items():
    path = Path(file)
    if not path.exists():
        continue

    text = path.read_text()

    for needle in needles:
        if needle in text:
            failures.append(
                f"{file} still contains old single-color orb implementation: {needle}"
            )

if failures:
    print("BA-48 verification failed:")
    for failure in failures:
        print(f" - {failure}")
    sys.exit(1)

print(
    "BA-48 verification passed: "
    "multicolor cosmic breathing orb is wired."
)
