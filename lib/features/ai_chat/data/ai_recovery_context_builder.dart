import '../../accountability/data/accountability_center_repository.dart';
import '../../log/data/mood_log_repository.dart';
import '../../log/data/recovery_event_repository.dart';
import '../../risk/data/risk_window_repository.dart';
import '../../settings/data/feature_control_settings_repository.dart';
import '../../support/data/recovery_plan_repository.dart';
import '../domain/ai_personalization_settings.dart';

class AiRecoveryContextBuilder {
  String _clean(String value){
    var text=value.trim().replaceAll(RegExp(r'[\r\n]+'),' ');
    text=text.replaceAll(RegExp(r'[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}'),'[email removed]');
    text=text.replaceAll(RegExp(r'(?:\+?1[-.\s]?)?(?:\(?\d{3}\)?[-.\s]?)\d{3}[-.\s]?\d{4}'),'[phone removed]');
    if(text.length>180)text='${text.substring(0,180)}…'; return text;
  }
  Future<String> build(AiPersonalizationSettings settings)async{
    if(!settings.enabled)return '';
    final lines=<String>['[USER-APPROVED RECOVERY CONTEXT]'];
    if(settings.includeCurrentGoal){final p=await AccountabilityCenterRepository().getPlan();if(p.currentGoal.trim().isNotEmpty)lines.add('Current goal: ${_clean(p.currentGoal)}');}
    if(settings.includeRecoveryPlan){final p=await RecoveryPlanRepository().getPlan();if(p.warningSigns.isNotEmpty)lines.add('Early warning signs: ${p.warningSigns.take(5).map(_clean).join(', ')}');if(p.triggers.isNotEmpty)lines.add('Triggers: ${p.triggers.take(5).map(_clean).join(', ')}');if(p.firstAction.trim().isNotEmpty)lines.add('First planned action: ${_clean(p.firstAction)}');if(p.groundingAction.trim().isNotEmpty)lines.add('Grounding action: ${_clean(p.groundingAction)}');}
    if(settings.includeRiskWindows){final windows=await RiskWindowRepository().getRiskWindows();for(final w in windows.where((item)=>item.isEnabled).take(3)){lines.add('Risk window: ${_clean(w.label)} ${w.timeRange}; prepare: ${_clean(w.preparationAction)}');}}
    if(settings.includeMoodNotes){final entries=await MoodLogRepository().getEntries();for(final e in entries.where((item)=>item.note.trim().isNotEmpty).take(3)){lines.add('Selected recent check-in note: ${_clean(e.note)}');}}
    if(settings.includeRecoveryNotes){final entries=await RecoveryEventRepository().getEntries();for(final e in entries.where((item)=>item.note.trim().isNotEmpty).take(3)){lines.add('Selected recent recovery note: ${_clean(e.note)}');}}
    if(settings.includeFaithPreference){final s=await FeatureControlSettingsRepository().getSettings();lines.add('Faith preference: ${s.faithLayerEnabled?'optional Christian reflections enabled':'secular recovery language preferred'}');}
    lines.add('[END USER-APPROVED CONTEXT]');
    var result=lines.join('\n');if(result.length>2400)result=result.substring(0,2400);return result;
  }
}
