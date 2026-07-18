import '../../../core/storage/local_data_safety.dart';

class RecoveryPlan {
  final List<String> riskyPlaces;
  final String firstAction;
  final String secondAction;
  final String groundingAction;
  final String supportPerson;
  final String fallbackPlan;
  final List<String> warningSigns;
  final List<String> triggers;
  final List<String> highRiskTimes;
  final String postSlipPlan;
  final String morningCommitment;
  final String eveningCommitment;
  final DateTime? reviewDate;
  final DateTime? updatedAt;

  const RecoveryPlan({
    required this.riskyPlaces,
    required this.firstAction,
    required this.secondAction,
    required this.groundingAction,
    required this.supportPerson,
    required this.fallbackPlan,
    this.warningSigns = const <String>[],
    this.triggers = const <String>[],
    this.highRiskTimes = const <String>[],
    this.postSlipPlan = '',
    this.morningCommitment = '',
    this.eveningCommitment = '',
    this.reviewDate,
    this.updatedAt,
  });

  factory RecoveryPlan.defaults() {
    return const RecoveryPlan(
      riskyPlaces: <String>[],
      firstAction: '',
      secondAction: '',
      groundingAction: '',
      supportPerson: '',
      fallbackPlan: '',
    );
  }

  int get completedSections {
    final values = <bool>[
      riskyPlaces.isNotEmpty,
      firstAction.trim().isNotEmpty,
      secondAction.trim().isNotEmpty,
      groundingAction.trim().isNotEmpty,
      supportPerson.trim().isNotEmpty,
      fallbackPlan.trim().isNotEmpty,
      warningSigns.isNotEmpty,
      triggers.isNotEmpty,
      highRiskTimes.isNotEmpty,
      postSlipPlan.trim().isNotEmpty,
      morningCommitment.trim().isNotEmpty,
      eveningCommitment.trim().isNotEmpty,
    ];
    return values.where((value) => value).length;
  }

  int get totalSections => 12;

  double get completion =>
      totalSections == 0 ? 0 : completedSections / totalSections;

  bool get hasBasicPlan =>
      firstAction.trim().isNotEmpty ||
      secondAction.trim().isNotEmpty ||
      groundingAction.trim().isNotEmpty ||
      fallbackPlan.trim().isNotEmpty;

  bool get hasAdvancedPlan =>
      warningSigns.isNotEmpty ||
      triggers.isNotEmpty ||
      highRiskTimes.isNotEmpty ||
      postSlipPlan.trim().isNotEmpty ||
      morningCommitment.trim().isNotEmpty ||
      eveningCommitment.trim().isNotEmpty;

  RecoveryPlan copyWith({
    List<String>? riskyPlaces,
    String? firstAction,
    String? secondAction,
    String? groundingAction,
    String? supportPerson,
    String? fallbackPlan,
    List<String>? warningSigns,
    List<String>? triggers,
    List<String>? highRiskTimes,
    String? postSlipPlan,
    String? morningCommitment,
    String? eveningCommitment,
    DateTime? reviewDate,
    DateTime? updatedAt,
  }) {
    return RecoveryPlan(
      riskyPlaces: riskyPlaces ?? this.riskyPlaces,
      firstAction: firstAction ?? this.firstAction,
      secondAction: secondAction ?? this.secondAction,
      groundingAction: groundingAction ?? this.groundingAction,
      supportPerson: supportPerson ?? this.supportPerson,
      fallbackPlan: fallbackPlan ?? this.fallbackPlan,
      warningSigns: warningSigns ?? this.warningSigns,
      triggers: triggers ?? this.triggers,
      highRiskTimes: highRiskTimes ?? this.highRiskTimes,
      postSlipPlan: postSlipPlan ?? this.postSlipPlan,
      morningCommitment: morningCommitment ?? this.morningCommitment,
      eveningCommitment: eveningCommitment ?? this.eveningCommitment,
      reviewDate: reviewDate ?? this.reviewDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'riskyPlaces': riskyPlaces,
      'firstAction': firstAction,
      'secondAction': secondAction,
      'groundingAction': groundingAction,
      'supportPerson': supportPerson,
      'fallbackPlan': fallbackPlan,
      'warningSigns': warningSigns,
      'triggers': triggers,
      'highRiskTimes': highRiskTimes,
      'postSlipPlan': postSlipPlan,
      'morningCommitment': morningCommitment,
      'eveningCommitment': eveningCommitment,
      'reviewDate': reviewDate?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory RecoveryPlan.fromMap(Map<String, dynamic> map) {
    return RecoveryPlan(
      riskyPlaces: LocalDataSafety.stringList(map['riskyPlaces']),
      firstAction: (map['firstAction'] as String?) ?? '',
      secondAction: (map['secondAction'] as String?) ?? '',
      groundingAction: (map['groundingAction'] as String?) ?? '',
      supportPerson: (map['supportPerson'] as String?) ?? '',
      fallbackPlan: (map['fallbackPlan'] as String?) ?? '',
      warningSigns: LocalDataSafety.stringList(map['warningSigns']),
      triggers: LocalDataSafety.stringList(map['triggers']),
      highRiskTimes: LocalDataSafety.stringList(map['highRiskTimes']),
      postSlipPlan: (map['postSlipPlan'] as String?) ?? '',
      morningCommitment: (map['morningCommitment'] as String?) ?? '',
      eveningCommitment: (map['eveningCommitment'] as String?) ?? '',
      reviewDate: DateTime.tryParse(
        (map['reviewDate'] as String?) ?? '',
      ),
      updatedAt: DateTime.tryParse(
        (map['updatedAt'] as String?) ?? '',
      ),
    );
  }
}
