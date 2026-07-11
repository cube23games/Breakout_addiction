import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_typography.dart';

class AnimatedDelayRing extends StatelessWidget {
  const AnimatedDelayRing({
    required this.progress,
    required this.remainingLabel,
    super.key,
  });

  final double progress;
  final String remainingLabel;

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0).toDouble();

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: safeProgress),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOut,
      builder: (context, animatedProgress, child) {
        return SizedBox.square(
          dimension: 172,
          child: CustomPaint(
            painter: _DelayRingPainter(
              progress: animatedProgress,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    remainingLabel,
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
    );
  }
}

class _DelayRingPainter extends CustomPainter {
  const _DelayRingPainter({
    required this.progress,
  });

  final double progress;

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

    final sweep = math.pi * 2 * progress;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      progressPaint,
    );

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
    return oldDelegate.progress != progress;
  }
}
