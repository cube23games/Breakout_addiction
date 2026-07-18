import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/info_card.dart';
import '../data/premium_local_guidance_repository.dart';
import '../domain/local_guidance_item.dart';

class PremiumLocalGuidanceScreen extends StatefulWidget {
  const PremiumLocalGuidanceScreen({super.key});

  @override
  State<PremiumLocalGuidanceScreen> createState() =>
      _PremiumLocalGuidanceScreenState();
}

class _PremiumLocalGuidanceScreenState
    extends State<PremiumLocalGuidanceScreen> {
  final PremiumLocalGuidanceRepository _repository =
      PremiumLocalGuidanceRepository();

  late Future<List<LocalGuidanceItem>> _guidance;

  @override
  void initState() {
    super.initState();
    _guidance = _repository.buildGuidance();
  }

  void _refresh() {
    setState(() {
      _guidance = _repository.buildGuidance();
    });
  }

  Widget _itemCard(LocalGuidanceItem item) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(item.title, style: AppTypography.section),
              ),
              if (item.faithSensitive)
                const Chip(label: Text('Optional faith')),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(item.detail, style: AppTypography.muted),
          const SizedBox(height: AppSpacing.md),
          Text('Try next', style: AppTypography.section),
          const SizedBox(height: 6),
          Text(item.nextAction, style: AppTypography.body),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Recovery Guidance'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh from current logs',
          ),
        ],
      ),
      body: FutureBuilder<List<LocalGuidanceItem>>(
        future: _guidance,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Local guidance could not be prepared. Your core Rescue and recovery tools are still available.',
                  style: AppTypography.muted,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final items = snapshot.data ?? const <LocalGuidanceItem>[];
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                'Private guidance from your on-device patterns.',
                style: AppTypography.title,
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'This guidance is selected locally from recovery data already stored on your device. It does not call an AI service.',
                style: AppTypography.muted,
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final item in items) ...[
                _itemCard(item),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          );
        },
      ),
    );
  }
}
