#!/usr/bin/env python3
from pathlib import Path
import sys

limits = {
    "lib/features/rescue/presentation/widgets/cosmic_orb_foreground.dart": 140,
    "lib/features/rescue/presentation/widgets/cosmic_orb_backdrop.dart": 190,
    "lib/features/rescue/presentation/widgets/cosmic_orb_core.dart": 120,
    "lib/features/rescue/presentation/widgets/cosmic_orb_painter.dart": 100,
    "lib/features/rescue/presentation/widgets/cosmic_breathing_orb.dart": 120,
    "lib/features/rescue/presentation/widgets/breathing_session_content.dart": 150,
    "lib/features/rescue/presentation/widgets/breathing_session_controller.dart": 140,
    "lib/features/rescue/presentation/widgets/breathing_card.dart": 150,
    "lib/features/rescue/presentation/widgets/delay_actions_card.dart": 190,
    "lib/features/rescue/presentation/widgets/delay_timer_controller.dart": 150,
    "lib/features/rescue/presentation/widgets/active_delay_content.dart": 150,
    "lib/features/rescue/presentation/widgets/completed_delay_content.dart": 210,
    "lib/features/rescue/presentation/widgets/delay_guidance_content.dart": 80,
    "lib/features/onboarding/data/onboarding_completion_service.dart": 80,
    "lib/features/onboarding/presentation/onboarding_screen.dart": 270,
    "lib/features/onboarding/presentation/widgets/onboarding_step_content.dart": 150,
    "lib/features/onboarding/presentation/widgets/onboarding_navigation_controls.dart": 80,
    "lib/features/onboarding/presentation/widgets/onboarding_goal_step.dart": 100,
    "lib/features/onboarding/presentation/widgets/onboarding_preferences_step.dart": 120,
    "lib/features/onboarding/presentation/widgets/onboarding_trigger_step.dart": 130,
    "lib/features/onboarding/presentation/widgets/onboarding_risk_step.dart": 140,
    "lib/features/onboarding/presentation/widgets/onboarding_contact_step.dart": 80,
}

checks = {
    "lib/features/rescue/presentation/widgets/cosmic_orb_core.dart": [
        "drawCosmicOrbCore",
        "MaskFilter.blur",
        "RadialGradient",
    ],
    "lib/features/rescue/presentation/widgets/breathing_card.dart": [
        "BreathingSessionController",
        "BreathingSessionContent",
        "_handleOrbTap",
    ],
    "lib/features/rescue/presentation/widgets/breathing_session_controller.dart": [
        "class BreathingSessionController",
        "Timer.periodic",
        "totalCycles = 3",
    ],
    "lib/features/rescue/presentation/widgets/breathing_session_content.dart": [
        "class BreathingSessionContent",
        "CosmicBreathingOrb",
        "End exercise",
    ],
    "lib/features/rescue/presentation/widgets/cosmic_orb_painter.dart": [
        "class CosmicOrbPainter extends CustomPainter",
        "drawCosmicOrbBackdrop",
        "drawCosmicOrbForeground",
    ],
    "lib/features/onboarding/data/onboarding_completion_service.dart": [
        "class OnboardingCompletionService",
        "Future<void> complete(OnboardingState state)",
        "_onboardingRepository.saveState(state)",
        "_contactRepository.saveContact(contact)",
    ],
    "lib/features/rescue/presentation/widgets/delay_actions_card.dart": [
        "DelayTimerController",
        "ActiveDelayContent",
        "CompletedDelayContent",
        "DelayGuidanceContent.tipFor",
    ],
    "lib/features/rescue/presentation/widgets/delay_timer_controller.dart": [
        "DateTime.now().add(duration)",
        "Duration(milliseconds: 250)",
        "didChangeAppLifecycleState",
    ],
    "lib/features/rescue/presentation/rescue_screen.dart": [
        "onOpenBreathing: () => _scrollTo(_breathingKey)",
        "onReviewReasons: () => _scrollTo(_reasonsKey)",
    ],
}

banned = {
    "lib/features/rescue/presentation/widgets/delay_actions_card.dart": [
        "Timer.periodic",
        "Widget _activeDelayContent",
        "Widget _completedContent",
        "List<String> get _guidanceTips",
    ],
}

failures = []

for filename, maximum in limits.items():
    path = Path(filename)

    if not path.exists():
        failures.append(f"missing file: {filename}")
        continue

    count = len(path.read_text(encoding="utf-8").splitlines())

    if count > maximum:
        failures.append(
            f"{filename} is {count} lines; maximum is {maximum}"
        )

for filename, needles in checks.items():
    path = Path(filename)

    if not path.exists():
        failures.append(f"missing file: {filename}")
        continue

    text = path.read_text(encoding="utf-8")

    for needle in needles:
        if needle not in text:
            failures.append(f"{filename} missing: {needle}")

for filename, needles in banned.items():
    path = Path(filename)

    if not path.exists():
        continue

    text = path.read_text(encoding="utf-8")

    for needle in needles:
        if needle in text:
            failures.append(f"{filename} still contains: {needle}")

if failures:
    print("BA-51 modular verification failed:")
    for failure in failures:
        print(f" - {failure}")
    sys.exit(1)

print(
    "BA-51 modular verification passed: "
    "Delay Actions is split into focused components."
)
