import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/widgets/info_card.dart';
import '../../premium/data/premium_access_repository.dart';
import '../../premium/domain/premium_status.dart';
import '../data/lesson_repository.dart';
import '../domain/lesson_track.dart';
import 'lesson_detail_screen.dart';

class EducateScreen extends StatelessWidget {
  const EducateScreen({super.key});
  @override Widget build(BuildContext context){
    final tracks=LessonRepository().getTracks();
    return Scaffold(appBar:AppBar(title:const Text('Learn')),body:FutureBuilder<PremiumStatus>(
      future:PremiumAccessRepository().getStatus(),
      builder:(context,snapshot){final status=snapshot.data??PremiumStatus.defaults();return ListView(padding:const EdgeInsets.all(AppSpacing.lg),children:[
        Text('Learn what is happening.',style:AppTypography.title),const SizedBox(height:AppSpacing.xs),
        const Text('Choose one topic. Lessons stay collapsed until you open the track.',style:AppTypography.muted),
        const SizedBox(height:AppSpacing.lg),
        for(final track in tracks)...[
          _TrackSummary(track:track,unlocked:!track.premiumOnly||status.hasPremium),
          const SizedBox(height:AppSpacing.md),
        ],
        if(!status.hasPremium)InfoCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('Educate Me Plus',style:AppTypography.section),const SizedBox(height:AppSpacing.sm),
          const Text('Plus adds deeper lessons about warning signs, risk windows, rebuilding after slips, and stress.',style:AppTypography.muted),
          const SizedBox(height:AppSpacing.md),OutlinedButton.icon(onPressed:()=>Navigator.pushNamed(context,RouteNames.premium),icon:const Icon(Icons.workspace_premium_outlined),label:const Text('Explore Plus')),
        ])),
      ]);},
    ));
  }
}
class _TrackSummary extends StatelessWidget{
  const _TrackSummary({required this.track,required this.unlocked}); final LessonTrack track; final bool unlocked;
  @override Widget build(BuildContext context)=>InfoCard(child:ExpansionTile(
    tilePadding:EdgeInsets.zero,childrenPadding:EdgeInsets.zero,
    leading:Icon(unlocked?Icons.menu_book_outlined:Icons.lock_outline),
    title:Text(track.title,style:AppTypography.section),subtitle:Text(track.subtitle,style:AppTypography.muted),
    children:unlocked?[for(final lesson in track.lessons)ListTile(contentPadding:EdgeInsets.zero,title:Text(lesson.title),subtitle:Text(lesson.summary,maxLines:2,overflow:TextOverflow.ellipsis),trailing:const Icon(Icons.chevron_right),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>LessonDetailScreen(lesson:lesson))))]:[
      const Padding(padding:EdgeInsets.only(bottom:12),child:Text('This track is included with Breakout Plus.')),
    ],
  ));
}
