import '../domain/demo_showcase_item.dart';

class DemoShowcaseRepository {
  const DemoShowcaseRepository();

  List<DemoShowcaseItem> getItems() {
    return const <DemoShowcaseItem>[
      DemoShowcaseItem(
        title: 'Private Recovery Core',
        subtitle:
            'Core recovery tools remain useful without AI.',
        bullets: <String>[
          'Cycle, Rescue, logs, insights, support, and privacy tools work together.',
          'Users can keep the experience simple and local-first.',
          'Supportive language is designed to reduce shame and encourage a practical next step.',
        ],
      ),
      DemoShowcaseItem(
        title: 'Breakout Plus Without AI',
        subtitle:
            'Premium stands on its own through local guidance and faith-sensitive packs.',
        bullets: <String>[
          'Local premium guidance is unlocked without AI chat.',
          'Faith-sensitive packs can stay local and private.',
          'Plus is valuable even for users who never want AI.',
        ],
      ),
      DemoShowcaseItem(
        title: 'Optional AI Support',
        subtitle:
            'AI is clearly separated into Breakout Plus AI and can be turned off.',
        bullets: <String>[
          'AI mode clarity is visible on-screen.',
          'AI status and privacy limits are clearly labeled.',
          'Emergency fallback pushes users toward human help, not more chat.',
        ],
      ),
      DemoShowcaseItem(
        title: 'Proactive Interruption',
        subtitle:
            'The app can support earlier action before a risky moment intensifies.',
        bullets: <String>[
          'Risk windows are configurable.',
          'Local reminders can support planned risk windows.',
          'Quick actions support earlier interruption.',
        ],
      ),
    ];
  }
}
