import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/info_card.dart';
import 'cosmic_breathing_orb.dart';

class BreathingCard extends StatefulWidget {
  const BreathingCard({super.key});

  @override
  State<BreathingCard> createState() => _BreathingCardState();
}

class _BreathingCardState extends State<BreathingCard>
    with SingleTickerProviderStateMixin {
  static const int _inhaleSeconds = 4;
  static const int _holdSeconds = 4;
  static const int _exhaleSeconds = 6;
  static const int _cycleSeconds = _inhaleSeconds + _holdSeconds + _exhaleSeconds;
  static const int _totalCycles = 3;
  static const int _totalSeconds = _cycleSeconds * _totalCycles;

  late final AnimationController _controller;
  Timer? _timer;

  int _elapsedSeconds = 0;
  bool _running = false;
  bool _completed = false;

  int get _phaseSecond => _elapsedSeconds % _cycleSeconds;

  int get _currentCycle {
    if (_elapsedSeconds >= _totalSeconds) {
      return _totalCycles;
    }
    return (_elapsedSeconds ~/ _cycleSeconds) + 1;
  }

  String get _phaseLabel {
    if (_completed) {
      return 'Done';
    }
    if (!_running) {
      return 'Ready';
    }
    if (_phaseSecond < _inhaleSeconds) {
      return 'Inhale';
    }
    if (_phaseSecond < _inhaleSeconds + _holdSeconds) {
      return 'Hold';
    }
    return 'Exhale';
  }

  String get _instruction {
    switch (_phaseLabel) {
      case 'Inhale':
        return 'Breathe in slowly.';
      case 'Hold':
        return 'Hold gently.';
      case 'Exhale':
        return 'Let it out slowly.';
      case 'Done':
        return 'Good. You slowed the moment down.';
      default:
        return 'Tap start and follow the orb.';
    }
  }

  int get _secondsLeftInPhase {
    if (!_running) {
      return 0;
    }

    if (_phaseSecond < _inhaleSeconds) {
      return _inhaleSeconds - _phaseSecond;
    }

    if (_phaseSecond < _inhaleSeconds + _holdSeconds) {
      return _inhaleSeconds + _holdSeconds - _phaseSecond;
    }

    return _cycleSeconds - _phaseSecond;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _cycleSeconds),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startBreathing() {
    _timer?.cancel();
    _controller
      ..reset()
      ..repeat();

    setState(() {
      _elapsedSeconds = 0;
      _running = true;
      _completed = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_elapsedSeconds >= _totalSeconds - 1) {
        timer.cancel();
        _controller.stop();
        setState(() {
          _elapsedSeconds = _totalSeconds;
          _running = false;
          _completed = true;
        });
        return;
      }

      setState(() {
        _elapsedSeconds += 1;
      });
    });
  }

  void _stopBreathing() {
    _timer?.cancel();
    _controller.stop();

    setState(() {
      _elapsedSeconds = 0;
      _running = false;
      _completed = false;
    });
  }

  double _orbScale(double controllerValue) {
    final seconds = controllerValue * _cycleSeconds;

    if (seconds < _inhaleSeconds) {
      final t = seconds / _inhaleSeconds;
      return 0.72 + (0.34 * Curves.easeInOut.transform(t));
    }

    if (seconds < _inhaleSeconds + _holdSeconds) {
      return 1.06;
    }

    final t = (seconds - _inhaleSeconds - _holdSeconds) / _exhaleSeconds;
    return 1.06 - (0.34 * Curves.easeInOut.transform(t));
  }

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Breathe With Me', style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Inhale for 4 • hold for 4 • exhale for 6. Repeat 3 times.',
            style: AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: CosmicBreathingOrb(
              animation: _controller,
              running: _running,
              label: _phaseLabel,
              scaleFor: _orbScale,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              _instruction,
              style: AppTypography.muted,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              _running
                  ? 'Cycle $_currentCycle of $_totalCycles • $_secondsLeftInPhase sec'
                  : _completed
                      ? 'Session complete'
                      : 'One focused minute can change the direction of the moment.',
              style: AppTypography.muted,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _running ? null : _startBreathing,
                  child: Text(_completed ? 'Start again' : 'Start breathing'),
                ),
              ),
              if (_running) ...[
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _stopBreathing,
                    child: const Text('Stop'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
