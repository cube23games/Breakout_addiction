import '../../../core/privacy/neutral_labels.dart';
import '../../guidance/data/local_guidance_service.dart';
import '../../log/data/mood_log_repository.dart';
import '../../log/domain/mood_entry.dart';
import '../../premium/data/premium_access_repository.dart';
import '../../premium_tools/data/premium_preferences_repository.dart';
import '../../premium_tools/domain/premium_preferences.dart';
import '../../privacy/data/privacy_label_repository.dart';
import '../../quotes/data/daily_quote_repository.dart';
import '../domain/widget_snapshot.dart';

class WidgetSnapshotRepository {
  final PrivacyLabelRepository _privacyRepository = PrivacyLabelRepository();
  final DailyQuoteRepository _quoteRepository = DailyQuoteRepository();
  final MoodLogRepository _moodRepository = MoodLogRepository();
  final PremiumAccessRepository _premiumRepository =
      PremiumAccessRepository();
  final PremiumPreferencesRepository _preferencesRepository =
      PremiumPreferencesRepository();
  final LocalGuidanceService _guidanceService = LocalGuidanceService();

  String _riskLabel(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return 'Guarded';
    }

    final recent = entries.take(3).toList();
    final averageStress =
        recent.map((e) => e.stress).reduce((a, b) => a + b) / recent.length;
    final averageLoneliness =
        recent.map((e) => e.loneliness).reduce((a, b) => a + b) / recent.length;
    final averageBoredom =
        recent.map((e) => e.boredom).reduce((a, b) => a + b) / recent.length;

    final pressure = averageStress + averageLoneliness + averageBoredom;
    if (pressure >= 21) return 'High Risk';
    if (pressure >= 16) return 'Elevated';
    if (pressure >= 10) return 'Guarded';
    return 'Low Risk';
  }

  Future<WidgetSnapshot> buildSnapshot() async {
    final neutralMode = await _privacyRepository.isNeutralModeEnabled();
    final quote = await _quoteRepository.getTodayQuote();
    final moods = await _moodRepository.getEntries();
    final riskLabel = _riskLabel(moods);
    final premium = await _premiumRepository.getStatus();

    var focusTitle = quote.text;
    var focusSubtitle = quote.focusLine;

    if (premium.hasPremium) {
      final preferences = await _preferencesRepository.getPreferences();
      switch (preferences.widgetFocus) {
        case PremiumWidgetFocus.encouragement:
          break;
        case PremiumWidgetFocus.riskSnapshot:
          focusTitle = 'Risk snapshot: $riskLabel';
          focusSubtitle =
              'Open Breakout early and prepare one safe next action.';
          break;
        case PremiumWidgetFocus.nextAction:
          final guidance = await _guidanceService.buildSnapshot();
          focusTitle = guidance.title;
          focusSubtitle = guidance.actionLine;
          break;
      }
    }

    return WidgetSnapshot(
      neutralMode: neutralMode,
      homeLabel: NeutralLabels.widgetHome(neutralMode),
      rescueLabel: NeutralLabels.widgetRescue(neutralMode),
      moodLabel: NeutralLabels.widgetMood(neutralMode),
      dailyFocusTitle: focusTitle,
      dailyFocusSubtitle: focusSubtitle,
      riskLabel: riskLabel,
    );
  }
}
