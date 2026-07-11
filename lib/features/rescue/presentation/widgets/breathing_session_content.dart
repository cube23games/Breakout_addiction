import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import 'cosmic_breathing_orb.dart';

class BreathingSessionContent extends StatelessWidget {
  const BreathingSessionContent({
    required this.animation,
    required this.running,
    required this.completed,
    required this.phaseLabel,
    required this.instruction,
    required this.currentCycle,
    required this.totalCycles,
    required this.secondsLeftInPhase,
    required this.scaleFor,
    required this.onOrbTap,
    required this.onStop,
    super.key,
  });

  final Animation<double> animation;
  final bool running;
  final bool completed;
  final String phaseLabel;
  final String instruction;
  final int currentCycle;
  final int totalCycles;
  final int secondsLeftInPhase;
  final double Function(double value) scaleFor;
  final VoidCallback onOrbTap;
  final VoidCallback onStop;

  String get _statusText {
    if (running) {
      return 'Cycle $currentCycle of $totalCycles • '
          '$secondsLeftInPhase sec';
    }

    if (completed) {
      return 'Session complete';
    }

    return 'One focused minute can change the '
        'direction of the moment.';
  }

  String get _semanticLabel {
    if (running) {
      return 'Breathing exercise active. $phaseLabel.';
    }

    if (completed) {
      return 'Restart breathing exercise.';
    }

    return 'Start breathing exercise.';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Breathe With Me',
          style: AppTypography.section,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Inhale for 4 • hold for 4 • '
          'exhale for 6. Repeat 3 times.',
          style: AppTypography.body,
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: CosmicBreathingOrb(
            animation: animation,
            running: running,
            label: phaseLabel,
            scaleFor: scaleFor,
            onTap: running ? null : onOrbTap,
            semanticLabel: _semanticLabel,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Text(
            instruction,
            style: AppTypography.muted,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: Text(
            _statusText,
            style: AppTypography.muted,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (running)
          Center(
            child: OutlinedButton.icon(
              onPressed: onStop,
              icon: const Icon(
                Icons.stop_circle_outlined,
              ),
              label: const Text('Stop breathing'),
            ),
          )
        else
          Center(
            child: Text(
              completed
                  ? 'Tap the orb to begin again.'
                  : 'Tap the orb to begin.',
              style: AppTypography.muted,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
