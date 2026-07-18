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
    LessonTrack(
      id: 'plus_stress_recovery',
      title: 'Educate Me Plus — Stress and Escape',
      subtitle:
          'Understand pressure, fatigue, avoidance, and healthier forms of relief.',
      premiumOnly: true,
      lessons: <Lesson>[
        Lesson(
          id: 'stress_narrows_choices',
          title: 'Stress narrows the choices you can see',
          summary:
              'Under pressure, the fastest familiar escape can look like the only available option.',
          bullets: <String>[
            'Stress reduces patience for discomfort.',
            'Automatic relief feels more convincing when you are depleted.',
            'A prepared two-minute action can reopen choice.',
          ],
          closingLine:
              'Recovery planning works best before pressure narrows the field.',
        ),
        Lesson(
          id: 'transition_risk',
          title: 'Transitions can carry hidden risk',
          summary:
              'The minutes after work, conflict, travel, or waking can combine fatigue with privacy.',
          bullets: <String>[
            'Unstructured transitions invite automatic rituals.',
            'A short transition routine reduces decisions under pressure.',
            'Environment changes often work faster than debate.',
          ],
          closingLine:
              'Protect the transition, not only the peak urge.',
        ),
        Lesson(
          id: 'real_relief_menu',
          title: 'Build a real relief menu',
          summary:
              'Replacement works when it offers believable relief rather than an idealized demand.',
          bullets: <String>[
            'Body relief, connection, rest, and completion solve different problems.',
            'The easiest useful option should be visible first.',
            'A replacement can be small and still interrupt the cycle.',
          ],
          closingLine:
              'The goal is a better next move, not a perfect evening.',
        ),
      ],
    ),
    LessonTrack(
      id: 'plus_loneliness_connection',
      title: 'Educate Me Plus — Loneliness and Connection',
      subtitle:
          'Separate being alone from isolating and build realistic human-support steps.',
      premiumOnly: true,
      lessons: <Lesson>[
        Lesson(
          id: 'alone_vs_isolating',
          title: 'Being alone is not the same as isolating',
          summary:
              'Isolation often includes hiding, withdrawal, and refusing available connection.',
          bullets: <String>[
            'Solitude can restore you; isolation usually shrinks your options.',
            'The cycle often protects secrecy before intensity rises.',
            'One low-pressure contact can interrupt the closed loop.',
          ],
          closingLine:
              'Notice when privacy turns into hiding.',
        ),
        Lesson(
          id: 'connection_before_crisis',
          title: 'Connection works better before crisis intensity',
          summary:
              'A small check-in is easier to use than an emergency disclosure at the peak.',
          bullets: <String>[
            'Support does not require telling every detail.',
            'A simple honest sentence can reduce isolation.',
            'Repeated safe contact builds a more available pathway.',
          ],
          closingLine:
              'Practice contact while you can still choose the words.',
        ),
        Lesson(
          id: 'shame_and_return',
          title: 'Shame says hide; recovery says return',
          summary:
              'After a slip, shame often asks for more secrecy, which protects the next cycle.',
          bullets: <String>[
            'You can take responsibility without disappearing.',
            'Useful disclosure is specific, bounded, and honest.',
            'Returning quickly matters more than performing perfect remorse.',
          ],
          closingLine:
              'The next act of honesty is part of recovery.',
        ),
      ],
    ),
    LessonTrack(
      id: 'plus_sleep_night',
      title: 'Educate Me Plus — Sleep and Nighttime Risk',
      subtitle:
          'Design around fatigue, privacy, waking, and late-night device use.',
      premiumOnly: true,
      lessons: <Lesson>[
        Lesson(
          id: 'fatigue_changes_bargaining',
          title: 'Fatigue changes the bargain',
          summary:
              'Late at night, long-term goals can feel less real than immediate relief.',
          bullets: <String>[
            'Fatigue weakens inhibition and increases emotional urgency.',
            'Removing decisions is often stronger than making promises.',
            'Charging location and screen-off time are recovery tools.',
          ],
          closingLine:
              'Protect the tired version of you with earlier decisions.',
        ),
        Lesson(
          id: 'waking_plan',
          title: 'Have a plan for waking during the night',
          summary:
              'Unexpected waking can create a vulnerable mix of privacy, discomfort, and easy access.',
          bullets: <String>[
            'Decide what the phone is for before the moment.',
            'Use a low-light, low-stimulation alternative.',
            'Change location when bargaining begins.',
          ],
          closingLine:
              'A nighttime plan should be simple enough to use half-awake.',
        ),
        Lesson(
          id: 'evening_closeout',
          title: 'Close the day instead of drifting out of it',
          summary:
              'A short closeout routine reduces endless scrolling and unresolved pressure.',
          bullets: <String>[
            'Review one win or lesson.',
            'Prepare tomorrow’s first action.',
            'End the day with a clear device boundary.',
          ],
          closingLine:
              'A deliberate ending protects the hours when judgment is tired.',
        ),
      ],
    ),
    LessonTrack(
      id: 'plus_digital_boundaries',
      title: 'Educate Me Plus — Digital Boundaries',
      subtitle:
          'Use friction, placement, settings, and replacement without pretending technology alone is recovery.',
      premiumOnly: true,
      lessons: <Lesson>[
        Lesson(
          id: 'boundary_not_cure',
          title: 'A boundary is support, not a cure',
          summary:
              'Filters and limits can slow the cycle, but they do not replace awareness, support, or action.',
          bullets: <String>[
            'Friction creates time for choice.',
            'A determined workaround reveals where more support is needed.',
            'Boundaries work best with a prepared replacement.',
          ],
          closingLine:
              'Use technology to support recovery, not to carry all of it.',
        ),
        Lesson(
          id: 'device_placement',
          title: 'Device placement changes behavior',
          summary:
              'Distance, visibility, and shared space can interrupt automatic access.',
          bullets: <String>[
            'Where the device lives matters more than a vague intention.',
            'Charging outside the riskiest room reduces late-night negotiation.',
            'Public or shared use can reduce secrecy.',
          ],
          closingLine:
              'Make the safer action physically easier.',
        ),
        Lesson(
          id: 'scrolling_setup',
          title: 'Scrolling can become the setup',
          summary:
              'Seemingly neutral browsing may gradually increase novelty, privacy, and bargaining.',
          bullets: <String>[
            'Notice when the goal of scrolling changes.',
            'Time and location can be warning signals.',
            'Stop the setup before it needs to become explicit.',
          ],
          closingLine:
              'The earlier exit is usually the cheaper exit.',
        ),
      ],
    ),
    LessonTrack(
      id: 'plus_accountability',
      title: 'Educate Me Plus — Accountability That Helps',
      subtitle:
          'Prepare honest, bounded, useful check-ins instead of surveillance or shame.',
      premiumOnly: true,
      lessons: <Lesson>[
        Lesson(
          id: 'accountability_not_policing',
          title: 'Accountability is not policing',
          summary:
              'Healthy accountability increases honesty and action without turning another person into a guard.',
          bullets: <String>[
            'The user remains responsible for choices.',
            'The partner needs clear consent and boundaries.',
            'Check-ins should lead to a concrete next step.',
          ],
          closingLine:
              'Support works best when both people know the purpose.',
        ),
        Lesson(
          id: 'share_the_useful_part',
          title: 'Share the useful part',
          summary:
              'A good summary can be honest without exposing every private detail.',
          bullets: <String>[
            'Share trends, needs, and commitments intentionally.',
            'Review reports before copying or sending.',
            'Private notes should remain private unless deliberately included.',
          ],
          closingLine:
              'Honesty and privacy can coexist.',
        ),
        Lesson(
          id: 'prepare_the_checkin',
          title: 'Prepare before the check-in',
          summary:
              'Reflection is clearer when you decide what happened, what helped, and what support you need.',
          bullets: <String>[
            'Name one win, one risk, and one next action.',
            'Avoid turning the check-in into a courtroom.',
            'Ask for a specific kind of support.',
          ],
          closingLine:
              'Preparation makes accountability more actionable and less frightening.',
        ),
      ],
    ),
    LessonTrack(
      id: 'plus_relationship_repair',
      title: 'Educate Me Plus — Relationship Repair Preparation',
      subtitle:
          'Approach honesty, impact, listening, and repair without using the app as therapy.',
      premiumOnly: true,
      lessons: <Lesson>[
        Lesson(
          id: 'impact_before_defense',
          title: 'Understand impact before defending intent',
          summary:
              'A partner may be responding to secrecy, broken trust, or emotional distance as much as the behavior itself.',
          bullets: <String>[
            'Intent does not erase impact.',
            'Listening is different from agreeing with every conclusion.',
            'Repair begins with reality, not image management.',
          ],
          closingLine:
              'Make room for the other person’s experience.',
        ),
        Lesson(
          id: 'honesty_with_support',
          title: 'Important disclosures may need professional support',
          summary:
              'Timing, detail, safety, and relationship history can make disclosure complex.',
          bullets: <String>[
            'Do not use an app-generated script as a substitute for judgment.',
            'A qualified counselor can help plan difficult conversations.',
            'Immediate safety concerns come before relationship processing.',
          ],
          closingLine:
              'Use human expertise when the stakes are high.',
        ),
        Lesson(
          id: 'repair_is_repeated',
          title: 'Repair is repeated behavior',
          summary:
              'Trust usually returns through consistent honesty, boundaries, and follow-through rather than one dramatic promise.',
          bullets: <String>[
            'Keep commitments small enough to verify.',
            'Expect repair to take time.',
            'Progress does not require demanding immediate forgiveness.',
          ],
          closingLine:
              'Let repeated action carry more weight than intensity.',
        ),
      ],
    ),
    LessonTrack(
      id: 'plus_faith_recovery',
      title: 'Educate Me Plus — Optional Christian Recovery',
      subtitle:
          'Join grace, confession, renewal, boundaries, and human support without replacing professional care.',
      premiumOnly: true,
      lessons: <Lesson>[
        Lesson(
          id: 'grace_and_responsibility',
          title: 'Grace and responsibility belong together',
          summary:
              'Grace can reduce hiding while responsibility turns honesty into changed action.',
          bullets: <String>[
            'Grace is not permission to ignore harm.',
            'Responsibility is not self-hatred.',
            'Truth, support, and practical boundaries can work together.',
          ],
          closingLine:
              'Receive grace in a way that makes honesty safer.',
        ),
        Lesson(
          id: 'confession_and_connection',
          title: 'Confession should move toward connection',
          summary:
              'Private shame can keep the struggle sealed off from wise human support.',
          bullets: <String>[
            'Choose trustworthy, appropriate support.',
            'Confession is not the same as public exposure.',
            'Prayer and practical action can reinforce each other.',
          ],
          closingLine:
              'Bring the struggle into truthful relationship.',
        ),
        Lesson(
          id: 'renewing_attention',
          title: 'Renew attention toward what gives life',
          summary:
              'Recovery includes more than saying no; it includes practicing attention, service, rest, and meaningful connection.',
          bullets: <String>[
            'Attention grows where it is repeatedly placed.',
            'Healthy replacement matters.',
            'Spiritual practices should support, not hide, emotional needs.',
          ],
          closingLine:
              'Choose one faithful action that is concrete today.',
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
