class DailyRecoveryDashboard {
  final int riskScore;
  final String riskLabel;
  final String riskReason;
  final String topTrigger;
  final String nextRiskWindow;
  final String recommendedRoutineId;
  final String recommendedRoutineTitle;
  final String firstAction;
  final int weeklyVictories;
  final int weeklyUrges;
  final int weeklySlips;
  final int weeklyCheckIns;
  final String weeklyLine;
  final String todayFocus;

  const DailyRecoveryDashboard({
    required this.riskScore,
    required this.riskLabel,
    required this.riskReason,
    required this.topTrigger,
    required this.nextRiskWindow,
    required this.recommendedRoutineId,
    required this.recommendedRoutineTitle,
    required this.firstAction,
    required this.weeklyVictories,
    required this.weeklyUrges,
    required this.weeklySlips,
    required this.weeklyCheckIns,
    required this.weeklyLine,
    required this.todayFocus,
  });

  bool get hasRecentActivity =>
      weeklyVictories + weeklyUrges + weeklySlips + weeklyCheckIns > 0;
}
