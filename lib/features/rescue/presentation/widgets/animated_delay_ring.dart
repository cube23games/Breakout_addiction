import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_typography.dart';

class AnimatedDelayRing extends StatefulWidget {
  const AnimatedDelayRing({
    required this.deadline,
    required this.totalDuration,
    required this.remainingLabel,
    super.key,
  });

  final DateTime deadline;
  final Duration totalDuration;
  final String remainingLabel;

  @override
  State<AnimatedDelayRing> createState() => _AnimatedDelayRingState();
}

class _AnimatedDelayRingState extends State<AnimatedDelayRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _frameTicker;

  @override
  void initState() {
    super.initState();

    _frameTicker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _frameTicker.dispose();
    super.dispose();
  }

  double _remainingFraction() {
    final totalMilliseconds = widget.totalDuration.inMilliseconds;

    if (totalMilliseconds <= 0) {
      return 0;
    }

    final remainingMilliseconds =
        widget.deadline.difference(DateTime.now()).inMilliseconds;

    return (remainingMilliseconds / totalMilliseconds)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Delay timer',
      value: '${widget.remainingLabel} remaining',
      child: AnimatedBuilder(
        animation: _frameTicker,
        builder: (context, child) {
          return SizedBox.square(
            dimension: 172,
            child: CustomPaint(
              painter: _DelayRingPainter(
                remainingFraction: _remainingFraction(),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.remainingLabel,
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'remaining',
                      style: AppTypography.muted,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DelayRingPainter extends CustomPainter {
  const _DelayRingPainter({
    required this.remainingFraction,
  });

  final double remainingFraction;

  static const Color _cyan = Color(0xFF45F3E5);
  static const Color _blue = Color(0xFF4E8DFF);
  static const Color _violet = Color(0xFF9A6BFF);
  static const Color _pink = Color(0xFFFF71C6);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) / 2) - 12;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(0.08);

    canvas.drawCircle(center, radius, backgroundPaint);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [
          _cyan,
          _blue,
          _violet,
          _pink,
          _cyan,
        ],
      ).createShader(rect);

    final sweep = math.pi * 2 * remainingFraction;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      progressPaint,
    );

    if (remainingFraction <= 0.002) {
      return;
    }

    final angle = -math.pi / 2 + sweep;
    final marker = center +
        Offset(
          math.cos(angle) * radius,
          math.sin(angle) * radius,
        );

    final glowPaint = Paint()
      ..color = _cyan.withOpacity(0.80)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        8,
      );

    canvas.drawCircle(marker, 7, glowPaint);
    canvas.drawCircle(marker, 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_DelayRingPainter oldDelegate) {
    return oldDelegate.remainingFraction != remainingFraction;
  }
}
