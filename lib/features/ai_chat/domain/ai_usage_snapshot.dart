class AiUsageSnapshot {
  final int promptAttempts;
  final int stoppedAttempts;
  final int livePrototypeCalls;
  final int localOrStubReplies;
  final String lastModeLabel;
  final String dailyPeriodKey;
  final int dailyRemoteRequests;
  final int dailyRequestLimit;

  const AiUsageSnapshot({
    required this.promptAttempts,
    required this.stoppedAttempts,
    required this.livePrototypeCalls,
    required this.localOrStubReplies,
    required this.lastModeLabel,
    required this.dailyPeriodKey,
    required this.dailyRemoteRequests,
    required this.dailyRequestLimit,
  });

  factory AiUsageSnapshot.empty() {
    return const AiUsageSnapshot(
      promptAttempts: 0,
      stoppedAttempts: 0,
      livePrototypeCalls: 0,
      localOrStubReplies: 0,
      lastModeLabel: 'No activity yet',
      dailyPeriodKey: '',
      dailyRemoteRequests: 0,
      dailyRequestLimit: 40,
    );
  }

  int get remainingToday {
    final remaining = dailyRequestLimit - dailyRemoteRequests;
    return remaining < 0 ? 0 : remaining;
  }

  bool get fairUseReached =>
      dailyRemoteRequests >= dailyRequestLimit;
}
