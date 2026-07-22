class RecoveryReportOptions {
  const RecoveryReportOptions({
    this.includeDetailedPlan = false,
    this.includeRiskWindows = false,
  });
  final bool includeDetailedPlan;
  final bool includeRiskWindows;
  RecoveryReportOptions copyWith({
    bool? includeDetailedPlan,
    bool? includeRiskWindows,
  }) => RecoveryReportOptions(
    includeDetailedPlan: includeDetailedPlan ?? this.includeDetailedPlan,
    includeRiskWindows: includeRiskWindows ?? this.includeRiskWindows,
  );
}
