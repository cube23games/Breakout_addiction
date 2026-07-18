import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/widgets/info_card.dart';
import '../data/private_pattern_repository.dart';
import '../domain/private_pattern_summary.dart';

class PrivatePatternScreen extends StatefulWidget {
  const PrivatePatternScreen({super.key});

  @override
  State<PrivatePatternScreen> createState() =>
      _PrivatePatternScreenState();
}

class _PrivatePatternScreenState extends State<PrivatePatternScreen> {
  final PrivatePatternRepository _repository = PrivatePatternRepository();
  PrivatePatternSummary? _summary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final summary = await _repository.build();
    if (!mounted) {
      return;
    }
    setState(() {
      _summary = summary;
      _loading = false;
    });
  }

  Widget _patternCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return InfoCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.section),
                const SizedBox(height: AppSpacing.sm),
                Text(value, style: AppTypography.body),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _summary == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Private Pattern Intelligence')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final summary = _summary!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Private Pattern Intelligence'),
        actions: [
          IconButton(
            onPressed: _load,
            tooltip: 'Refresh patterns',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('See the pattern before it becomes a verdict.',
              style: AppTypography.title),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'These observations are calculated on this device from your own logs. They describe recorded patterns, not certainty about what will happen next.',
            style: AppTypography.muted,
          ),
          const SizedBox(height: AppSpacing.lg),
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weekly Private Summary', style: AppTypography.section),
                const SizedBox(height: AppSpacing.sm),
                Text(summary.weeklySummary, style: AppTypography.body),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  summary.currentWeekDirection,
                  style: AppTypography.muted,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${summary.evidenceCount} local records contributed to this view.',
                  style: AppTypography.muted,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _patternCard(
            title: 'Peak Risk Day',
            value: summary.peakDay,
            icon: Icons.calendar_today_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          _patternCard(
            title: 'Peak Risk Time',
            value: summary.peakTime,
            icon: Icons.schedule_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          _patternCard(
            title: 'Most Repeated Trigger',
            value: summary.topTrigger,
            icon: Icons.bolt_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          _patternCard(
            title: 'Trigger Combination',
            value: summary.triggerPair,
            icon: Icons.join_inner_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          _patternCard(
            title: 'Earlier Signal Before Slips',
            value: summary.preSlipSignal,
            icon: Icons.warning_amber_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          _patternCard(
            title: 'What Has Helped',
            value: summary.effectiveInterruption,
            icon: Icons.task_alt_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, RouteNames.logHub),
              icon: const Icon(Icons.edit_note_outlined),
              label: const Text('Add More Useful Detail'),
            ),
          ),
        ],
      ),
    );
  }
}
