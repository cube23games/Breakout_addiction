class PrivatePatternSummary {
  final String peakDay;
  final String peakTime;
  final String topTrigger;
  final String triggerPair;
  final String preSlipSignal;
  final String effectiveInterruption;
  final String currentWeekDirection;
  final String weeklySummary;
  final int evidenceCount;

  const PrivatePatternSummary({
    required this.peakDay,
    required this.peakTime,
    required this.topTrigger,
    required this.triggerPair,
    required this.preSlipSignal,
    required this.effectiveInterruption,
    required this.currentWeekDirection,
    required this.weeklySummary,
    required this.evidenceCount,
  });

  bool get hasEnoughEvidence => evidenceCount >= 3;
}
