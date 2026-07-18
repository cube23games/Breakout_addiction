class ProgressScorecard {
  final int engagementScore;
  final String momentumLabel;
  final String scoreMeaning;
  final int victories7;
  final int urges7;
  final int slips7;
  final int checkIns7;
  final int routineStepsCompleted;
  final int routineStepsTotal;
  final int programStepsCompleted;
  final int programStepsTotal;
  final int planSectionsCompleted;
  final int planSectionsTotal;
  final List<String> milestones;
  final String nextFocus;

  const ProgressScorecard({
    required this.engagementScore,
    required this.momentumLabel,
    required this.scoreMeaning,
    required this.victories7,
    required this.urges7,
    required this.slips7,
    required this.checkIns7,
    required this.routineStepsCompleted,
    required this.routineStepsTotal,
    required this.programStepsCompleted,
    required this.programStepsTotal,
    required this.planSectionsCompleted,
    required this.planSectionsTotal,
    required this.milestones,
    required this.nextFocus,
  });

  double get routineProgress => routineStepsTotal == 0
      ? 0
      : routineStepsCompleted / routineStepsTotal;

  double get programProgress => programStepsTotal == 0
      ? 0
      : programStepsCompleted / programStepsTotal;

  double get planProgress => planSectionsTotal == 0
      ? 0
      : planSectionsCompleted / planSectionsTotal;
}
