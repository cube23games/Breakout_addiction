import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../reasons/data/my_reasons_repository.dart';
import '../../../reasons/presentation/my_reasons_screen.dart';

class ReasonsToStopCard extends StatefulWidget {
  const ReasonsToStopCard({super.key});

  @override
  State<ReasonsToStopCard> createState() => _ReasonsToStopCardState();
}

class _ReasonsToStopCardState extends State<ReasonsToStopCard> {
  final MyReasonsRepository _repository = MyReasonsRepository();
  String _reason = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final state = await _repository.getState();
    if (mounted) {
      setState(() => _reason = state.primaryReason);
    }
  }

  Future<void> _open() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyReasonsScreen()),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Remember why you started', style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _reason.trim().isEmpty
                ? 'Add one personal reason to reach during a difficult moment.'
                : _reason,
            style: _reason.trim().isEmpty
                ? AppTypography.muted
                : AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _open,
              icon: const Icon(Icons.favorite_outline),
              label: const Text('View My Reasons'),
            ),
          ),
        ],
      ),
    );
  }
}
