enum PremiumPlan {
  none,
  plus,
  plusAi,
}

extension PremiumPlanX on PremiumPlan {
  String get label {
    switch (this) {
      case PremiumPlan.none:
        return 'Standard';
      case PremiumPlan.plus:
        return 'Breakout Plus';
      case PremiumPlan.plusAi:
        return 'Breakout Plus AI';
    }
  }

  String get subtitle {
    switch (this) {
      case PremiumPlan.none:
        return 'Core recovery and safety tools, free.';
      case PremiumPlan.plus:
        return 'Deeper local recovery tools with no AI required.';
      case PremiumPlan.plusAi:
        return 'Everything in Plus with optional AI personalization.';
    }
  }

  int get accessLevel {
    switch (this) {
      case PremiumPlan.none:
        return 0;
      case PremiumPlan.plus:
        return 1;
      case PremiumPlan.plusAi:
        return 2;
    }
  }

  bool includes(PremiumPlan requiredPlan) {
    return accessLevel >= requiredPlan.accessLevel;
  }
}
