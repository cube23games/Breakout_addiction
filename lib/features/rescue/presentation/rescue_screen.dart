import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import 'widgets/breathing_card.dart';
import 'widgets/delay_actions_card.dart';
import 'widgets/reasons_to_stop_card.dart';
import 'widgets/stage_aware_suggestion_card.dart';

class RescueScreen extends StatefulWidget {
  const RescueScreen({super.key});

  @override
  State<RescueScreen> createState() => _RescueScreenState();
}

class _RescueScreenState extends State<RescueScreen> {
  double _urgeIntensity = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rescue')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('Pause. You still have a choice.', style: AppTypography.title),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Interrupt the cycle before it gains momentum.',
              style: AppTypography.muted,
            ),
            const SizedBox(height: AppSpacing.lg),
            InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Urge Intensity', style: AppTypography.section),
                  SizedBox(height: AppSpacing.sm),
                  Slider(
                    value: _urgeIntensity,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: _urgeIntensity.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _urgeIntensity = value;
                      });
                    },
                  ),
                  Text(
                    'Current intensity: ${_urgeIntensity.round()}/10',
                    style: AppTypography.muted,
                  ),
                  Text('Use this as a quick gut-check. If the number is high, change location, breathe, or contact support now.', style: AppTypography.muted),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const DelayActionsCard(),
            const SizedBox(height: AppSpacing.md),
            const BreathingCard(),
            const SizedBox(height: AppSpacing.md),
            const StageAwareSuggestionCard(),
            const SizedBox(height: AppSpacing.md),
            const ReasonsToStopCard(),
            const SizedBox(height: AppSpacing.md),
            InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Support Actions', style: AppTypography.section),
                  const SizedBox(height: AppSpacing.sm),
                  PrimaryButton(
                    label: 'Open Support',
                    icon: Icons.support_agent_outlined,
                    onPressed: () => Navigator.pushNamed(context, RouteNames.support),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, RouteNames.home);
              break;
            case 1:
              break;
            case 2:
              Navigator.pushReplacementNamed(context, RouteNames.logHub);
              break;
            case 3:
              Navigator.pushReplacementNamed(context, RouteNames.insights);
              break;
            case 4:
              Navigator.pushReplacementNamed(context, RouteNames.support);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.flash_on_outlined), label: 'Rescue'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note_outlined), label: 'Log'),
          BottomNavigationBarItem(icon: Icon(Icons.insights_outlined), label: 'Insights'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent_outlined), label: 'Support'),
        ],
      ),
    );
  }
}
