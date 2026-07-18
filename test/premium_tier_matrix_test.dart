import 'package:breakout_addiction/features/educate/data/lesson_repository.dart';
import 'package:breakout_addiction/features/premium/domain/premium_feature_catalog.dart';
import 'package:breakout_addiction/features/premium/domain/premium_plan.dart';
import 'package:breakout_addiction/features/premium_tools/data/guided_routine_repository.dart';
import 'package:breakout_addiction/features/premium_tools/data/recovery_journey_repository.dart';
import 'package:breakout_addiction/features/premium_tools/domain/premium_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Standard keeps every never-paywall feature', () {
    final core = PremiumFeatureCatalog.all
        .where((feature) => feature.neverPaywall)
        .toList();

    expect(core.length, greaterThanOrEqualTo(4));
    for (final feature in core) {
      expect(feature.requiredPlan, PremiumPlan.none);
      expect(feature.isIncludedFor(PremiumPlan.none), isTrue);
    }
  });

  test('Plus AI inherits every Plus feature', () {
    final plusFeatures = PremiumFeatureCatalog.exactlyFor(PremiumPlan.plus);
    final aiFeatures = PremiumFeatureCatalog.exactlyFor(PremiumPlan.plusAi);

    expect(plusFeatures.length, greaterThanOrEqualTo(10));
    expect(aiFeatures.length, greaterThanOrEqualTo(8));
    for (final feature in plusFeatures) {
      expect(feature.isIncludedFor(PremiumPlan.plusAi), isTrue);
    }
  });

  test('guided routines and journeys have stable unique identifiers', () {
    final routineIds = GuidedRoutineRepository.routines
        .map((routine) => routine.id)
        .toList();
    final journeyIds = RecoveryJourneyRepository.journeys
        .map((journey) => journey.id)
        .toList();

    expect(routineIds.toSet().length, routineIds.length);
    expect(journeyIds.toSet().length, journeyIds.length);
    expect(routineIds.length, greaterThanOrEqualTo(4));
    expect(journeyIds.length, greaterThanOrEqualTo(3));
  });

  test('Educate Me has real Plus-only learning tracks', () {
    final plusTracks = LessonRepository()
        .getTracks()
        .where((track) => track.premiumOnly)
        .toList();

    expect(plusTracks.length, greaterThanOrEqualTo(9));
    expect(
      plusTracks.expand((track) => track.lessons).length,
      greaterThanOrEqualTo(25),
    );
  });

  test('premium personalization defaults remain private and usable', () {
    final preferences = PremiumPreferences.defaults();

    expect(preferences.routineFocus, PremiumRoutineFocus.balanced);
    expect(preferences.reportDetail, PremiumReportDetail.detailed);
    expect(
      preferences.widgetFocus,
      PremiumWidgetFocus.encouragement,
    );
  });
}
