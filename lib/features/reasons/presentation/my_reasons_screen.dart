import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../rescue/data/reasons_to_stop_repository.dart';
import '../data/my_reasons_repository.dart';
import '../domain/my_reasons_state.dart';
import '../domain/reason_media_item.dart';

class MyReasonsScreen extends StatefulWidget {
  const MyReasonsScreen({super.key});

  @override
  State<MyReasonsScreen> createState() => _MyReasonsScreenState();
}

class _MyReasonsScreenState extends State<MyReasonsScreen> {
  final MyReasonsRepository _repository = MyReasonsRepository();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _reasonController = TextEditingController();

  MyReasonsState _state = MyReasonsState.empty();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final state = await _repository.getState();
    if (!mounted) {
      return;
    }
    _reasonController.text = state.primaryReason;
    setState(() {
      _state = state;
      _loading = false;
    });
  }

  Future<void> _choosePhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 2200,
    );
    if (picked == null) {
      return;
    }

    final imported = await _repository.importPhoto(picked);
    final previous = _state.media.isEmpty ? null : _state.media.first;
    if (previous != null) {
      await _repository.deleteMedia(previous);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _state = _state.copyWith(
        media: <ReasonMediaItem>[imported],
        primaryMediaId: imported.id,
      );
    });
  }

  Future<void> _removePhoto() async {
    if (_state.media.isEmpty) {
      return;
    }
    await _repository.deleteMedia(_state.media.first);
    if (!mounted) {
      return;
    }
    setState(() {
      _state = _state.copyWith(
        media: const <ReasonMediaItem>[],
        clearPrimaryMediaId: true,
      );
    });
  }

  Future<void> _save() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add one personal reason before saving.')),
      );
      return;
    }
    setState(() => _saving = true);
    final updated = _state.copyWith(reasons: <String>[reason]);
    await _repository.saveState(updated);
    await ReasonsToStopRepository().saveReasons(<String>[
      reason,
      ReasonsToStopRepository.otherReason,
    ]);
    if (!mounted) {
      return;
    }
    setState(() {
      _state = updated;
      _saving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your reason was saved privately.')),
    );
  }

  Widget _photoCard() {
    final media = _state.primaryMedia;
    final file = media == null ? null : File(media.path);
    final exists = file != null && file.existsSync();
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your photo', style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          if (exists)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                file,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(
                  height: 120,
                  child: Center(child: Text('Photo could not be displayed.')),
                ),
              ),
            )
          else
            const Text(
              'Standard includes one private photo. Choose something that reminds you why recovery matters.',
              style: AppTypography.muted,
            ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _choosePhoto,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(exists ? 'Replace Photo' : 'Choose Photo'),
            ),
          ),
          if (exists) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _removePhoto,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove Photo'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        appBar: AppBar(title: Text('My Reasons')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Reasons')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Remember why you started.', style: AppTypography.title),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Your reason and photo stay on this device unless you choose to share them.',
            style: AppTypography.muted,
          ),
          const SizedBox(height: AppSpacing.lg),
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your reason', style: AppTypography.section),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _reasonController,
                  minLines: 3,
                  maxLines: 6,
                  maxLength: 300,
                  decoration: const InputDecoration(
                    hintText: 'Example: I want to be fully present with the people I love.',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _photoCard(),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: _saving ? 'Saving...' : 'Save My Reason',
            icon: Icons.favorite_outline,
            onPressed: _saving ? () {} : _save,
          ),
        ],
      ),
    );
  }
}
