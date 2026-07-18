class RecoveryProgram {
  final String id;
  final String title;
  final String description;
  final int durationDays;
  final bool faithSensitive;
  final List<String> steps;

  const RecoveryProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.durationDays,
    required this.faithSensitive,
    required this.steps,
  });

  bool get hasDailyStructure => steps.length >= durationDays;
}
