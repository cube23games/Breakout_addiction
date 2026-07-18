import '../../insights/data/insights_repository.dart';
import '../../settings/data/feature_control_settings_repository.dart';
import '../domain/local_guidance_item.dart';

class PremiumLocalGuidanceRepository {
  final InsightsRepository _insightsRepository;
  final FeatureControlSettingsRepository _featureRepository;

  PremiumLocalGuidanceRepository({
    InsightsRepository? insightsRepository,
    FeatureControlSettingsRepository? featureRepository,
  })  : _insightsRepository = insightsRepository ?? InsightsRepository(),
        _featureRepository =
            featureRepository ?? FeatureControlSettingsRepository();

  Future<List<LocalGuidanceItem>> buildGuidance() async {
    final insights = await _insightsRepository.buildSummary();
    final settings = await _featureRepository.getSettings();
    final items = <LocalGuidanceItem>[
      LocalGuidanceItem(
        title: 'Start earlier than the urge',
        detail: insights.summaryLine,
        nextAction: insights.nextBestAction,
      ),
    ];

    switch (insights.strongestPressureDriver) {
      case 'Stress':
        items.add(
          const LocalGuidanceItem(
            title: 'Stress pressure plan',
            detail:
                'Stress can make quick relief feel urgent. Lower body tension and decision load before negotiating with the urge.',
            nextAction:
                'Use one grounding action, leave the private setting, and delay the next decision for ten minutes.',
          ),
        );
        break;
      case 'Loneliness':
        items.add(
          const LocalGuidanceItem(
            title: 'Loneliness interruption',
            detail:
                'Isolation can turn the behavior into a substitute for contact. Human connection is often a stronger interruption than more private willpower.',
            nextAction:
                'Move near other people or send a simple, non-graphic check-in to someone safe.',
          ),
        );
        break;
      case 'Boredom':
        items.add(
          const LocalGuidanceItem(
            title: 'Boredom friction',
            detail:
                'Unstructured time can become ritual setup. A concrete replacement works better than telling yourself to do nothing.',
            nextAction:
                'Choose a ten-minute activity that uses your hands, body, or attention away from the screen.',
          ),
        );
        break;
      default:
        items.add(
          const LocalGuidanceItem(
            title: 'Build more signal',
            detail:
                'Your recent logs do not yet show one dominant pressure driver. That is useful information, not failure.',
            nextAction:
                'Log the next urge earlier and include stress, loneliness, boredom, and the first warning sign.',
          ),
        );
        break;
    }

    items.add(
      LocalGuidanceItem(
        title: 'Recovery focus for now',
        detail: insights.recommendationLine,
        nextAction:
            'Pick one change small enough to repeat during the next vulnerable window.',
      ),
    );

    items.add(
      const LocalGuidanceItem(
        title: 'Encouragement pack',
        detail:
            'A difficult urge is not a verdict. Every interruption trains a different response, including the imperfect ones.',
        nextAction:
            'Name one thing you did earlier, safer, or more honestly than before.',
      ),
    );

    if (settings.faithLayerEnabled) {
      items.add(
        const LocalGuidanceItem(
          title: 'Optional Christian reflection',
          detail:
              'Recovery can include honesty, mercy, responsibility, and returning after a setback without hiding in shame.',
          nextAction:
              'Pause for a brief prayer, name the truth plainly, and take one concrete repair step.',
          faithSensitive: true,
        ),
      );
    }

    return items;
  }
}
