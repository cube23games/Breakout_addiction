import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../notifications/data/breakout_notification_service.dart';
import '../../notifications/data/risk_window_reminder_sync_service.dart';
import '../../support/presentation/widgets/support_bottom_navigation.dart';
import '../data/risk_window_repository.dart';
import '../domain/reminder_settings.dart';
import '../domain/risk_window.dart';
import 'widgets/risk_window_editor_sheet.dart';

class RiskWindowsScreen extends StatefulWidget {
  const RiskWindowsScreen({super.key});

  @override
  State<RiskWindowsScreen> createState() =>
      _RiskWindowsScreenState();
}

class _RiskWindowsScreenState
    extends State<RiskWindowsScreen> {
  final RiskWindowRepository _repository =
      RiskWindowRepository();
  final RiskWindowReminderSyncService _syncService =
      RiskWindowReminderSyncService();

  List<RiskWindow> _windows = <RiskWindow>[];
  ReminderSettings _settings = ReminderSettings.defaults();
  bool _use24HourTime = false;
  bool _loading = true;

  static const List<int> _leadOptions =
      <int>[5, 10, 15, 30, 45, 60];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final windows = await _repository.getRiskWindows();
    final settings =
        await _repository.getReminderSettings();
    final use24HourTime =
        await _repository.getUse24HourTime();

    if (!mounted) {
      return;
    }

    setState(() {
      _windows = windows;
      _settings = settings;
      _use24HourTime = use24HourTime;
      _loading = false;
    });
  }

  Future<void> _requestPermission() async {
    await BreakoutNotificationService.instance
        .requestPermissions();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Notification permission request sent.',
        ),
      ),
    );
  }

  Future<void> _syncReminders() async {
    final result = await _syncService.sync();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.remindersEnabled
              ? 'Live reminders synced: ${result.scheduledCount} scheduled, ${result.cancelledCount} cleared.'
              : 'Reminder prep is off. ${result.cancelledCount} reminders cleared.',
        ),
      ),
    );
  }

  Future<void> _saveSettings(
    ReminderSettings settings,
  ) async {
    await _repository.saveReminderSettings(settings);

    if (!mounted) {
      return;
    }

    setState(() => _settings = settings);
    await _syncReminders();
  }

  Future<void> _saveTimeFormat(bool value) async {
    await _repository.saveUse24HourTime(value);

    if (!mounted) {
      return;
    }

    setState(() => _use24HourTime = value);
  }

  Future<void> _deleteWindow(String id) async {
    await _repository.deleteRiskWindow(id);
    await _load();
    await _syncReminders();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Risk window removed.'),
      ),
    );
  }

  Future<void> _showWindowSheet({
    RiskWindow? existing,
  }) async {
    final window = await showModalBottomSheet<RiskWindow>(
      context: context,
      isScrollControlled: true,
      builder: (_) => RiskWindowEditorSheet(
        existing: existing,
        use24HourFormat: _use24HourTime,
      ),
    );

    if (window == null) {
      return;
    }

    await _repository.upsertRiskWindow(window);
    await _load();
    await _syncReminders();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          existing == null
              ? 'Risk window saved.'
              : 'Risk window updated.',
        ),
      ),
    );
  }

  Widget _windowCard(RiskWindow window) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            window.label,
            style: AppTypography.section,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            window.formattedRange(
              use24HourFormat: _use24HourTime,
            ),
            style: AppTypography.body,
          ),
          if (window.crossesMidnight) ...[
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Ends the next day',
              style: AppTypography.muted,
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(
            window.isEnabled ? 'Enabled' : 'Disabled',
            style: AppTypography.muted,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showWindowSheet(
                    existing: window,
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _deleteWindow(window.id),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Risk Windows')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Risk Windows')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'Get ahead of the risky moments.',
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Define the times when you are more vulnerable so the app can become proactive with real local reminders.',
            style: AppTypography.muted,
          ),
          const SizedBox(height: AppSpacing.lg),
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Reminder Status',
                  style: AppTypography.section,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _settings.remindersEnabled
                      ? 'Reminder prep is on.'
                      : 'Reminder prep is off.',
                  style: AppTypography.body,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Lead time: ${_settings.leadMinutes} minutes before each enabled risk window.',
                  style: AppTypography.muted,
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label:
                      'Request Notification Permission',
                  icon:
                      Icons.notifications_active_outlined,
                  onPressed: _requestPermission,
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _syncReminders,
                    icon: const Icon(Icons.sync_outlined),
                    label: const Text(
                      'Sync Live Reminders',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reminder Settings',
                  style: AppTypography.section,
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _settings.remindersEnabled,
                  onChanged: (value) {
                    _saveSettings(
                      _settings.copyWith(
                        remindersEnabled: value,
                      ),
                    );
                  },
                  title: const Text(
                    'Enable Live Reminders',
                  ),
                  subtitle: const Text(
                    'Schedules local notifications before enabled risk windows.',
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<int>(
                  initialValue: _settings.leadMinutes,
                  decoration: const InputDecoration(
                    labelText: 'Lead Time',
                  ),
                  items: _leadOptions
                      .map(
                        (value) =>
                            DropdownMenuItem<int>(
                          value: value,
                          child: Text(
                            '$value minutes before',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    _saveSettings(
                      _settings.copyWith(
                        leadMinutes: value,
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _use24HourTime,
                  onChanged: _saveTimeFormat,
                  title: const Text(
                    'Use 24-hour time',
                  ),
                  subtitle: const Text(
                    'Off uses a simpler 12-hour clock with AM and PM.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: 'Add Risk Window',
            icon: Icons.add_alert_outlined,
            onPressed: () => _showWindowSheet(),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_windows.isEmpty)
            const InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Risk Windows Yet',
                    style: AppTypography.section,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Add a few recurring high-risk times like late night, after work, or weekends.',
                    style: AppTypography.muted,
                  ),
                ],
              ),
            )
          else
            for (final window in _windows) ...[
              _windowCard(window),
              const SizedBox(height: AppSpacing.md),
            ],
        ],
      ),
      bottomNavigationBar:
          const SupportBottomNavigation(),
    );
  }
}
