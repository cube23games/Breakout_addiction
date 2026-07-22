class AiPersonalizationSettings {
  const AiPersonalizationSettings({
    this.enabled = false,
    this.includeCurrentGoal = false,
    this.includeRecoveryPlan = false,
    this.includeRiskWindows = false,
    this.includeMoodNotes = false,
    this.includeRecoveryNotes = false,
    this.includeFaithPreference = false,
  });
  final bool enabled;
  final bool includeCurrentGoal;
  final bool includeRecoveryPlan;
  final bool includeRiskWindows;
  final bool includeMoodNotes;
  final bool includeRecoveryNotes;
  final bool includeFaithPreference;
  factory AiPersonalizationSettings.defaults()=>const AiPersonalizationSettings();
  AiPersonalizationSettings copyWith({bool? enabled,bool? includeCurrentGoal,bool? includeRecoveryPlan,bool? includeRiskWindows,bool? includeMoodNotes,bool? includeRecoveryNotes,bool? includeFaithPreference})=>AiPersonalizationSettings(
    enabled:enabled??this.enabled,includeCurrentGoal:includeCurrentGoal??this.includeCurrentGoal,
    includeRecoveryPlan:includeRecoveryPlan??this.includeRecoveryPlan,includeRiskWindows:includeRiskWindows??this.includeRiskWindows,
    includeMoodNotes:includeMoodNotes??this.includeMoodNotes,includeRecoveryNotes:includeRecoveryNotes??this.includeRecoveryNotes,
    includeFaithPreference:includeFaithPreference??this.includeFaithPreference,
  );
  Map<String,dynamic> toMap()=><String,dynamic>{'enabled':enabled,'includeCurrentGoal':includeCurrentGoal,'includeRecoveryPlan':includeRecoveryPlan,'includeRiskWindows':includeRiskWindows,'includeMoodNotes':includeMoodNotes,'includeRecoveryNotes':includeRecoveryNotes,'includeFaithPreference':includeFaithPreference};
  factory AiPersonalizationSettings.fromMap(Map<String,dynamic> map)=>AiPersonalizationSettings(
    enabled:(map['enabled'] as bool?)??false,includeCurrentGoal:(map['includeCurrentGoal'] as bool?)??false,
    includeRecoveryPlan:(map['includeRecoveryPlan'] as bool?)??false,includeRiskWindows:(map['includeRiskWindows'] as bool?)??false,
    includeMoodNotes:(map['includeMoodNotes'] as bool?)??false,includeRecoveryNotes:(map['includeRecoveryNotes'] as bool?)??false,
    includeFaithPreference:(map['includeFaithPreference'] as bool?)??false,
  );
}
