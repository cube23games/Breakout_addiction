import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/widgets/info_card.dart';

class _AiToolDefinition {
  final String title;
  final String description;
  final String prompt;
  final IconData icon;

  const _AiToolDefinition({
    required this.title,
    required this.description,
    required this.prompt,
    required this.icon,
  });
}

class AiToolsScreen extends StatelessWidget {
  const AiToolsScreen({super.key});

  static const List<_AiToolDefinition> _tools = [
    _AiToolDefinition(
      title: 'Recovery Plan Helper',
      description:
          'Draft or strengthen first actions, warning signs, support steps, and fallback plans.',
      prompt:
          'Help me strengthen my recovery plan. Ask only for non-identifying details, separate observations from suggestions, and help me choose one first action, one backup action, one grounding action, and one human-support step.',
      icon: Icons.health_and_safety_outlined,
    ),
    _AiToolDefinition(
      title: 'Pattern Reflection',
      description:
          'Explore a trigger, warning sign, urge, victory, or slip without turning reflection into shame.',
      prompt:
          'Guide me through a brief, non-shaming recovery reflection. Help me identify the earliest warning sign, what relief I was seeking, what interrupted or failed to interrupt the pattern, and one practical change for next time.',
      icon: Icons.psychology_alt_outlined,
    ),
    _AiToolDefinition(
      title: 'Weekly Recovery Review',
      description:
          'Turn the week into progress highlights, emerging risks, and one next focus.',
      prompt:
          'Help me create a weekly recovery review. Ask for only the minimum non-identifying information needed, then summarize wins, repeated pressure, emerging risk, and one realistic focus for the next seven days.',
      icon: Icons.calendar_view_week_outlined,
    ),
    _AiToolDefinition(
      title: 'Accountability Draft',
      description:
          'Prepare an honest message that the user reviews before sending to a trusted person.',
      prompt:
          'Help me draft a concise accountability check-in. Do not send anything. Keep it honest, non-graphic, and focused on what happened, what I learned, what I am changing, and what support I am asking for.',
      icon: Icons.forum_outlined,
    ),
    _AiToolDefinition(
      title: 'High-Risk Window Prep',
      description:
          'Build a practical plan before a vulnerable time begins.',
      prompt:
          'Help me prepare for a high-risk window. Ask about time, setting, pressure, privacy, first action, backup action, and human support without requesting identifying information.',
      icon: Icons.schedule_outlined,
    ),
    _AiToolDefinition(
      title: 'Rescue Personalizer',
      description:
          'Choose a tailored next action while the immediate Rescue tools remain free.',
      prompt:
          'I am using Rescue now. Give me one brief grounding step, one environment change, and one human-support option. Do not ask for identifying details and keep the answer short enough to use during an urge.',
      icon: Icons.sos_outlined,
    ),
    _AiToolDefinition(
      title: 'Personalized Encouragement',
      description:
          'Create practical encouragement for the current pressure without inventing quotations.',
      prompt:
          'Give me brief recovery encouragement for what I am facing. Do not invent or attribute a quote. Keep it practical, non-shaming, and end with one next action.',
      icon: Icons.favorite_outline,
    ),
    _AiToolDefinition(
      title: 'Optional Faith Reflection',
      description:
          'Use a Christian recovery lens only when the user deliberately chooses it.',
      prompt:
          'Offer an optional Christian recovery reflection focused on honesty, mercy, responsibility, and one concrete next step. Do not claim certainty about God, do not replace professional or emergency help, and do not invent scripture quotations.',
      icon: Icons.auto_awesome_outlined,
    ),
    _AiToolDefinition(
      title: 'Report Interpretation Helper',
      description:
          'Explore a recovery report the user chooses to summarize without treating AI as the source of truth.',
      prompt:
          'Help me interpret a recovery report I will summarize in non-identifying terms. Separate the facts I provide from your suggestions, identify no more than three patterns, and suggest one realistic next focus.',
      icon: Icons.summarize_outlined,
    ),
  ];

  void _openCoach(BuildContext context, String prompt) {
    Navigator.pushNamed(
      context,
      RouteNames.aiChat,
      arguments: prompt,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Personalization Tools')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'Start with a focused recovery task.',
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Each tool opens the secure AI coach with a reviewable starter prompt. Keep names, contact information, and other identifying details out of AI chat.',
            style: AppTypography.muted,
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final tool in _tools) ...[
            InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(tool.icon, size: 30),
                  const SizedBox(height: AppSpacing.sm),
                  Text(tool.title, style: AppTypography.section),
                  const SizedBox(height: AppSpacing.sm),
                  Text(tool.description, style: AppTypography.muted),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openCoach(context, tool.prompt),
                      icon: const Icon(Icons.auto_awesome_outlined),
                      label: const Text('Open in AI Coach'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          const InfoCard(
            child: Text(
              'AI support is optional, subject to fair-use limits, and never replaces immediate Rescue, a trusted person, professional care, or emergency help.',
              style: AppTypography.muted,
            ),
          ),
        ],
      ),
    );
  }
}
