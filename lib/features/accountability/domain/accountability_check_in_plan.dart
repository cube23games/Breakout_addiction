class AccountabilityCheckInPlan {
  final String partnerName;
  final DateTime? nextCheckIn;
  final String currentGoal;
  final String winToShare;
  final String riskToDiscuss;
  final String supportRequest;
  final String nextCommitment;
  final DateTime? updatedAt;

  const AccountabilityCheckInPlan({
    required this.partnerName,
    required this.nextCheckIn,
    required this.currentGoal,
    required this.winToShare,
    required this.riskToDiscuss,
    required this.supportRequest,
    required this.nextCommitment,
    this.updatedAt,
  });

  factory AccountabilityCheckInPlan.defaults() {
    return const AccountabilityCheckInPlan(
      partnerName: '',
      nextCheckIn: null,
      currentGoal: '',
      winToShare: '',
      riskToDiscuss: '',
      supportRequest: '',
      nextCommitment: '',
    );
  }

  bool get hasUsefulPreparation =>
      currentGoal.trim().isNotEmpty ||
      winToShare.trim().isNotEmpty ||
      riskToDiscuss.trim().isNotEmpty ||
      supportRequest.trim().isNotEmpty ||
      nextCommitment.trim().isNotEmpty;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'partnerName': partnerName,
      'nextCheckIn': nextCheckIn?.toIso8601String(),
      'currentGoal': currentGoal,
      'winToShare': winToShare,
      'riskToDiscuss': riskToDiscuss,
      'supportRequest': supportRequest,
      'nextCommitment': nextCommitment,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory AccountabilityCheckInPlan.fromMap(Map<String, dynamic> map) {
    return AccountabilityCheckInPlan(
      partnerName: (map['partnerName'] as String?) ?? '',
      nextCheckIn: DateTime.tryParse(
        (map['nextCheckIn'] as String?) ?? '',
      ),
      currentGoal: (map['currentGoal'] as String?) ?? '',
      winToShare: (map['winToShare'] as String?) ?? '',
      riskToDiscuss: (map['riskToDiscuss'] as String?) ?? '',
      supportRequest: (map['supportRequest'] as String?) ?? '',
      nextCommitment: (map['nextCommitment'] as String?) ?? '',
      updatedAt: DateTime.tryParse(
        (map['updatedAt'] as String?) ?? '',
      ),
    );
  }
}
