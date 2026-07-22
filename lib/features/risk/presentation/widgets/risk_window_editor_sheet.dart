import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/tag_chip_input.dart';
import '../../domain/risk_window.dart';

class RiskWindowEditorSheet extends StatefulWidget {
  const RiskWindowEditorSheet({required this.use24HourFormat,this.existing,super.key});
  final RiskWindow? existing;
  final bool use24HourFormat;
  @override
  State<RiskWindowEditorSheet> createState()=>_RiskWindowEditorSheetState();
}

class _RiskWindowEditorSheetState extends State<RiskWindowEditorSheet> {
  late final TextEditingController _labelController;
  late final TextEditingController _preparationController;
  late final TextEditingController _supportController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _enabled;
  late List<String> _warningSigns;
  late List<String> _triggers;
  String? _error;

  @override
  void initState(){
    super.initState(); final e=widget.existing;
    _labelController=TextEditingController(text:e?.label??'');
    _preparationController=TextEditingController(text:e?.preparationAction??'');
    _supportController=TextEditingController(text:e?.supportAction??'');
    _startTime=TimeOfDay(hour:e?.startHour??22,minute:e?.startMinute??0);
    _endTime=TimeOfDay(hour:e?.endHour??23,minute:e?.endMinute??0);
    _enabled=e?.isEnabled??true;
    _warningSigns=[...?e?.earlyWarningSigns];
    _triggers=[...?e?.triggers];
  }
  @override
  void dispose(){_labelController.dispose();_preparationController.dispose();_supportController.dispose();super.dispose();}

  String _format(TimeOfDay value)=>MaterialLocalizations.of(context).formatTimeOfDay(value,alwaysUse24HourFormat:widget.use24HourFormat);
  Future<void> _pick(bool start) async {
    final value=await showTimePicker(context:context,initialTime:start?_startTime:_endTime,initialEntryMode:TimePickerEntryMode.dial);
    if(value!=null&&mounted)setState((){if(start){_startTime=value;}else{_endTime=value;}_error=null;});
  }
  void _save(){
    final label=_labelController.text.trim();
    final preparation=_preparationController.text.trim();
    final support=_supportController.text.trim();
    final same=_startTime.hour==_endTime.hour&&_startTime.minute==_endTime.minute;
    if(label.isEmpty||_warningSigns.isEmpty||preparation.isEmpty||same){
      setState(()=>_error=same?'Start and end times must be different.':'Add a label, at least one early warning sign, and a preparation action.');
      return;
    }
    Navigator.pop(context,RiskWindow(
      id:widget.existing?.id??DateTime.now().microsecondsSinceEpoch.toString(),
      label:label,startHour:_startTime.hour,startMinute:_startTime.minute,
      endHour:_endTime.hour,endMinute:_endTime.minute,isEnabled:_enabled,
      earlyWarningSigns:_warningSigns,triggers:_triggers,
      preparationAction:preparation,supportAction:support,
    ));
  }
  @override
  Widget build(BuildContext context)=>SingleChildScrollView(
    padding:EdgeInsets.fromLTRB(AppSpacing.lg,AppSpacing.lg,AppSpacing.lg,MediaQuery.of(context).viewInsets.bottom+AppSpacing.lg),
    child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(widget.existing==null?'Add Risk Window':'Edit Risk Window',style:AppTypography.title),
      const SizedBox(height:AppSpacing.xs),
      const Text('Start with the signs that tell you pressure is rising. Then set the clock and decide what you will do.',style:AppTypography.muted),
      const SizedBox(height:AppSpacing.md),
      TagChipInput(label:'Early warning signs',hint:'Type a sign, then comma or Add',values:_warningSigns,onChanged:(value)=>setState(()=>_warningSigns=value)),
      const SizedBox(height:AppSpacing.md),
      TagChipInput(label:'Triggers or context',hint:'Stress, loneliness, conflict…',values:_triggers,onChanged:(value)=>setState(()=>_triggers=value)),
      const SizedBox(height:AppSpacing.md),
      TextField(controller:_labelController,decoration:const InputDecoration(labelText:'Window label',hintText:'Late night',border:OutlineInputBorder())),
      const SizedBox(height:AppSpacing.md),
      Row(children:[
        Expanded(child:OutlinedButton.icon(onPressed:()=>_pick(true),icon:const Icon(Icons.schedule),label:Text('Start ${_format(_startTime)}'))),
        const SizedBox(width:AppSpacing.sm),
        Expanded(child:OutlinedButton.icon(onPressed:()=>_pick(false),icon:const Icon(Icons.schedule),label:Text('End ${_format(_endTime)}'))),
      ]),
      const SizedBox(height:AppSpacing.md),
      TextField(controller:_preparationController,minLines:2,maxLines:4,decoration:const InputDecoration(labelText:'Preparation action',hintText:'What will you do before the window begins?',border:OutlineInputBorder())),
      const SizedBox(height:AppSpacing.md),
      TextField(controller:_supportController,minLines:2,maxLines:4,decoration:const InputDecoration(labelText:'Support action (optional)',hintText:'Who will you contact or where will you go?',border:OutlineInputBorder())),
      SwitchListTile.adaptive(contentPadding:EdgeInsets.zero,value:_enabled,onChanged:(value)=>setState(()=>_enabled=value),title:const Text('Reminder enabled')),
      if(_error!=null)Padding(padding:const EdgeInsets.only(bottom:AppSpacing.sm),child:Text(_error!,style:TextStyle(color:Theme.of(context).colorScheme.error))),
      PrimaryButton(label:widget.existing==null?'Save Risk Window':'Update Risk Window',icon:Icons.schedule_outlined,onPressed:_save),
    ]),
  );
}
