import 'package:flutter/material.dart';

import '../../../core/constants/route_names.dart';
import '../../home/presentation/home_screen.dart';
import '../../privacy/domain/lock_scope.dart';
import '../../privacy/presentation/protected_route_gate.dart';
import '../../rescue/data/delay_session_repository.dart';
import '../../widget/data/app_entry_repository.dart';
import '../data/onboarding_repository.dart';
import '../data/welcome_banner_repository.dart';
import '../domain/welcome_message.dart';
import 'widgets/welcome_banner_overlay.dart';

class HomeEntryScreen extends StatefulWidget {
  const HomeEntryScreen({super.key});

  @override
  State<HomeEntryScreen> createState() =>
      _HomeEntryScreenState();
}

class _HomeEntryScreenState extends State<HomeEntryScreen> {
  static bool _completedEntryResolvedThisProcess = false;

  final OnboardingRepository _onboardingRepository =
      OnboardingRepository();
  final AppEntryRepository _appEntryRepository =
      AppEntryRepository();
  final DelaySessionRepository _delaySessionRepository =
      DelaySessionRepository();
  final WelcomeBannerRepository _welcomeBannerRepository =
      WelcomeBannerRepository();

  bool _homeReady = false;
  bool _welcomeOverlayScheduled = false;
  WelcomeMessage? _welcomeMessage;
  OverlayEntry? _welcomeOverlayEntry;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final state = await _onboardingRepository.getState();

    if (!mounted) {
      return;
    }

    if (!state.completed) {
      setState(() {
        _homeReady = false;
        _welcomeMessage = null;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        Navigator.pushReplacementNamed(
          context,
          RouteNames.onboarding,
        );
      });
      return;
    }

    final isInitialCompletedEntry =
        !_completedEntryResolvedThisProcess;
    _completedEntryResolvedThisProcess = true;

    final pending =
        await _appEntryRepository.consumePendingEntry();

    if (!mounted) {
      return;
    }

    if (pending != null &&
        pending.routeName != RouteNames.home) {
      setState(() {
        _homeReady = false;
        _welcomeMessage = null;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        Navigator.pushReplacementNamed(
          context,
          pending.routeName,
        );
      });
      return;
    }

    if (isInitialCompletedEntry) {
      final hasDelay = await _delaySessionRepository
          .hasRestorableSession();

      if (!mounted) {
        return;
      }

      if (hasDelay) {
        setState(() {
          _homeReady = false;
          _welcomeMessage = null;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          Navigator.pushReplacementNamed(
            context,
            RouteNames.rescue,
          );
        });
        return;
      }
    }

    final welcomeMessage = isInitialCompletedEntry
        ? await _welcomeBannerRepository.nextMessage()
        : null;

    if (!mounted) {
      return;
    }

    setState(() {
      _homeReady = true;
      _welcomeMessage = welcomeMessage;
    });
  }

  void _showWelcomeOverlay() {
    if (!mounted ||
        _welcomeMessage == null ||
        _welcomeOverlayEntry != null ||
        _welcomeOverlayScheduled) {
      return;
    }

    _welcomeOverlayScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _welcomeOverlayScheduled = false;
      if (!mounted ||
          _welcomeMessage == null ||
          _welcomeOverlayEntry != null) {
        return;
      }

      final message = _welcomeMessage!;
      final overlay = Overlay.of(context, rootOverlay: true);
      late final OverlayEntry entry;
      entry = OverlayEntry(
        builder: (_) => WelcomeBannerOverlay(
          message: message,
          onComplete: () {
            if (_welcomeOverlayEntry != entry) {
              return;
            }
            entry.remove();
            _welcomeOverlayEntry = null;
            if (mounted) {
              setState(() {
                _welcomeMessage = null;
              });
            }
          },
        ),
      );

      _welcomeOverlayEntry = entry;
      overlay.insert(entry);
    });
  }

  @override
  void dispose() {
    _welcomeOverlayEntry?.remove();
    _welcomeOverlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_homeReady) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ProtectedRouteGate(
      scope: LockScope.app,
      child: HomeScreen(
        onStartupNoticeReady: _showWelcomeOverlay,
      ),
    );
  }
}
