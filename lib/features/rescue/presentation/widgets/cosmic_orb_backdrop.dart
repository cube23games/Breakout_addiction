import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'cosmic_orb_core.dart';

void drawCosmicOrbBackdrop({
  required Canvas canvas,
  required Offset center,
  required double size,
  required double progress,
  required double pulse,
  required Color colorA,
  required Color colorB,
  required Color pink,
}) {
  _drawAura(
    canvas: canvas,
    center: center,
    size: size,
    pulse: pulse,
    colorA: colorA,
    colorB: colorB,
  );

  _drawOrbitLines(
    canvas: canvas,
    center: center,
    size: size,
    progress: progress,
    colorA: colorA,
    colorB: colorB,
    pink: pink,
  );

  drawCosmicOrbCore(
    canvas: canvas,
    center: center,
    size: size,
    pulse: pulse,
    colorA: colorA,
    colorB: colorB,
  );
}

void _drawAura({
  required Canvas canvas,
  required Offset center,
  required double size,
  required double pulse,
  required Color colorA,
  required Color colorB,
}) {
  final auraPaint = Paint()
    ..shader = RadialGradient(
      colors: [
        colorA.withOpacity(0.24 + (pulse * 0.10)),
        colorB.withOpacity(0.12),
        Colors.transparent,
      ],
      stops: const [
        0.05,
        0.54,
        1.0,
      ],
    ).createShader(
      Rect.fromCircle(
        center: center,
        radius: size * 0.50,
      ),
    );

  canvas.drawCircle(
    center,
    size * 0.50,
    auraPaint,
  );
}

void _drawOrbitLines({
  required Canvas canvas,
  required Offset center,
  required double size,
  required double progress,
  required Color colorA,
  required Color colorB,
  required Color pink,
}) {
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.rotate(progress * math.pi * 2);

  final firstPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6
    ..color = colorA.withOpacity(0.42);

  final secondPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.1
    ..color = colorB.withOpacity(0.30);

  canvas.drawOval(
    Rect.fromCenter(
      center: Offset.zero,
      width: size * 0.90,
      height: size * 0.50,
    ),
    firstPaint,
  );

  canvas.rotate(math.pi / 2.8);

  canvas.drawOval(
    Rect.fromCenter(
      center: Offset.zero,
      width: size * 0.84,
      height: size * 0.44,
    ),
    secondPaint,
  );

  canvas.rotate(math.pi / 2.4);

  canvas.drawOval(
    Rect.fromCenter(
      center: Offset.zero,
      width: size * 0.76,
      height: size * 0.38,
    ),
    firstPaint
      ..color = pink.withOpacity(0.20),
  );

  canvas.restore();
}
