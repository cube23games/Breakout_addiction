enum AccountabilityScope {
  progress,
  recentUrges,
  relapseEvents,
  victoryEvents,
  moodTrends,
  riskWindows,
  recoveryPlan,
  reasonsToStop,
  supportNeeded,
}

extension AccountabilityScopeX on AccountabilityScope {
  String get label {
    switch (this) {
      case AccountabilityScope.progress:
        return 'Recovery progress';
      case AccountabilityScope.recentUrges:
        return 'Recent urges';
      case AccountabilityScope.relapseEvents:
        return 'Relapse events';
      case AccountabilityScope.victoryEvents:
        return 'Victory events';
      case AccountabilityScope.moodTrends:
        return 'Mood trends';
      case AccountabilityScope.riskWindows:
        return 'Risk windows';
      case AccountabilityScope.recoveryPlan:
        return 'Recovery plan';
      case AccountabilityScope.reasonsToStop:
        return 'Reasons to stop';
      case AccountabilityScope.supportNeeded:
        return 'Support-needed flag';
    }
  }
}
