import '../domain/guided_routine.dart';

class GuidedRoutineRepository {
  static const List<GuidedRoutine> routines = <GuidedRoutine>[
    GuidedRoutine(
      id: 'morning_reset',
      title: 'Morning Reset',
      description: 'Start the day before stress and autopilot take over.',
      steps: <String>[
        'Name today’s most likely pressure point.',
        'Read one Reason to Stop.',
        'Choose the first action you will use if an urge appears.',
        'Remove one easy source of risky privacy.',
        'Set one realistic recovery intention for today.',
      ],
    ),
    GuidedRoutine(
      id: 'risk_window_prep',
      title: 'High-Risk Window Prep',
      description: 'Prepare the environment before the vulnerable time begins.',
      steps: <String>[
        'Identify the exact start and end of the risky window.',
        'Move the device or change the setting before the window.',
        'Choose one body-level grounding action.',
        'Choose one person you can contact.',
        'Open Rescue now so the next action is obvious.',
      ],
    ),
    GuidedRoutine(
      id: 'evening_protection',
      title: 'Evening Protection',
      description: 'Reduce fatigue, privacy, and late-night negotiation.',
      steps: <String>[
        'Decide where the phone will charge tonight.',
        'Review the strongest trigger from today.',
        'Choose a screen-off time.',
        'Prepare a low-stimulation replacement activity.',
        'End with one honest win or lesson from today.',
      ],
    ),
    GuidedRoutine(
      id: 'post_slip_rebuild',
      title: 'Post-Slip Rebuild',
      description: 'Move from shame toward useful information and the next safe step.',
      steps: <String>[
        'Stop the episode and change location.',
        'Record what happened without punishment or exaggeration.',
        'Name the earliest warning sign you missed.',
        'Contact someone safe when that is part of your plan.',
        'Change one condition before the next risky window.',
      ],
    ),
  ];
}
