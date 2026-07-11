import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'cosmic_orb_backdrop.dart';
import 'cosmic_orb_foreground.dart';

class CosmicOrbPainter extends CustomPainter {
  const CosmicOrbPainter({
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

    final colorA =
        Color.lerp(_cyan, _violet, progress) ?? _cyan;
    final colorB =
        Color.lerp(_blue, _pink, progress) ?? _blue;

    drawCosmicOrbBackdrop(
      canvas: canvas,
      center: center,
      size: shortest,
      progress: progress,
      pulse: pulse,
      colorA: colorA,
      colorB: colorB,
      pink: _pink,
    );

    drawCosmicOrbForeground(
      canvas: canvas,
      center: center,
      size: shortest,
      progress: progress,
      pulse: pulse,
      color: colorA,
      pink: _pink,
      gold: _gold,
    );
  }

  @override
  bool shouldRepaint(CosmicOrbPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.active != active;
  }
}
