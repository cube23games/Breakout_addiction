enum PremiumRoutineFocus {
  balanced,
  prevention,
  rebuilding,
}

enum PremiumReportDetail {
  concise,
  detailed,
}

enum PremiumWidgetFocus {
  encouragement,
  riskSnapshot,
  nextAction,
}

extension PremiumRoutineFocusX on PremiumRoutineFocus {
  String get label {
    switch (this) {
      case PremiumRoutineFocus.balanced:
        return 'Balanced';
      case PremiumRoutineFocus.prevention:
        return 'Prevention first';
      case PremiumRoutineFocus.rebuilding:
        return 'Rebuilding after setbacks';
    }
  }
}

extension PremiumReportDetailX on PremiumReportDetail {
  String get label {
    switch (this) {
      case PremiumReportDetail.concise:
        return 'Concise';
      case PremiumReportDetail.detailed:
        return 'Detailed';
    }
  }
}

extension PremiumWidgetFocusX on PremiumWidgetFocus {
  String get label {
    switch (this) {
      case PremiumWidgetFocus.encouragement:
        return 'Daily encouragement';
      case PremiumWidgetFocus.riskSnapshot:
        return 'Risk snapshot';
      case PremiumWidgetFocus.nextAction:
        return 'Next recovery action';
    }
  }
}

class PremiumPreferences {
  final PremiumRoutineFocus routineFocus;
  final PremiumReportDetail reportDetail;
  final PremiumWidgetFocus widgetFocus;

  const PremiumPreferences({
    required this.routineFocus,
    required this.reportDetail,
    required this.widgetFocus,
  });

  factory PremiumPreferences.defaults() {
    return const PremiumPreferences(
      routineFocus: PremiumRoutineFocus.balanced,
      reportDetail: PremiumReportDetail.detailed,
      widgetFocus: PremiumWidgetFocus.encouragement,
    );
  }

  PremiumPreferences copyWith({
    PremiumRoutineFocus? routineFocus,
    PremiumReportDetail? reportDetail,
    PremiumWidgetFocus? widgetFocus,
  }) {
    return PremiumPreferences(
      routineFocus: routineFocus ?? this.routineFocus,
      reportDetail: reportDetail ?? this.reportDetail,
      widgetFocus: widgetFocus ?? this.widgetFocus,
    );
  }
}
