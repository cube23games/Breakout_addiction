import 'package:flutter/material.dart';

void drawCosmicOrbCore({
  required Canvas canvas,
  required Offset center,
  required double size,
  required double pulse,
  required Color colorA,
  required Color colorB,
}) {
  final radius = size * 0.34;

  final shadowPaint = Paint()
    ..color = colorA.withOpacity(0.30)
    ..maskFilter = MaskFilter.blur(
      BlurStyle.normal,
      18 + (pulse * 10),
    );

  canvas.drawCircle(
    center,
    radius * 1.10,
    shadowPaint,
  );

  final orbPaint = Paint()
    ..shader = RadialGradient(
      center: const Alignment(-0.30, -0.35),
      radius: 1.08,
      colors: [
        Colors.white.withOpacity(0.95),
        colorA.withOpacity(0.94),
        colorB.withOpacity(0.86),
        const Color(0xFF9A6BFF).withOpacity(0.78),
        const Color(0xFF172944).withOpacity(0.94),
      ],
      stops: const [
        0.0,
        0.14,
        0.42,
        0.70,
        1.0,
      ],
    ).createShader(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
    );

  canvas.drawCircle(
    center,
    radius,
    orbPaint,
  );

  final highlightCenter = center.translate(
    -radius * 0.22,
    -radius * 0.25,
  );

  final highlightPaint = Paint()
    ..shader = RadialGradient(
      colors: [
        Colors.white.withOpacity(0.40),
        Colors.transparent,
      ],
    ).createShader(
      Rect.fromCircle(
        center: highlightCenter,
        radius: radius * 0.48,
      ),
    );

  canvas.drawCircle(
    highlightCenter,
    radius * 0.48,
    highlightPaint,
  );
}
