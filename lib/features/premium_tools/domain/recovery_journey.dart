class RecoveryJourney {
  final String id;
  final String title;
  final String description;
  final bool faithSensitive;
  final List<String> steps;

  const RecoveryJourney({
    required this.id,
    required this.title,
    required this.description,
    required this.faithSensitive,
    required this.steps,
  });
}
