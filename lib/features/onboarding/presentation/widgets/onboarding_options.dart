import '../../../quotes/domain/daily_quote.dart';

class OnboardingOptions {
  const OnboardingOptions._();

  static const customGoal = 'I want to add my own reason';
  static const customTrigger = 'I want to add my own trigger';
  static const customRisk = 'Another time or situation';
  static const unknown = 'I’m not sure yet';

  static const goals = <String>[
    'Break the cycle earlier',
    'Reduce secrecy and shame',
    'Strengthen self-control',
    'Protect my relationships',
    customGoal,
  ];

  static const triggers = <String>[
    'Stress',
    'Loneliness',
    'Boredom',
    'Late-night phone use',
    'Arguments',
    'Scrolling social apps',
  ];

  static const riskSituations = <String>[
    'Late night',
    'Right after waking up',
    'After work',
    'When home alone',
    'Weekends',
    'After conflict',
  ];

  static const religions = <String>[
    'Christian',
    'General Faith',
    'Secular',
  ];

  static String quoteModeLabel(QuoteMode mode) {
    switch (mode) {
      case QuoteMode.motivational:
        return 'Motivational';
      case QuoteMode.recovery:
        return 'Recovery';
      case QuoteMode.faith:
        return 'Faith-sensitive';
    }
  }
}
