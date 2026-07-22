import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../reasons/data/my_reasons_repository.dart';
import '../../../reasons/domain/my_reasons_state.dart';
import '../../../reasons/presentation/my_reasons_screen.dart';

class MyReasonsHomeCard extends StatefulWidget {
  const MyReasonsHomeCard({super.key});

  @override
  State<MyReasonsHomeCard> createState() => _MyReasonsHomeCardState();
}

class _MyReasonsHomeCardState extends State<MyReasonsHomeCard> {
  final MyReasonsRepository _repository = MyReasonsRepository();
  MyReasonsState? _state;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final state = await _repository.getState();
    if (mounted) {
      setState(() => _state = state);
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
    final state = _state;
    final media = state?.primaryMedia;
    final file = media == null ? null : File(media.path);
    final hasPhoto = file != null && file.existsSync();
    final reason = state?.primaryReason.trim() ?? '';

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Reasons', style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          if (hasPhoto)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                file,
                width: double.infinity,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
          if (hasPhoto) const SizedBox(height: AppSpacing.sm),
          Text(
            reason.isEmpty ? 'Add one reason that matters to you.' : reason,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: reason.isEmpty ? AppTypography.muted : AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _open,
              icon: const Icon(Icons.favorite_outline),
              label: Text(reason.isEmpty ? 'Add My Reason' : 'View My Reasons'),
            ),
          ),
        ],
      ),
    );
  }
}
