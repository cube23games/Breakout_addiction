import 'dart:math' as math;

import 'package:flutter/material.dart';

void drawCosmicOrbForeground({
  required Canvas canvas,
  required Offset center,
  required double size,
  required double progress,
  required double pulse,
  required Color color,
  required Color pink,
  required Color gold,
}) {
  _drawOrbitingLights(
    canvas: canvas,
    center: center,
    size: size,
    progress: progress,
    color: color,
    pink: pink,
    gold: gold,
  );

  _drawCenterStar(
    canvas: canvas,
    center: center,
    size: size,
    pulse: pulse,
  );
}

void _drawOrbitingLights({
  required Canvas canvas,
  required Offset center,
  required double size,
  required double progress,
  required Color color,
  required Color pink,
  required Color gold,
}) {
  final angle = progress * math.pi * 2;
  final secondaryAngle = -progress * math.pi * 2.4;

  final first = center +
      Offset(
        math.cos(angle) * size * 0.43,
        math.sin(angle) * size * 0.25,
      );

  final second = center +
      Offset(
        math.cos(secondaryAngle) * size * 0.36,
        math.sin(secondaryAngle) * size * 0.19,
      );

  final glowPaint = Paint()
    ..color = color.withOpacity(0.85)
    ..maskFilter = const MaskFilter.blur(
      BlurStyle.normal,
      7,
    );

  canvas.drawCircle(first, 5.0, glowPaint);

  canvas.drawCircle(
    second,
    3.5,
    glowPaint..color = pink.withOpacity(0.75),
  );

  canvas.drawCircle(
    first,
    2.2,
    Paint()..color = Colors.white,
  );

  canvas.drawCircle(
    second,
    1.7,
    Paint()..color = gold,
  );
}

void _drawCenterStar({
  required Canvas canvas,
  required Offset center,
  required double size,
  required double pulse,
}) {
  final radius = size * (0.050 + (pulse * 0.012));

  final starPaint = Paint()
    ..color = Colors.white.withOpacity(0.82)
    ..style = PaintingStyle.fill
    ..maskFilter = const MaskFilter.blur(
      BlurStyle.normal,
      2,
    );

  final path = Path()
    ..moveTo(center.dx, center.dy - radius)
    ..lineTo(
      center.dx + radius * 0.24,
      center.dy - radius * 0.24,
    )
    ..lineTo(center.dx + radius, center.dy)
    ..lineTo(
      center.dx + radius * 0.24,
      center.dy + radius * 0.24,
    )
    ..lineTo(center.dx, center.dy + radius)
    ..lineTo(
      center.dx - radius * 0.24,
      center.dy + radius * 0.24,
    )
    ..lineTo(center.dx - radius, center.dy)
    ..lineTo(
      center.dx - radius * 0.24,
      center.dy - radius * 0.24,
    )
    ..close();

  canvas.drawPath(path, starPaint);
}
