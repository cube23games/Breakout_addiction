import '../domain/lesson.dart';
import '../domain/lesson_track.dart';

class LessonRepository {
  static const List<LessonTrack> _tracks = <LessonTrack>[
    LessonTrack(
      id: 'why_this_happens',
      title: 'Why This Happens',
      subtitle: 'Understand why urges can feel stronger than your intentions.',
      lessons: <Lesson>[
        Lesson(
          id: 'urge_is_a_wave',
          title: 'An urge is a wave, not a command',
          summary:
              'Urges often arrive with a false sense of urgency. They rise, peak, and fall.',
          bullets: <String>[
            'The body can confuse intensity with necessity.',
            'An urge can feel urgent without being important.',
            'Delay and interruption often reduce power fast.',
          ],
          closingLine:
              'The goal is not to panic at the wave. It is to outlast it.',
        ),
        Lesson(
          id: 'stress_and_escape',
          title: 'Stress often drives escape, not desire',
          summary:
              'Many acting-out moments are driven less by attraction and more by pressure, fatigue, or overwhelm.',
          bullets: <String>[
            'Stress reduces your willingness to tolerate discomfort.',
            'Escaping quickly can feel more attractive than coping well.',
            'The brain starts linking relief with a specific ritual.',
          ],
          closingLine:
              'When you name stress honestly, the cycle becomes easier to interrupt.',
        ),
      ],
    ),
    LessonTrack(
      id: 'what_am_i_chasing',
      title: 'What Am I Actually Chasing?',
      subtitle: 'Look beneath the habit and identify the payoff you are seeking.',
      lessons: <Lesson>[
        Lesson(
          id: 'relief_not_just_pleasure',
          title: 'Sometimes you are chasing relief, not pleasure',
          summary:
              'What looks like desire can actually be a search for relief, numbing, distraction, or comfort.',
          bullets: <String>[
            'Relief can masquerade as excitement.',
            'The ritual may promise calm more than pleasure.',
            'If the goal is relief, better relief tools can weaken the loop.',
          ],
          closingLine:
              'Ask what problem you are trying to solve in the moment.',
        ),
        Lesson(
          id: 'novelty_and_control',
          title: 'Novelty can feel like control',
          summary:
              'A flood of stimulation can create the illusion of control, power, or certainty for a short time.',
          bullets: <String>[
            'Novelty grabs attention fast and overwhelms reflection.',
            'More stimulation can become necessary to get the same effect.',
            'That pattern can leave you feeling flatter afterward.',
          ],
          closingLine:
              'The more clearly you see the payoff, the less mystical the habit becomes.',
        ),
      ],
    ),
    LessonTrack(
      id: 'recovery_and_rewiring',
      title: 'Recovery and Rewiring',
      subtitle: 'Learn how repetition, honesty, and interruption change the cycle.',
      lessons: <Lesson>[
        Lesson(
          id: 'earlier_interruptions',
          title: 'Earlier interruptions matter most',
          summary:
              'The fastest wins usually happen before the cycle reaches full speed.',
          bullets: <String>[
            'Catching boredom or loneliness early is easier than stopping at peak urge.',
            'Logs create awareness. Awareness creates earlier action.',
            'Small interruptions repeated often reshape the pattern.',
          ],
          closingLine:
              'You do not need perfect days. You need earlier catches.',
        ),
        Lesson(
          id: 'shame_vs_honesty',
          title: 'Shame hides patterns. Honesty reveals them.',
          summary:
              'Shame makes the habit feel darker and more personal. Honest tracking makes it more visible and workable.',
          bullets: <String>[
            'Shame says “this is who I am.”',
            'Honesty says “this is a pattern I can learn.”',
            'Patterns that can be seen can be changed.',
          ],
          closingLine:
              'Clear data and honest reflection are recovery tools, not punishments.',
        ),
      ],
    ),
    LessonTrack(
      id: 'plus_pattern_interruption',
      title: 'Educate Me Plus — Pattern Interruption',
      subtitle:
          'Go deeper into warning signs, rituals, risk windows, and practical friction.',
      premiumOnly: true,
      lessons: <Lesson>[
        Lesson(
          id: 'ritual_before_urge',
          title: 'The ritual often begins before the urge',
          summary:
              'Secrecy, scrolling, isolation, and negotiation can be part of the cycle before intensity rises.',
          bullets: <String>[
            'Look for repeated setup behavior, not only peak desire.',
            'Changing location can interrupt a ritual before it becomes an urge.',
            'Earlier friction usually costs less effort than late resistance.',
          ],
          closingLine:
              'Treat the setup as actionable recovery information.',
        ),
        Lesson(
          id: 'risk_window_design',
          title: 'Design around predictable risk windows',
          summary:
              'A recurring vulnerable time is easier to prepare for than an apparently random failure.',
          bullets: <String>[
            'Name the time, setting, pressure, and privacy involved.',
            'Move the first safe action before the risky window begins.',
            'Use reminders as preparation, not as punishment.',
          ],
          closingLine:
              'Good recovery design reduces the number of decisions made under pressure.',
        ),
        Lesson(
          id: 'friction_and_replacement',
          title: 'Friction works better with replacement',
          summary:
              'Blocking one path is stronger when a realistic next action is already available.',
          bullets: <String>[
            'Friction slows automatic behavior.',
            'Replacement answers what to do with the discomfort next.',
            'The best replacement is simple enough to use while tired or stressed.',
          ],
          closingLine:
              'Pair every boundary with a specific next action.',
        ),
      ],
    ),
    LessonTrack(
      id: 'plus_rebuilding',
      title: 'Educate Me Plus — Rebuilding After a Slip',
      subtitle:
          'Use honest review, responsibility, and repair without turning a setback into surrender.',
      premiumOnly: true,
      lessons: <Lesson>[
        Lesson(
          id: 'slip_is_data_not_permission',
          title: 'A slip is data, not permission to continue',
          summary:
              'The first setback does not require a longer episode or a ruined week.',
          bullets: <String>[
            'Stop as soon as awareness returns.',
            'Change location before beginning the review.',
            'Record the earliest useful warning sign, not a moral verdict.',
          ],
          closingLine:
              'Recovery resumes with the next honest action.',
        ),
        Lesson(
          id: 'repair_the_condition',
          title: 'Repair one condition before the next window',
          summary:
              'Reflection becomes useful when it changes the environment, plan, or support step.',
          bullets: <String>[
            'Choose one condition that made acting out easier.',
            'Make one boundary or support change specific and visible.',
            'Avoid making ten promises that cannot be tested.',
          ],
          closingLine:
              'One completed repair is stronger than a dramatic list of intentions.',
        ),
      ],
    ),
  ];

  List<LessonTrack> getTracks() => _tracks;

  Lesson? findLessonById(String id) {
    for (final track in _tracks) {
      for (final lesson in track.lessons) {
        if (lesson.id == id) {
          return lesson;
        }
      }
    }
    return null;
  }
}
