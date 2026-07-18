import '../../insights/data/insights_repository.dart';
import '../../risk/data/risk_window_repository.dart';
import '../../support/data/recovery_plan_repository.dart';
import '../domain/premium_preferences.dart';
import 'premium_preferences_repository.dart';
import 'premium_trend_repository.dart';

class PremiumReportRepository {
  final InsightsRepository _insightsRepository;
  final RiskWindowRepository _riskWindowRepository;
  final RecoveryPlanRepository _recoveryPlanRepository;
  final PremiumPreferencesRepository _preferencesRepository;
  final PremiumTrendRepository _trendRepository;

  PremiumReportRepository({
    InsightsRepository? insightsRepository,
    RiskWindowRepository? riskWindowRepository,
    RecoveryPlanRepository? recoveryPlanRepository,
    PremiumPreferencesRepository? preferencesRepository,
    PremiumTrendRepository? trendRepository,
  })  : _insightsRepository =
            insightsRepository ?? InsightsRepository(),
        _riskWindowRepository =
            riskWindowRepository ?? RiskWindowRepository(),
        _recoveryPlanRepository =
            recoveryPlanRepository ?? RecoveryPlanRepository(),
        _preferencesRepository =
            preferencesRepository ?? PremiumPreferencesRepository(),
        _trendRepository =
            trendRepository ?? PremiumTrendRepository();

  Future<String> buildReport() async {
    final insights = await _insightsRepository.buildSummary();
    final windows = await _riskWindowRepository.getRiskWindows();
    final plan = await _recoveryPlanRepository.getPlan();
    final preferences = await _preferencesRepository.getPreferences();
    final trends = await _trendRepository.buildSummary();
    final generated = DateTime.now().toLocal();

    final enabledWindows =
        windows.where((window) => window.isEnabled).toList();
    final riskyPlaces = plan.riskyPlaces.isEmpty
        ? 'Not set'
        : plan.riskyPlaces.join(', ');

    final report = <String>[
      'BREAKOUT ADDICTION RECOVERY REPORT',
      'Generated: ${generated.month}/${generated.day}/${generated.year}',
      '',
      'PRIVATE RECOVERY SUMMARY',
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

    if (preferences.reportDetail == PremiumReportDetail.detailed) {
      report.addAll(<String>[
        '',
        'LOGGED ACTIVITY',
        'Mood check-ins: ${insights.moodLogCount}',
        'Cycle-stage logs: ${insights.stageLogCount}',
        'Urges logged: ${insights.urgeCount}',
        'Victories logged: ${insights.victoryCount}',
        'Slips or relapses logged: ${insights.relapseCount}',
        'Most common mood: ${insights.mostCommonMoodLabel}',
        '',
        'RECOVERY PLAN',
        'Risky places: $riskyPlaces',
        'First action: ${plan.firstAction.isEmpty ? 'Not set' : plan.firstAction}',
        'Backup action: ${plan.secondAction.isEmpty ? 'Not set' : plan.secondAction}',
        'Grounding action: ${plan.groundingAction.isEmpty ? 'Not set' : plan.groundingAction}',
        'Support person: ${plan.supportPerson.isEmpty ? 'Not set' : plan.supportPerson}',
        'Fallback plan: ${plan.fallbackPlan.isEmpty ? 'Not set' : plan.fallbackPlan}',
        '',
        'RISK WINDOWS',
        enabledWindows.isEmpty
            ? 'No enabled risk windows.'
            : '${enabledWindows.length} enabled risk window(s).',
      ]);
    }

    report.addAll(const <String>[
      '',
      'SHARING NOTE',
      'This report contains private recovery information. Review it before copying or sharing.',
    ]);

    return report.join('\n');
  }
}
