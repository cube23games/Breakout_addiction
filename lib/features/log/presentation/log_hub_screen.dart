import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/route_names.dart';
import '../../cycle/domain/cycle_stage.dart';
import '../domain/recovery_event_entry.dart';
import '../domain/recovery_event_save_result.dart';
import 'log_hub_controller.dart';
import 'widgets/log_hub/log_hub_bottom_navigation.dart';
import 'widgets/log_hub/log_hub_intro_card.dart';
import 'widgets/log_hub/log_hub_quick_actions_card.dart';
import 'widgets/log_hub/recent_recovery_events_card.dart';
import 'widgets/log_hub/recent_stage_logs_card.dart';
import 'widgets/log_hub/recovery_event_delete_dialog.dart';

class LogHubScreen extends StatefulWidget {
  const LogHubScreen({super.key});

  @override
  State<LogHubScreen> createState() =>
      _LogHubScreenState();
}

class _LogHubScreenState extends State<LogHubScreen> {
  final LogHubController _controller =
      LogHubController();

  void _refresh() {
    setState(_controller.reload);
  }

  void _openCycleStageLog() {
    Navigator.pushNamed(
      context,
      RouteNames.cycleStageLog,
      arguments: CycleStage.triggers,
    );
  }

  void _openMoodLog() {
    Navigator.pushNamed(
      context,
      RouteNames.moodLog,
    );
  }

  Future<void> _openRecoveryEventLog([
    RecoveryEventEntry? entry,
  ]) async {
    final result = await Navigator.pushNamed(
      context,
      RouteNames.recoveryEventLog,
      arguments: entry,
    );

    if (!mounted ||
        result is! RecoveryEventSaveResult) {
      return;
    }

    _refresh();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF13212C),
        content: Text(result.message),
      ),
    );
  }

  Future<void> _confirmDeleteEvent(
    RecoveryEventEntry entry,
  ) async {
    final confirmed =
        await showRecoveryEventDeleteDialog(
      context,
    );

    if (!confirmed) {
      return;
    }

    await _controller.deleteEvent(entry);

    if (!mounted) {
      return;
    }

    _refresh();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF13212C),
        content: const Text(
          'Recovery event deleted.',
        ),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await _controller.restoreEvent(entry);

            if (mounted) {
              _refresh();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(
          AppSpacing.lg,
        ),
        children: [
          const LogHubIntroCard(),
          const SizedBox(height: AppSpacing.md),
          LogHubQuickActionsCard(
            onLogCycleStage: _openCycleStageLog,
            onLogMood: _openMoodLog,
            onLogRecoveryEvent: () {
              _openRecoveryEventLog();
            },
          ),
          const SizedBox(height: AppSpacing.md),
          RecentStageLogsCard(
            future:
                _controller.stageEntriesFuture,
          ),
          const SizedBox(height: AppSpacing.md),
          RecentRecoveryEventsCard(
            future:
                _controller.eventEntriesFuture,
            onEdit: (entry) {
              _openRecoveryEventLog(entry);
            },
            onDelete: (entry) {
              _confirmDeleteEvent(entry);
            },
          ),
        ],
      ),
      bottomNavigationBar:
          const LogHubBottomNavigation(),
    );
  }
}
