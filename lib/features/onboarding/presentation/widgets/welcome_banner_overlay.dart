import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../domain/welcome_message.dart';

class WelcomeBannerOverlay extends StatefulWidget {
  const WelcomeBannerOverlay({
    required this.message,
    required this.onComplete,
    super.key,
  });

  final WelcomeMessage message;
  final VoidCallback onComplete;

  @override
  State<WelcomeBannerOverlay> createState() =>
      _WelcomeBannerOverlayState();
}

class _WelcomeBannerOverlayState
    extends State<WelcomeBannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _position;

  Timer? _holdTimer;
  Completer<void>? _holdCompleter;
  bool _started = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _position = Tween<Offset>(
      begin: const Offset(0, -0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_started) {
      return;
    }

    _started = true;
    _run();
  }

  Future<void> _wait(Duration duration) {
    _holdTimer?.cancel();

    final previous = _holdCompleter;
    if (previous != null && !previous.isCompleted) {
      previous.complete();
    }

    final completer = Completer<void>();
    _holdCompleter = completer;
    _holdTimer = Timer(duration, () {
      _holdTimer = null;
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    return completer.future;
  }

  Future<void> _run() async {
    final reduceMotion =
        MediaQuery.of(context).disableAnimations;

    if (reduceMotion) {
      _controller.value = 1;
      await _wait(const Duration(milliseconds: 1500));
    } else {
      await _controller.forward();
      await _wait(const Duration(milliseconds: 1700));
      if (mounted) {
        await _controller.reverse();
      }
    }

    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _holdTimer?.cancel();

    final completer = _holdCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }

    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: FadeTransition(
            opacity: _opacity,
            child: SlideTransition(
              position: _position,
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: 520),
                child: Material(
                  color: colorScheme.surfaceContainerHigh,
                  elevation: 8,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.primary
                            .withOpacity(0.45),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.bolt_outlined,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.message.title,
                                style: AppTypography.section,
                              ),
                              const SizedBox(
                                height: AppSpacing.xs,
                              ),
                              Text(
                                widget.message.subtitle,
                                style: AppTypography.muted,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
