enum ReleaseChecklistStatus {
  ready,
  needsReview,
  later,
}

extension ReleaseChecklistStatusLabel on ReleaseChecklistStatus {
  String get label {
    switch (this) {
      case ReleaseChecklistStatus.ready:
        return 'Ready';
      case ReleaseChecklistStatus.needsReview:
        return 'Needs review';
      case ReleaseChecklistStatus.later:
        return 'Later';
    }
  }
}

class ReleaseChecklistItem {
  const ReleaseChecklistItem({
    required this.title,
    required this.status,
    required this.detail,
  });

  final String title;
  final ReleaseChecklistStatus status;
  final String detail;

  bool get isReady => status == ReleaseChecklistStatus.ready;
}
