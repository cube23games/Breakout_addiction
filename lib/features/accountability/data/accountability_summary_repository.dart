import '../../insights/data/insights_repository.dart';
import '../../log/data/mood_log_repository.dart';
import '../../log/data/recovery_event_repository.dart';
import '../../log/domain/recovery_event_entry.dart';
import '../../rescue/data/reasons_to_stop_repository.dart';
import '../../risk/data/risk_window_repository.dart';
import '../../support/data/recovery_plan_repository.dart';
import '../domain/accountability_scope.dart';
import '../domain/accountability_settings.dart';
import '../domain/accountability_summary_item.dart';

class AccountabilitySummaryRepository {
  final InsightsRepository _insightsRepository =
      InsightsRepository();
  final RecoveryEventRepository _eventRepository =
      RecoveryEventRepository();
  final MoodLogRepository _moodRepository =
      MoodLogRepository();
  final RiskWindowRepository _riskRepository =
      RiskWindowRepository();
  final RecoveryPlanRepository _planRepository =
      RecoveryPlanRepository();
  final ReasonsToStopRepository _reasonsRepository =
      ReasonsToStopRepository();

  Future<List<AccountabilitySummaryItem>> buildItems(
    AccountabilitySettings settings,
  ) async {
    final scopes = settings.sharedScopes.toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    final items = <AccountabilitySummaryItem>[];
    for (final scope in scopes) {
      try {
        items.add(
          await _buildItem(
            scope,
            sharePrivateNotes: settings.sharePrivateNotes,
          ),
        );
      } catch (_) {
        items.add(AccountabilitySummaryItem.unavailable(scope));
      }
    }
    return items;
  }

  Future<AccountabilitySummaryItem> _buildItem(
    AccountabilityScope scope, {
    required bool sharePrivateNotes,
  }) async {
    switch (scope) {
      case AccountabilityScope.progress:
        return _progress();
      case AccountabilityScope.recentUrges:
        return _events(
          scope,
          RecoveryEventType.urge,
          'No urge events have been recorded yet.',
          sharePrivateNotes,
        );
      case AccountabilityScope.relapseEvents:
        return _events(
          scope,
          RecoveryEventType.relapse,
          'No relapse events have been recorded yet.',
          sharePrivateNotes,
        );
      case AccountabilityScope.victoryEvents:
        return _events(
          scope,
          RecoveryEventType.victory,
          'No victory events have been recorded yet.',
          sharePrivateNotes,
        );
      case AccountabilityScope.moodTrends:
        return _moodTrends();
      case AccountabilityScope.riskWindows:
        return _riskWindows();
      case AccountabilityScope.recoveryPlan:
        return _recoveryPlan();
      case AccountabilityScope.reasonsToStop:
        return _reasonsToStop();
      case AccountabilityScope.supportNeeded:
        return _supportNeeded();
    }
  }

  Future<AccountabilitySummaryItem> _progress() async {
    final summary = await _insightsRepository.buildSummary();
    final activityCount = summary.moodLogCount +
        summary.stageLogCount +
        summary.urgeCount +
        summary.relapseCount +
        summary.victoryCount;

    if (activityCount == 0) {
      return AccountabilitySummaryItem.empty(
        AccountabilityScope.progress,
        'No recovery activity has been recorded yet.',
      );
    }

    return AccountabilitySummaryItem(
      scope: AccountabilityScope.progress,
      status: AccountabilityDataStatus.available,
      summary: '$activityCount recovery records are available.',
      details: <String>[
        '${summary.urgeCount} urges • ${summary.victoryCount} victories '
            '• ${summary.relapseCount} relapses',
        '${summary.moodLogCount} mood check-ins • '
            '${summary.stageLogCount} cycle-stage logs',
        'Recent risk level: ${summary.recentRiskLabel}',
      ],
    );
  }

  Future<AccountabilitySummaryItem> _events(
    AccountabilityScope scope,
    RecoveryEventType type,
    String emptyMessage,
    bool sharePrivateNotes,
  ) async {
    final all = await _eventRepository.getEntries();
    final entries = all
        .where((entry) => entry.type == type)
        .toList();

    if (entries.isEmpty) {
      return AccountabilitySummaryItem.empty(
        scope,
        emptyMessage,
      );
    }

    final recent = entries.take(3).map(
      (entry) => _eventLine(
        entry,
        sharePrivateNotes: sharePrivateNotes,
      ),
    );

    return AccountabilitySummaryItem(
      scope: scope,
      status: AccountabilityDataStatus.available,
      summary:
          '${entries.length} ${type.label.toLowerCase()} '
          '${entries.length == 1 ? 'event' : 'events'} recorded.',
      details: recent.toList(),
    );
  }

  Future<AccountabilitySummaryItem> _moodTrends() async {
    final moods = await _moodRepository.getEntries();
    if (moods.isEmpty) {
      return AccountabilitySummaryItem.empty(
        AccountabilityScope.moodTrends,
        'No mood check-ins have been recorded yet.',
      );
    }

    final recent = moods.take(7).toList();
    final averageStress = recent
            .map((entry) => entry.stress)
            .reduce((a, b) => a + b) /
        recent.length;
    final counts = <String, int>{};
    for (final entry in moods) {
      counts.update(
        entry.moodLabel,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    final common = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return AccountabilitySummaryItem(
      scope: AccountabilityScope.moodTrends,
      status: AccountabilityDataStatus.available,
      summary: '${moods.length} mood check-ins recorded.',
      details: <String>[
        'Most common mood: ${common.first.key}',
        'Average recent stress: '
            '${averageStress.toStringAsFixed(1)}/10',
        'Latest check-in: ${_shortDate(moods.first.timestamp)}',
      ],
    );
  }

  Future<AccountabilitySummaryItem> _riskWindows() async {
    final windows = await _riskRepository.getRiskWindows();
    if (windows.isEmpty) {
      return AccountabilitySummaryItem.empty(
        AccountabilityScope.riskWindows,
        'No risk windows have been set up yet.',
      );
    }

    final use24Hour =
        await _riskRepository.getUse24HourTime();
    final enabled =
        windows.where((window) => window.isEnabled).length;

    return AccountabilitySummaryItem(
      scope: AccountabilityScope.riskWindows,
      status: AccountabilityDataStatus.available,
      summary:
          '$enabled of ${windows.length} risk windows are enabled.',
      details: windows.take(4).map((window) {
        final overnight =
            window.crossesMidnight ? ' • ends next day' : '';
        final state = window.isEnabled ? '' : ' • disabled';
        return '${window.label}: '
            '${window.formattedRange(use24HourFormat: use24Hour)}'
            '$overnight$state';
      }).toList(),
    );
  }

  Future<AccountabilitySummaryItem> _recoveryPlan() async {
    final plan = await _planRepository.getPlan();
    final details = <String>[
      if (plan.riskyPlaces.isNotEmpty)
        'Risky places: ${plan.riskyPlaces.join(', ')}',
      if (plan.firstAction.trim().isNotEmpty)
        'First action: ${plan.firstAction.trim()}',
      if (plan.secondAction.trim().isNotEmpty)
        'Second action: ${plan.secondAction.trim()}',
      if (plan.groundingAction.trim().isNotEmpty)
        'Grounding action: ${plan.groundingAction.trim()}',
      if (plan.supportPerson.trim().isNotEmpty)
        'Support person: ${plan.supportPerson.trim()}',
      if (plan.fallbackPlan.trim().isNotEmpty)
        'Fallback plan: ${plan.fallbackPlan.trim()}',
      if (plan.warningSigns.isNotEmpty)
        'Warning signs: ${plan.warningSigns.join(', ')}',
      if (plan.triggers.isNotEmpty)
        'Triggers: ${plan.triggers.join(', ')}',
      if (plan.highRiskTimes.isNotEmpty)
        'High-risk times: ${plan.highRiskTimes.join(', ')}',
      if (plan.morningCommitment.trim().isNotEmpty)
        'Morning commitment: ${plan.morningCommitment.trim()}',
      if (plan.eveningCommitment.trim().isNotEmpty)
        'Evening commitment: ${plan.eveningCommitment.trim()}',
      if (plan.postSlipPlan.trim().isNotEmpty)
        'Post-slip rebuild: ${plan.postSlipPlan.trim()}',
      'Plan readiness: ${plan.completedSections}/${plan.totalSections}',
    ];

    if (details.isEmpty) {
      return AccountabilitySummaryItem.empty(
        AccountabilityScope.recoveryPlan,
        'A recovery plan has not been completed yet.',
      );
    }

    return AccountabilitySummaryItem(
      scope: AccountabilityScope.recoveryPlan,
      status: AccountabilityDataStatus.available,
      summary: 'A recovery plan is available.',
      details: details,
    );
  }

  Future<AccountabilitySummaryItem> _reasonsToStop() async {
    final reasons = (await _reasonsRepository.getReasons())
        .where(
          (reason) =>
              reason.trim().isNotEmpty &&
              reason != ReasonsToStopRepository.otherReason,
        )
        .toList();

    if (reasons.isEmpty) {
      return AccountabilitySummaryItem.empty(
        AccountabilityScope.reasonsToStop,
        'No reasons to stop have been recorded yet.',
      );
    }

    return AccountabilitySummaryItem(
      scope: AccountabilityScope.reasonsToStop,
      status: AccountabilityDataStatus.available,
      summary: '${reasons.length} reasons are available.',
      details: reasons.take(6).toList(),
    );
  }

  Future<AccountabilitySummaryItem> _supportNeeded() async {
    final events = await _eventRepository.getEntries();
    final moods = await _moodRepository.getEntries();
    final cutoff =
        DateTime.now().subtract(const Duration(days: 7));
    final recent = events
        .where((entry) => entry.timestamp.isAfter(cutoff))
        .toList();

    if (recent.isEmpty && moods.isEmpty) {
      return AccountabilitySummaryItem.empty(
        AccountabilityScope.supportNeeded,
        'Not enough recent data is available to show a '
        'support-needed signal.',
      );
    }

    final highUrges = recent
        .where(
          (entry) =>
              entry.type == RecoveryEventType.urge &&
              entry.intensity >= 7,
        )
        .length;
    final relapses = recent
        .where(
          (entry) =>
              entry.type == RecoveryEventType.relapse,
        )
        .length;
    final latestStress =
        moods.isEmpty ? 0 : moods.first.stress;
    final supportMayHelp =
        highUrges > 0 || relapses > 0 || latestStress >= 8;

    return AccountabilitySummaryItem(
      scope: AccountabilityScope.supportNeeded,
      status: AccountabilityDataStatus.available,
      summary: supportMayHelp
          ? 'Recent shared logs suggest extra support may be '
              'useful right now.'
          : 'Recent shared logs do not show a strong '
              'support-needed signal.',
      details: <String>[
        '$highUrges high-intensity urges in the last 7 days',
        '$relapses relapse events in the last 7 days',
        'This is a simple local signal, not a clinical assessment.',
      ],
    );
  }

  String _eventLine(
    RecoveryEventEntry entry, {
    required bool sharePrivateNotes,
  }) {
    final parts = <String>[
      _shortDate(entry.timestamp),
      'Intensity ${entry.intensity}/10',
      entry.displayTrigger,
    ];

    if (sharePrivateNotes && entry.note.trim().isNotEmpty) {
      parts.add('Shared note: ${_trim(entry.note)}');
    }

    return parts.join(' • ');
  }

  String _trim(String value) {
    final cleaned = value.trim();
    if (cleaned.length <= 80) {
      return cleaned;
    }
    return '${cleaned.substring(0, 77)}...';
  }

  String _shortDate(DateTime value) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final local = value.toLocal();
    return '${months[local.month - 1]} ${local.day}, ${local.year}';
  }
}
