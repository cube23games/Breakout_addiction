class PremiumTrendSummary {
  final int urges30;
  final int victories30;
  final int slips30;
  final int urges90;
  final int victories90;
  final int slips90;
  final int moodLogs30;
  final int stageLogs30;
  final double averagePressure30;
  final String topTrigger30;
  final String directionLine;
  final String nextFocus;

  const PremiumTrendSummary({
    required this.urges30,
    required this.victories30,
    required this.slips30,
    required this.urges90,
    required this.victories90,
    required this.slips90,
    required this.moodLogs30,
    required this.stageLogs30,
    required this.averagePressure30,
    required this.topTrigger30,
    required this.directionLine,
    required this.nextFocus,
  });
}
