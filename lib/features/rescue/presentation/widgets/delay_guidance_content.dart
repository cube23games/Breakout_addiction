import '../../../quotes/domain/daily_quote.dart';

class DelayGuidanceContent {
  const DelayGuidanceContent._();

  static String tipFor(
    QuoteMode mode,
    Duration elapsed,
  ) {
    final tips = _tipsFor(mode);
    final index = (elapsed.inSeconds ~/ 20) % tips.length;

    return tips[index];
  }

  static List<String> _tipsFor(QuoteMode mode) {
    switch (mode) {
      case QuoteMode.faith:
        return const <String>[
          'Pause, pray or reflect, and choose the next honest action.',
          'Move into a more open space instead of staying isolated.',
          'Let this delay become an act of returning to your values.',
          'Use the breathing orb and let your body settle.',
        ];
      case QuoteMode.motivational:
        return const <String>[
          'Stand up and move to a different room.',
          'Put the phone somewhere that requires effort to retrieve.',
          'Drink water and take ten slow breaths.',
          'Choose the next strong action, not the perfect one.',
        ];
      case QuoteMode.recovery:
        return const <String>[
          'Change locations before the urge gains more momentum.',
          'Name the trigger without arguing with yourself about it.',
          'Review your Reasons to Stop and reconnect with what matters.',
          'Use the breathing orb until your body feels less activated.',
        ];
    }
  }
}
