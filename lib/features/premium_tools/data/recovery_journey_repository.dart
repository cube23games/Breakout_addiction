import '../domain/recovery_journey.dart';

class RecoveryJourneyRepository {
  static const List<RecoveryJourney> journeys = <RecoveryJourney>[
    RecoveryJourney(
      id: 'seven_day_rebuild',
      title: 'Seven-Day Rebuild',
      description: 'A practical secular journey for restoring early interruption.',
      faithSensitive: false,
      steps: <String>[
        'Day 1 — Map the cycle without judging yourself.',
        'Day 2 — Identify your earliest reliable warning sign.',
        'Day 3 — Reduce privacy around one risky setting.',
        'Day 4 — Strengthen your first and backup actions.',
        'Day 5 — Practice one urge interruption before you need it.',
        'Day 6 — Review victories, slips, and repeated pressure drivers.',
        'Day 7 — Write the next-week focus in one sentence.',
      ],
    ),
    RecoveryJourney(
      id: 'five_day_honesty',
      title: 'Five Days of Honest Recovery',
      description: 'Build awareness, responsibility, and a clearer next step.',
      faithSensitive: false,
      steps: <String>[
        'Day 1 — Tell the truth about the pattern.',
        'Day 2 — Separate the urge from the action.',
        'Day 3 — Name what relief you are actually seeking.',
        'Day 4 — Practice a human-support step.',
        'Day 5 — Choose the next right commitment.',
      ],
    ),
    RecoveryJourney(
      id: 'christian_renewal',
      title: 'Christian Renewal Journey',
      description: 'Optional faith-sensitive recovery focused on grace, honesty, and action.',
      faithSensitive: true,
      steps: <String>[
        'Day 1 — Bring the struggle into honest prayer without hiding.',
        'Day 2 — Reflect on grace without using grace to avoid responsibility.',
        'Day 3 — Replace isolation with wise human support.',
        'Day 4 — Prepare one practical boundary before temptation.',
        'Day 5 — Practice renewing attention toward what is life-giving.',
        'Day 6 — Respond to a setback with confession, learning, and action.',
        'Day 7 — Choose one faithful next step for the coming week.',
      ],
    ),
  ];
}
