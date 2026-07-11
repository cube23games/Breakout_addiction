import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../data/lock_settings_repository.dart';
import '../domain/lock_scope.dart';
import '../domain/lock_settings.dart';
import 'lock_gate_screen.dart';
import 'lock_session_controller.dart';

class ProtectedRouteGate extends StatefulWidget {
  final LockScope scope;
  final Widget child;
  final bool isRescueRoute;

  const ProtectedRouteGate({
    super.key,
    required this.scope,
    required this.child,
    this.isRescueRoute = false,
  });

  @override
  State<ProtectedRouteGate> createState() =>
      _ProtectedRouteGateState();
}

class _ProtectedRouteGateState extends State<ProtectedRouteGate> {
  final LockSettingsRepository _repository =
      LockSettingsRepository();
  final LockSessionController _session =
      LockSessionController.instance;

  LockSettings? _settings;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _session.addListener(_handleSessionChange);
    _load();
  }

  @override
  void dispose() {
    _session.removeListener(_handleSessionChange);
    super.dispose();
  }

  void _handleSessionChange() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _load() async {
    final settings = await _repository.getSettings();

    if (!mounted) {
      return;
    }

    _session.updateGraceMinutes(
      settings.backgroundGraceMinutes,
    );

    setState(() {
      _settings = settings;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _settings == null) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final settings = _settings!;
    final rescueBypass =
        widget.isRescueRoute && settings.allowRescueWithoutUnlock;
    final shouldLock = settings.shouldLock(widget.scope);

    if (_session.isUnlocked ||
        rescueBypass ||
        !shouldLock ||
        !settings.hasPasscode) {
      return widget.child;
    }

    return LockGateScreen(
      title: 'Protected Content',
      subtitle:
          'Unlock once to use protected areas until the app is left or your relock timer expires.',
      onUnlockAttempt: _repository.verifyPasscode,
      onUnlockSuccess: _session.unlock,
    );
  }
}
