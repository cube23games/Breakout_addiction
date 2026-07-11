import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_typography.dart';

class CosmicBreathingOrb extends StatelessWidget {
  const CosmicBreathingOrb({
    required this.animation,
    required this.running,
    required this.label,
    required this.scaleFor,
    super.key,
  });

  final Animation<double> animation;
  final bool running;
  final String label;
  final double Function(double value) scaleFor;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = animation.value;
        final scale = running ? scaleFor(progress) : 0.78;

        return Transform.scale(
          scale: scale,
          child: SizedBox.square(
            dimension: 196,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size.square(196),
                  painter: _CosmicOrbPainter(
                    progress: progress,
                    active: running,
                  ),
                ),
                Container(
                  width: 102,
                  height: 102,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.18),
                    ),
                  ),
                  child: Text(
                    label,
                    style: AppTypography.section.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      shadows: const [
                        Shadow(
                          blurRadius: 12,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CosmicOrbPainter extends CustomPainter {
  const _CosmicOrbPainter({
    required this.progress,
    required this.active,
  });

  final double progress;
  final bool active;

  static const Color _cyan = Color(0xFF45F3E5);
  static const Color _blue = Color(0xFF4E8DFF);
  static const Color _violet = Color(0xFF9A6BFF);
  static const Color _pink = Color(0xFFFF71C6);
  static const Color _gold = Color(0xFFFFE69A);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final shortest = math.min(size.width, size.height);
    final pulse = active
        ? (math.sin(progress * math.pi * 2) + 1) / 2
        : 0.35;

    final colorA = Color.lerp(_cyan, _violet, progress) ?? _cyan;
    final colorB = Color.lerp(_blue, _pink, progress) ?? _blue;

    _drawAura(
      canvas,
      center,
      shortest,
      colorA,
      colorB,
      pulse,
    );

    _drawOrbitLines(
      canvas,
      center,
      shortest,
      colorA,
      colorB,
    );

    _drawOrb(
      canvas,
      center,
      shortest,
      colorA,
      colorB,
      pulse,
    );

    _drawOrbitingLights(
      canvas,
      center,
      shortest,
      colorA,
    );

    _drawCenterStar(
      canvas,
      center,
      shortest,
      pulse,
    );
  }

  void _drawAura(
    Canvas canvas,
    Offset center,
    double size,
    Color colorA,
    Color colorB,
    double pulse,
  ) {
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          colorA.withOpacity(0.24 + (pulse * 0.10)),
          colorB.withOpacity(0.12),
          Colors.transparent,
        ],
        stops: const [0.05, 0.54, 1.0],
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

  void _drawOrbitLines(
    Canvas canvas,
    Offset center,
    double size,
    Color colorA,
    Color colorB,
  ) {
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
      firstPaint..color = _pink.withOpacity(0.20),
    );

    canvas.restore();
  }

  void _drawOrb(
    Canvas canvas,
    Offset center,
    double size,
    Color colorA,
    Color colorB,
    double pulse,
  ) {
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
          _violet.withOpacity(0.78),
          const Color(0xFF172944).withOpacity(0.94),
        ],
        stops: const [0.0, 0.14, 0.42, 0.70, 1.0],
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

    final highlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.40),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: center.translate(-radius * 0.22, -radius * 0.25),
          radius: radius * 0.48,
        ),
      );

    canvas.drawCircle(
      center.translate(-radius * 0.22, -radius * 0.25),
      radius * 0.48,
      highlightPaint,
    );
  }

  void _drawOrbitingLights(
    Canvas canvas,
    Offset center,
    double size,
    Color color,
  ) {
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
    canvas.drawCircle(second, 3.5, glowPaint..color = _pink.withOpacity(0.75));

    canvas.drawCircle(
      first,
      2.2,
      Paint()..color = Colors.white,
    );

    canvas.drawCircle(
      second,
      1.7,
      Paint()..color = _gold,
    );
  }

  void _drawCenterStar(
    Canvas canvas,
    Offset center,
    double size,
    double pulse,
  ) {
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
      ..lineTo(center.dx + radius * 0.24, center.dy - radius * 0.24)
      ..lineTo(center.dx + radius, center.dy)
      ..lineTo(center.dx + radius * 0.24, center.dy + radius * 0.24)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - radius * 0.24, center.dy + radius * 0.24)
      ..lineTo(center.dx - radius, center.dy)
      ..lineTo(center.dx - radius * 0.24, center.dy - radius * 0.24)
      ..close();

    canvas.drawPath(path, starPaint);
  }

  @override
  bool shouldRepaint(_CosmicOrbPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.active != active;
  }
}
