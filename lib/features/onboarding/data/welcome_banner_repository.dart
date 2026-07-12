import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/welcome_message.dart';

class WelcomeBannerRepository {
  static const String _hasWelcomedKey =
      'welcome_banner_has_welcomed';
  static const String _remainingQuoteIndexesKey =
      'welcome_banner_remaining_quote_indexes';
  static const String _lastQuoteIndexKey =
      'welcome_banner_last_quote_index';

  static const List<String> _quotes = <String>[
    'One choice can change the direction of this moment.',
    'Pause. Breathe. Choose what comes next.',
    'A difficult moment is not the whole day.',
    'You do not have to follow every urge.',
    'Small victories still move you forward.',
    'Progress begins with the next honest choice.',
    'You are allowed to begin again.',
    'Keep moving forward, one decision at a time.',
    'The urge can pass without controlling you.',
    'Your next choice still belongs to you.',
    'A pause can create a different outcome.',
    'Today still has room for a better choice.',
  ];

  Future<WelcomeMessage> nextMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final hasWelcomed =
        prefs.getBool(_hasWelcomedKey) ?? false;

    if (!hasWelcomed) {
      await prefs.setBool(_hasWelcomedKey, true);
      return const WelcomeMessage(
        title: 'Welcome to Breakout',
        subtitle: 'Your recovery space is ready.',
      );
    }

    final index = await _nextQuoteIndex(prefs);
    return WelcomeMessage(
      title: 'Welcome back',
      subtitle: _quotes[index],
    );
  }

  Future<int> _nextQuoteIndex(
    SharedPreferences prefs,
  ) async {
    final lastIndex =
        prefs.getInt(_lastQuoteIndexKey);
    final stored = prefs.getStringList(
          _remainingQuoteIndexesKey,
        ) ??
        <String>[];

    final remaining = stored
        .map(int.tryParse)
        .whereType<int>()
        .where(
          (index) =>
              index >= 0 && index < _quotes.length,
        )
        .toList();

    if (remaining.isEmpty) {
      remaining.addAll(
        List<int>.generate(
          _quotes.length,
          (index) => index,
        ),
      );
      remaining.shuffle(Random());

      if (remaining.length > 1 &&
          remaining.first == lastIndex) {
        final first = remaining.removeAt(0);
        remaining.add(first);
      }
    }

    final selected = remaining.removeAt(0);
    await prefs.setInt(_lastQuoteIndexKey, selected);
    await prefs.setStringList(
      _remainingQuoteIndexesKey,
      remaining.map((index) => '$index').toList(),
    );

    return selected;
  }
}
