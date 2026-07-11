import 'package:flutter/material.dart';

import '../../../../core/constants/route_names.dart';

class SupportBottomNavigation extends StatelessWidget {
  const SupportBottomNavigation({super.key});

  void _openDestination(BuildContext context, int index) {
    final route = switch (index) {
      0 => RouteNames.home,
      1 => RouteNames.rescue,
      2 => RouteNames.logHub,
      3 => RouteNames.insights,
      _ => null,
    };

    if (route == null) {
      return;
    }

    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 4,
      onTap: (index) => _openDestination(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.flash_on_outlined),
          label: 'Rescue',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.edit_note_outlined),
          label: 'Log',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.insights_outlined),
          label: 'Insights',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.support_agent_outlined),
          label: 'Support',
        ),
      ],
    );
  }
}
