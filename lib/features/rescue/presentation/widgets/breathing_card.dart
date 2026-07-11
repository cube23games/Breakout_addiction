import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/info_card.dart';
import 'breathing_session_content.dart';
import 'breathing_session_controller.dart';

class BreathingCard extends StatefulWidget {
  const BreathingCard({super.key});

  @override
  State<BreathingCard> createState() =>
      _BreathingCardState();
}

class _BreathingCardState extends State<BreathingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final BreathingSessionController _session;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: BreathingSessionController.cycleSeconds,
      ),
    );

    _session = BreathingSessionController()
      ..addListener(_handleSessionChange);
  }

  void _handleSessionChange() {
    if (!_session.running) {
      _animationController.stop();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _startBreathing() {
    _animationController
      ..reset()
      ..repeat();

    _session.start();
  }

  void _handleOrbTap() {
    if (_session.running) {
      return;
    }

    HapticFeedback.lightImpact();
    _startBreathing();
  }

  void _stopBreathing() {
    _animationController.stop();
    _session.stop();
  }

  double _orbScale(double controllerValue) {
    final seconds = controllerValue *
        BreathingSessionController.cycleSeconds;

    if (seconds <
        BreathingSessionController.inhaleSeconds) {
      final progress = seconds /
          BreathingSessionController.inhaleSeconds;

      return 0.72 +
          0.34 * Curves.easeInOut.transform(progress);
    }

    final holdEnd =
        BreathingSessionController.inhaleSeconds +
            BreathingSessionController.holdSeconds;

    if (seconds < holdEnd) {
      return 1.06;
    }

    final progress = (seconds - holdEnd) /
        BreathingSessionController.exhaleSeconds;

    return 1.06 -
        0.34 * Curves.easeInOut.transform(progress);
  }

  @override
  void dispose() {
    _session
      ..removeListener(_handleSessionChange)
      ..dispose();

    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: BreathingSessionContent(
        animation: _animationController,
        running: _session.running,
        completed: _session.completed,
        phaseLabel: _session.phaseLabel,
        instruction: _session.instruction,
        currentCycle: _session.currentCycle,
        totalCycles:
            BreathingSessionController.totalCycles,
        secondsLeftInPhase:
            _session.secondsLeftInPhase,
        scaleFor: _orbScale,
        onOrbTap: _handleOrbTap,
        onStop: _stopBreathing,
      ),
    );
  }
}
