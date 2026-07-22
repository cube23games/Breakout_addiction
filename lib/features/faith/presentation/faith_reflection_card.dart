import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/info_card.dart';
import '../data/public_domain_verse_repository.dart';
import '../domain/public_domain_verse.dart';

class FaithReflectionCard extends StatelessWidget {
  const FaithReflectionCard({required this.dayNumber,super.key});
  final int dayNumber;
  @override Widget build(BuildContext context){
    final verse=PublicDomainVerseRepository().forDay(dayNumber);
    return InfoCard(
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[const Icon(Icons.auto_stories_outlined),const SizedBox(width:8),Expanded(child:Text('Optional faith reflection',style:AppTypography.section))]),
        const SizedBox(height:AppSpacing.sm),
        Text('“${verse.text}”',style:AppTypography.body),
        const SizedBox(height:AppSpacing.sm),
        Text('${verse.reference} • ${PublicDomainVerse.translation}',style:AppTypography.muted),
        const SizedBox(height:AppSpacing.sm),
        const Text('Reflection: What honest, practical action would living this verse look like today?',style:AppTypography.muted),
      ]),
    );
  }
}
