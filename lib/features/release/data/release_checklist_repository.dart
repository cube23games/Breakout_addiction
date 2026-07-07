import '../domain/release_checklist_item.dart';

class ReleaseChecklistRepository {
  const ReleaseChecklistRepository();

  List<ReleaseChecklistItem> loadItems() {
    return const [
      ReleaseChecklistItem(
        title: 'Core recovery loop',
        status: ReleaseChecklistStatus.ready,
        detail: 'Home, Rescue, Cycle, Log, Insights, Learn, and Support are wired for the demo path.',
      ),
      ReleaseChecklistItem(
        title: 'Privacy-first positioning',
        status: ReleaseChecklistStatus.ready,
        detail: 'Lock mode, neutral labels, feature controls, and local-only defaults are visible in app.',
      ),
      ReleaseChecklistItem(
        title: 'Optional AI layer',
        status: ReleaseChecklistStatus.needsReview,
        detail: 'AI remains gated, clearly labeled, and not required for the main recovery experience.',
      ),
      ReleaseChecklistItem(
        title: 'Android release build',
        status: ReleaseChecklistStatus.needsReview,
        detail: 'CI is responsible for analyze, test, release APK, and generated Android platform files.',
      ),
      ReleaseChecklistItem(
        title: 'Play Store listing',
        status: ReleaseChecklistStatus.later,
        detail: 'Store screenshots, description, privacy policy link, and data safety answers still need final owner review.',
      ),
    ];
  }

  int readyCount() {
    return loadItems().where((item) => item.isReady).length;
  }
}
