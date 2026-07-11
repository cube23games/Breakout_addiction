import '../../log/domain/mood_entry.dart';

class RiskStatusSummary {
  const RiskStatusSummary({
    required this.label,
    required this.detail,
  });

  final String label;
  final String detail;

  factory RiskStatusSummary.fromEntries(
    List<MoodEntry> entries,
  ) {
    if (entries.isEmpty) {
      return const RiskStatusSummary(
        label: 'Not enough data yet',
        detail:
            'Add a mood check-in so Breakout can estimate '
            'risk from recent patterns.',
      );
    }

    final recent = entries.take(3).toList();

    final averageStress = recent
            .map((entry) => entry.stress)
            .reduce((a, b) => a + b) /
        recent.length;

    final averageLoneliness = recent
            .map((entry) => entry.loneliness)
            .reduce((a, b) => a + b) /
        recent.length;

    final averageBoredom = recent
            .map((entry) => entry.boredom)
            .reduce((a, b) => a + b) /
        recent.length;

    final pressure = averageStress +
        averageLoneliness +
        averageBoredom;

    final label = switch (pressure) {
      >= 21 => 'High Risk',
      >= 16 => 'Elevated',
      >= 10 => 'Guarded',
      _ => 'Low Risk',
    };

    final latest = entries.first;

    return RiskStatusSummary(
      label: label,
      detail:
          'Most recent mood: ${latest.moodLabel}. '
          'Stress ${latest.stress}/10 • '
          'Loneliness ${latest.loneliness}/10 • '
          'Boredom ${latest.boredom}/10.',
    );
  }
}
