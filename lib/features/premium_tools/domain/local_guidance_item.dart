class LocalGuidanceItem {
  final String title;
  final String detail;
  final String nextAction;
  final bool faithSensitive;

  const LocalGuidanceItem({
    required this.title,
    required this.detail,
    required this.nextAction,
    this.faithSensitive = false,
  });
}
