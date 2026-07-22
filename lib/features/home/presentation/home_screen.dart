import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/route_names.dart';
import '../../settings/data/feature_control_settings_repository.dart';
import 'widgets/daily_quote_card.dart';
import 'widgets/home_hero_card.dart';
import 'widgets/home_tier_section.dart';
import 'widgets/my_reasons_home_card.dart';
import 'widgets/quick_actions_row.dart';
import 'widgets/risk_status_card.dart';
import 'widgets/startup_notice_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    this.onStartupNoticeReady,
    super.key,
  });

  final VoidCallback? onStartupNoticeReady;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static bool _startupNoticeHandledThisSession = false;
  final FeatureControlSettingsRepository _settingsRepository =
      FeatureControlSettingsRepository();
  bool _startupNoticeReadySent = false;

  @override
  void initState() {
    super.initState();
    _maybeShowStartupNotice();
  }

  void _notifyStartupNoticeReady() {
    if (_startupNoticeReadySent) {
      return;
    }
    _startupNoticeReadySent = true;
    widget.onStartupNoticeReady?.call();
  }

  Future<void> _maybeShowStartupNotice() async {
    final settings = await _settingsRepository.getSettings();
    if (!mounted) {
      return;
    }

    if (!settings.showStartupNotice || _startupNoticeHandledThisSession) {
      _notifyStartupNoticeReady();
      return;
    }

    _startupNoticeHandledThisSession = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      var currentSettings = settings;
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          return StatefulBuilder(
            builder: (context, setSheetState) {
              return StartupNoticeSheet(
                showOnStartup: currentSettings.showStartupNotice,
                onShowOnStartupChanged: (value) async {
                  currentSettings =
                      currentSettings.copyWith(showStartupNotice: value);
                  await _settingsRepository.saveSettings(currentSettings);
                  setSheetState(() {});
                },
                onContinue: () => Navigator.pop(sheetContext),
                onOpenFeatureChoices: () {
                  Navigator.pop(sheetContext);
                  Navigator.pushNamed(context, RouteNames.featureControls);
                },
                onOpenSupport: () {
                  Navigator.pop(sheetContext);
                  Navigator.pushNamed(context, RouteNames.support);
                },
              );
            },
          );
        },
      );

      // The welcome banner is inserted in the root overlay after the modal
      // route exists, so it remains above the startup sheet and times out
      // independently.
      _notifyStartupNoticeReady();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breakout Addiction'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, RouteNames.support),
            tooltip: 'Open Support',
            icon: const Icon(Icons.support_agent_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const HomeHeroCard(),
            const SizedBox(height: AppSpacing.md),
            const HomeTierSection(),
            const SizedBox(height: AppSpacing.md),
            const MyReasonsHomeCard(),
            const SizedBox(height: AppSpacing.md),
            const DailyQuoteCard(),
            const SizedBox(height: AppSpacing.md),
            const RiskStatusCard(),
            const SizedBox(height: AppSpacing.md),
            const QuickActionsRow(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushReplacementNamed(context, RouteNames.rescue);
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
