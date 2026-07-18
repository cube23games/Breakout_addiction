import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/info_card.dart';
import '../data/premium_trend_repository.dart';
import '../domain/premium_trend_summary.dart';

class PremiumInsightsScreen extends StatefulWidget {
  const PremiumInsightsScreen({super.key});

  @override
  State<PremiumInsightsScreen> createState() =>
      _PremiumInsightsScreenState();
}

class _PremiumInsightsScreenState extends State<PremiumInsightsScreen> {
  final PremiumTrendRepository _repository = PremiumTrendRepository();
  late Future<PremiumTrendSummary> _summary;

  @override
  void initState() {
    super.initState();
    _summary = _repository.buildSummary();
  }

  void _refresh() {
    setState(() => _summary = _repository.buildSummary());
  }

  Widget _metric(String label, Object value) {
    return Expanded(
      child: Column(
        children: [
          Text('$value', style: AppTypography.title),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.muted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _periodCard({
    required String title,
    required int urges,
    required int victories,
    required int slips,
  }) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.section),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _metric('Urges', urges),
              _metric('Victories', victories),
              _metric('Slips', slips),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Insights'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh insights',
          ),
        ],
      ),
      body: FutureBuilder<PremiumTrendSummary>(
        future: _summary,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Advanced insights could not be prepared. Your logs and core recovery tools remain available.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final summary = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                'See the pattern beyond the latest moment.',
                style: AppTypography.title,
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'These private 30- and 90-day summaries are calculated on your device from your own logs.',
                style: AppTypography.muted,
              ),
              const SizedBox(height: AppSpacing.lg),
              _periodCard(
                title: 'Last 30 days',
                urges: summary.urges30,
                victories: summary.victories30,
                slips: summary.slips30,
              ),
              const SizedBox(height: AppSpacing.md),
              _periodCard(
                title: 'Last 90 days',
                urges: summary.urges90,
                victories: summary.victories90,
                slips: summary.slips90,
              ),
              const SizedBox(height: AppSpacing.md),
              InfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Context depth', style: AppTypography.section),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Mood logs, 30 days: ${summary.moodLogs30}'),
                    Text('Cycle-stage logs, 30 days: ${summary.stageLogs30}'),
                    Text(
                      'Average combined pressure: ${summary.averagePressure30.toStringAsFixed(1)} / 30',
                    ),
                    Text('Most repeated trigger: ${summary.topTrigger30}'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              InfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Direction', style: AppTypography.section),
                    const SizedBox(height: AppSpacing.sm),
                    Text(summary.directionLine, style: AppTypography.muted),
                    const SizedBox(height: AppSpacing.md),
                    Text('Next focus', style: AppTypography.section),
                    const SizedBox(height: 6),
                    Text(summary.nextFocus),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
