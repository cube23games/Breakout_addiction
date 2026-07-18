import 'package:flutter/material.dart';

import '../core/constants/route_names.dart';
import '../core/integrity/app_integrity_banner.dart';
import '../features/privacy/presentation/lock_session_controller.dart';
import 'app_router.dart';
import 'theme/app_theme.dart';

class BreakoutApp extends StatefulWidget {
  const BreakoutApp({super.key});

  @override
  State<BreakoutApp> createState() => _BreakoutAppState();
}

class _BreakoutAppState extends State<BreakoutApp> {
  final LockSessionController _lockSession =
      LockSessionController.instance;

  @override
  void initState() {
    super.initState();
    _lockSession.start();
  }

  @override
  void dispose() {
    _lockSession.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Breakout Addiction',
      debugShowCheckedModeBanner: false,
      theme: buildBreakoutTheme(),
      initialRoute: RouteNames.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
      builder: (context, child) {
        return AppIntegrityBanner(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
