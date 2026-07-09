import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../cycle/domain/cycle_stage.dart';
import '../data/cycle_stage_log_repository.dart';
import '../data/recovery_event_repository.dart';
import '../domain/cycle_stage_log_entry.dart';
import '../domain/recovery_event_entry.dart';

class LogHubScreen extends StatefulWidget {
  const LogHubScreen({super.key});

  @override
  State<LogHubScreen> createState() => _LogHubScreenState();
}

class _LogHubScreenState extends State<LogHubScreen> {
  final CycleStageLogRepository _stageRepository = CycleStageLogRepository();
  final RecoveryEventRepository _eventRepository = RecoveryEventRepository();

  late Future<List<CycleStageLogEntry>> _stageEntriesFuture;
  late Future<List<RecoveryEventEntry>> _eventEntriesFuture;

  @override
  void initState() {
    super.initState();
    _reloadEntries();
  }

  void _reloadEntries() {
    _stageEntriesFuture = _stageRepository.getEntries();
    _eventEntriesFuture = _eventRepository.getEntries();
  }

  void _refresh() {
    setState(_reloadEntries);
  }

  Future<void> _confirmDeleteEvent(RecoveryEventEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete recovery event?'),
          content: const Text(
            'This removes the saved log from this device. You can undo immediately after deleting.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _eventRepository.deleteEntry(entry);
    if (!mounted) return;

    _refresh();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF13212C),
        content: const Text('Recovery event deleted.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await _eventRepository.saveEntry(entry);
            if (mounted) {
              _refresh();
            }
          },
        ),
      ),
    );
  }

  void _editEvent(RecoveryEventEntry entry) {
    Navigator.pushNamed(
      context,
      RouteNames.recoveryEventLog,
      arguments: entry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Private Logs', style: AppTypography.section),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Use different log types to understand mood, cycle stage, urges, slips, and wins more clearly.',
                  style: AppTypography.muted,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick Log Actions', style: AppTypography.section),
                const SizedBox(height: AppSpacing.sm),
                PrimaryButton(
                  label: 'Log Cycle Stage',
                  icon: Icons.add_chart_outlined,
                  onPressed: () => Navigator.pushNamed(
                    context,
                    RouteNames.cycleStageLog,
                    arguments: CycleStage.triggers,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      RouteNames.moodLog,
                    ),
                    icon: const Icon(Icons.mood_outlined),
                    label: const Text('Log Mood'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      RouteNames.recoveryEventLog,
                    ),
                    icon: const Icon(Icons.flag_outlined),
                    label: const Text('Log Urge / Relapse / Victory'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FutureBuilder<List<CycleStageLogEntry>>(
            future: _stageEntriesFuture,
            builder: (context, snapshot) {
              final entries = snapshot.data ?? <CycleStageLogEntry>[];

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const InfoCard(
                  child: Text(
                    'Loading recent stage logs...',
                    style: AppTypography.muted,
                  ),
                );
              }

              if (entries.isEmpty) {
                return const InfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recent Stage Logs', style: AppTypography.section),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        'No saved stage logs yet.',
                        style: AppTypography.muted,
                      ),
                    ],
                  ),
                );
              }

              return InfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent Stage Logs', style: AppTypography.section),
                    const SizedBox(height: AppSpacing.sm),
                    for (final entry in entries.take(4)) ...[
                      _StageRow(entry: entry),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          FutureBuilder<List<RecoveryEventEntry>>(
            future: _eventEntriesFuture,
            builder: (context, snapshot) {
              final entries = snapshot.data ?? <RecoveryEventEntry>[];

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const InfoCard(
                  child: Text(
                    'Loading recent recovery events...',
                    style: AppTypography.muted,
                  ),
                );
              }

              if (entries.isEmpty) {
                return const InfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recent Recovery Events', style: AppTypography.section),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        'No urge, relapse, or victory logs yet.',
                        style: AppTypography.muted,
                      ),
                    ],
                  ),
                );
              }

              return InfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent Recovery Events', style: AppTypography.section),
                    const SizedBox(height: AppSpacing.sm),
                    for (final entry in entries.take(5)) ...[
                      _RecoveryEventRow(
                        entry: entry,
                        onEdit: () => _editEvent(entry),
                        onDelete: () => _confirmDeleteEvent(entry),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, RouteNames.home);
              break;
            case 1:
              Navigator.pushReplacementNamed(context, RouteNames.rescue);
              break;
            case 2:
              break;
            case 3:
              Navigator.pushReplacementNamed(context, RouteNames.educate);
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
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Learn'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent_outlined), label: 'Support'),
        ],
      ),
    );
  }
}

class _StageRow extends StatelessWidget {
  final CycleStageLogEntry entry;

  const _StageRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final note = entry.note.isEmpty ? 'No note added.' : entry.note;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF263041)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.stage.title, style: AppTypography.section),
          const SizedBox(height: 4),
          Text('Intensity: ${entry.intensity}/10', style: AppTypography.muted),
          const SizedBox(height: 4),
          Text(note, style: AppTypography.body),
        ],
      ),
    );
  }
}

class _RecoveryEventRow extends StatelessWidget {
  final RecoveryEventEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RecoveryEventRow({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final contextText = entry.context.isEmpty ? 'No context added.' : entry.context;
    final noteText = entry.note.isEmpty ? 'No note added.' : entry.note;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF263041)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.type.label, style: AppTypography.section),
          const SizedBox(height: 4),
          Text('Reason: ${entry.displayReason}', style: AppTypography.muted),
          const SizedBox(height: 4),
          Text('Intensity: ${entry.intensity}/10', style: AppTypography.muted),
          const SizedBox(height: AppSpacing.sm),
          Text(contextText, style: AppTypography.body),
          const SizedBox(height: 4),
          Text(noteText, style: AppTypography.muted),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
              OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
