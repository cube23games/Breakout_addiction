import 'package:flutter/material.dart';

import '../../../../app/theme/app_typography.dart';
import 'cosmic_orb_painter.dart';

class CosmicBreathingOrb extends StatelessWidget {
  const CosmicBreathingOrb({
    required this.animation,
    required this.running,
    required this.label,
    required this.scaleFor,
    required this.onTap,
    required this.semanticLabel,
    super.key,
  });

  final Animation<double> animation;
  final bool running;
  final String label;
  final double Function(double value) scaleFor;
  final VoidCallback? onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      label: semanticLabel,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final progress = animation.value;
            final scale =
                running ? scaleFor(progress) : 0.78;

            return Transform.scale(
              scale: scale,
              child: SizedBox.square(
                dimension: 196,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size.square(196),
                      painter: CosmicOrbPainter(
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
                          color:
                              Colors.white.withOpacity(0.18),
                        ),
                      ),
                      child: Text(
                        label,
                        style:
                            AppTypography.section.copyWith(
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
        ),
      ),
    );
  }
}
