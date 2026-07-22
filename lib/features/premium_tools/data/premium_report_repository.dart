import '../../insights/data/insights_repository.dart';
import '../../risk/data/risk_window_repository.dart';
import '../../support/data/recovery_plan_repository.dart';
import '../domain/recovery_report_options.dart';
import 'premium_trend_repository.dart';

class PremiumReportRepository {
  PremiumReportRepository({
    InsightsRepository? insightsRepository,
    RiskWindowRepository? riskWindowRepository,
    RecoveryPlanRepository? recoveryPlanRepository,
    PremiumTrendRepository? trendRepository,
  })  : _insightsRepository = insightsRepository ?? InsightsRepository(),
        _riskWindowRepository = riskWindowRepository ?? RiskWindowRepository(),
        _recoveryPlanRepository = recoveryPlanRepository ?? RecoveryPlanRepository(),
        _trendRepository = trendRepository ?? PremiumTrendRepository();

  final InsightsRepository _insightsRepository;
  final RiskWindowRepository _riskWindowRepository;
  final RecoveryPlanRepository _recoveryPlanRepository;
  final PremiumTrendRepository _trendRepository;

  Future<String> buildReport({
    RecoveryReportOptions options = const RecoveryReportOptions(),
  }) async {
    final insights = await _insightsRepository.buildSummary();
    final windows = await _riskWindowRepository.getRiskWindows();
    final plan = await _recoveryPlanRepository.getPlan();
    final trends = await _trendRepository.buildSummary();
    final generated = DateTime.now().toLocal();
    final report = <String>[
      'BREAKOUT ADDICTION RECOVERY REPORT',
      'Generated: ${generated.month}/${generated.day}/${generated.year}',
      '',
      'RECOVERY SUMMARY',
      insights.summaryLine,
      '',
      'RECENT PATTERN',
      'Risk level: ${insights.recentRiskLabel}',
      'Strongest pressure driver: ${insights.strongestPressureDriver}',
      'Most logged cycle stage: ${insights.topStageTitle}',
      '',
      '30-DAY SNAPSHOT',
      'Urges: ${trends.urges30}',
      'Victories: ${trends.victories30}',
      'Slips or relapses: ${trends.slips30}',
      'Most repeated trigger/context: ${trends.topTrigger30}',
      trends.directionLine,
      '',
      '90-DAY SNAPSHOT',
      'Urges: ${trends.urges90}',
      'Victories: ${trends.victories90}',
      'Slips or relapses: ${trends.slips90}',
      '',
      'NEXT FOCUS',
      trends.nextFocus,
      insights.recommendationLine,
      insights.nextBestAction,
    ];
    if (options.includeDetailedPlan) {
      report.addAll(<String>[
        '', 'SELECTED RECOVERY PLAN DETAILS',
        'Risky places: ${plan.riskyPlaces.isEmpty ? 'Not set' : plan.riskyPlaces.join(', ')}',
        'First action: ${plan.firstAction.isEmpty ? 'Not set' : plan.firstAction}',
        'Backup action: ${plan.secondAction.isEmpty ? 'Not set' : plan.secondAction}',
        'Grounding action: ${plan.groundingAction.isEmpty ? 'Not set' : plan.groundingAction}',
        'Warning signs: ${plan.warningSigns.isEmpty ? 'Not set' : plan.warningSigns.join(', ')}',
        'Primary triggers: ${plan.triggers.isEmpty ? 'Not set' : plan.triggers.join(', ')}',
        'High-risk times: ${plan.highRiskTimes.isEmpty ? 'Not set' : plan.highRiskTimes.join(', ')}',
        'Morning commitment: ${plan.morningCommitment.isEmpty ? 'Not set' : plan.morningCommitment}',
        'Evening commitment: ${plan.eveningCommitment.isEmpty ? 'Not set' : plan.eveningCommitment}',
        'Post-slip rebuild: ${plan.postSlipPlan.isEmpty ? 'Not set' : plan.postSlipPlan}',
        'Plan readiness: ${(plan.completion * 100).round()}%',
      ]);
    }
    if (options.includeRiskWindows) {
      final enabled = windows.where((item) => item.isEnabled).toList();
      report.addAll(<String>[
        '', 'SELECTED RISK WINDOWS',
        if (enabled.isEmpty) 'No enabled risk windows.',
        for (final window in enabled) '${window.label}: ${window.timeRange}',
      ]);
    }
    report.addAll(const <String>[
      '', 'PRIVACY REVIEW',
      'Private notes, faith content, media, and contact details are not included automatically.',
      'Review every line before sharing.',
    ]);
    return report.join('\n');
  }
}
