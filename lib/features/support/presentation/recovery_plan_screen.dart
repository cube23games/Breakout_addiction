import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/tag_chip_input.dart';
import '../../premium/data/premium_access_repository.dart';
import '../../premium/domain/premium_status.dart';
import '../data/recovery_plan_repository.dart';
import '../domain/recovery_plan.dart';

class RecoveryPlanScreen extends StatefulWidget { const RecoveryPlanScreen({super.key}); @override State<RecoveryPlanScreen> createState()=>_RecoveryPlanScreenState(); }
class _RecoveryPlanScreenState extends State<RecoveryPlanScreen>{
  final _repository=RecoveryPlanRepository(); final _premiumRepository=PremiumAccessRepository();
  final _first=TextEditingController(); final _second=TextEditingController(); final _grounding=TextEditingController(); final _support=TextEditingController(); final _fallback=TextEditingController();
  final _postSlip=TextEditingController(); final _morning=TextEditingController(); final _evening=TextEditingController();
  List<String> _riskyPlaces=[]; List<String> _warningSigns=[]; List<String> _triggers=[]; List<String> _highRiskTimes=[];
  RecoveryPlan _loaded=RecoveryPlan.defaults(); PremiumStatus _premium=PremiumStatus.defaults(); DateTime? _reviewDate; bool _loading=true; bool _saving=false;
  bool get _hasPlus=>_premium.hasPremium;
  @override void initState(){super.initState();_load();}
  @override void dispose(){for(final c in [_first,_second,_grounding,_support,_fallback,_postSlip,_morning,_evening]){c.dispose();}super.dispose();}
  Future<void> _load()async{final plan=await _repository.getPlan();final premium=await _premiumRepository.getStatus();if(!mounted)return;_loaded=plan;_premium=premium;_riskyPlaces=[...plan.riskyPlaces];_warningSigns=[...plan.warningSigns];_triggers=[...plan.triggers];_highRiskTimes=[...plan.highRiskTimes];_first.text=plan.firstAction;_second.text=plan.secondAction;_grounding.text=plan.groundingAction;_support.text=plan.supportPerson;_fallback.text=plan.fallbackPlan;_postSlip.text=plan.postSlipPlan;_morning.text=plan.morningCommitment;_evening.text=plan.eveningCommitment;_reviewDate=plan.reviewDate;setState(()=>_loading=false);}
  bool get _hasMeaningfulPlanEntry=>_riskyPlaces.isNotEmpty||[_first,_second,_grounding,_support,_fallback].any((c)=>c.text.trim().isNotEmpty)||(_hasPlus&&(_warningSigns.isNotEmpty||_triggers.isNotEmpty||_highRiskTimes.isNotEmpty||[_postSlip,_morning,_evening].any((c)=>c.text.trim().isNotEmpty)));
  Future<void> _save()async{if(!_hasMeaningfulPlanEntry){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Add at least one recovery plan entry before saving.')));return;}setState(()=>_saving=true);final plan=RecoveryPlan(riskyPlaces:_riskyPlaces,firstAction:_first.text.trim(),secondAction:_second.text.trim(),groundingAction:_grounding.text.trim(),supportPerson:_support.text.trim(),fallbackPlan:_fallback.text.trim(),warningSigns:_hasPlus?_warningSigns:_loaded.warningSigns,triggers:_hasPlus?_triggers:_loaded.triggers,highRiskTimes:_hasPlus?_highRiskTimes:_loaded.highRiskTimes,postSlipPlan:_hasPlus?_postSlip.text.trim():_loaded.postSlipPlan,morningCommitment:_hasPlus?_morning.text.trim():_loaded.morningCommitment,eveningCommitment:_hasPlus?_evening.text.trim():_loaded.eveningCommitment,reviewDate:_hasPlus?_reviewDate:_loaded.reviewDate,updatedAt:DateTime.now().toUtc());await _repository.savePlan(plan);if(!mounted)return;setState((){_loaded=plan;_saving=false;});ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Recovery plan saved.')));}
  Future<void> _pickReviewDate()async{final now=DateTime.now();final selected=await showDatePicker(context:context,initialDate:_reviewDate??now.add(const Duration(days:30)),firstDate:now.subtract(const Duration(days:365)),lastDate:now.add(const Duration(days:730)));if(selected!=null&&mounted)setState(()=>_reviewDate=selected);}
  Widget _text(String title,String hint,TextEditingController controller,{int lines=2})=>InfoCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:AppTypography.section),const SizedBox(height:AppSpacing.sm),TextField(controller:controller,minLines:lines,maxLines:lines+2,decoration:InputDecoration(hintText:hint,border:const OutlineInputBorder()))]));
  Widget _chips(String title,String hint,List<String> values,ValueChanged<List<String>> onChanged)=>InfoCard(child:TagChipInput(label:title,hint:hint,values:values,onChanged:onChanged));
  Widget _locked()=>InfoCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Breakout Plus Plan Builder',style:AppTypography.section),const SizedBox(height:AppSpacing.sm),const Text('The basic action plan remains available to everyone. Plus adds warning signs, triggers, high-risk times, commitments, and review dates.',style:AppTypography.muted),const SizedBox(height:AppSpacing.md),PrimaryButton(label:'Open Breakout Plus',icon:Icons.workspace_premium_outlined,onPressed:()=>Navigator.pushNamed(context,RouteNames.premium))]));
  @override Widget build(BuildContext context){if(_loading)return Scaffold(appBar:AppBar(title:const Text('Recovery Plan')),body:const Center(child:CircularProgressIndicator()));return Scaffold(appBar:AppBar(title:const Text('Recovery Plan')),body:ListView(padding:const EdgeInsets.all(AppSpacing.lg),children:[
    Text('Build a plan you can use.',style:AppTypography.title),const SizedBox(height:AppSpacing.xs),const Text('Add one item at a time. Press comma, Enter, or Add to create a removable chip.',style:AppTypography.muted),const SizedBox(height:AppSpacing.lg),
    _chips('Risky places','Bedroom at night',_riskyPlaces,(v)=>setState(()=>_riskyPlaces=v)),const SizedBox(height:AppSpacing.md),
    _text('First action','Leave the room or put the phone away.',_first),const SizedBox(height:AppSpacing.md),_text('Backup action','Text someone or open Rescue.',_second),const SizedBox(height:AppSpacing.md),_text('Grounding action','Breathe, walk, or use cold water.',_grounding),const SizedBox(height:AppSpacing.md),_text('Support person','Who will you contact?',_support,lines:1),const SizedBox(height:AppSpacing.md),_text('Fallback plan','What will you do if pressure stays high?',_fallback,lines:3),const SizedBox(height:AppSpacing.lg),
    if (!_hasPlus) _locked() else ...[
      Text('Plus plan details',style:AppTypography.title),const SizedBox(height:AppSpacing.md),
      _chips('Early Warning Signs','Restless scrolling',_warningSigns,(v)=>setState(()=>_warningSigns=v)),const SizedBox(height:AppSpacing.md),
      _chips('Primary Triggers','Stress or loneliness',_triggers,(v)=>setState(()=>_triggers=v)),const SizedBox(height:AppSpacing.md),
      _chips('High-Risk Times','Late night',_highRiskTimes,(v)=>setState(()=>_highRiskTimes=v)),const SizedBox(height:AppSpacing.md),
      _text('Morning Commitment','One action for this morning.',_morning),const SizedBox(height:AppSpacing.md),_text('Evening Commitment','One boundary for tonight.',_evening),const SizedBox(height:AppSpacing.md),_text('Post-Slip Rebuild Plan','What will you do in the first 15 minutes?',_postSlip,lines:3),const SizedBox(height:AppSpacing.sm),OutlinedButton.icon(onPressed:_pickReviewDate,icon:const Icon(Icons.event_outlined),label:Text(_reviewDate==null?'Choose Review Date':'Review ${_reviewDate!.month}/${_reviewDate!.day}/${_reviewDate!.year}')),
      const SizedBox(height:AppSpacing.md),InfoCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Plan Readiness',style:AppTypography.section),const SizedBox(height:AppSpacing.sm),LinearProgressIndicator(value:_loaded.completion.clamp(0,1)),const SizedBox(height:AppSpacing.xs),Text('${(_loaded.completion*100).round()}% of plan sections saved',style:AppTypography.muted)])),
    ],const SizedBox(height:AppSpacing.lg),PrimaryButton(label:_saving?'Saving...':'Save Recovery Plan',icon:Icons.save_outlined,onPressed:_saving?(){}:_save),
  ]));}
}
