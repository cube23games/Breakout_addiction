import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../premium/data/premium_access_repository.dart';
import '../../premium/domain/premium_status.dart';
import '../../rescue/data/reasons_to_stop_repository.dart';
import '../data/my_reasons_repository.dart';
import '../domain/my_reasons_state.dart';
import '../domain/reason_media_item.dart';
import 'reason_media_viewer.dart';

class MyReasonsScreen extends StatefulWidget {
  const MyReasonsScreen({super.key});
  @override
  State<MyReasonsScreen> createState() => _MyReasonsScreenState();
}

class _MyReasonsScreenState extends State<MyReasonsScreen> {
  final MyReasonsRepository _repository = MyReasonsRepository();
  final PremiumAccessRepository _premiumRepository = PremiumAccessRepository();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _reasonController = TextEditingController();
  MyReasonsState _state = MyReasonsState.empty();
  PremiumStatus _premium = PremiumStatus.defaults();
  bool _loading = true;
  bool _saving = false;

  bool get _hasPlus => _premium.hasPremium;
  int get _maxMedia => _hasPlus ? 10 : 1;

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _reasonController.dispose(); super.dispose(); }

  Future<void> _load() async {
    final state = await _repository.getState();
    final premium = await _premiumRepository.getStatus();
    if (!mounted) return;
    _reasonController.text = state.primaryReason;
    setState(() { _state = state; _premium = premium; _loading = false; });
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _choosePhoto() async {
    if (_state.media.length >= _maxMedia) {
      _message(_hasPlus ? 'You can save up to 10 photos or videos.' : 'Standard includes one private photo.');
      return;
    }
    final picked = await _picker.pickImage(
      source: ImageSource.gallery, imageQuality: 90, maxWidth: 2200,
    );
    if (picked == null) return;
    final imported = await _repository.importPhoto(picked);
    if (!mounted) return;
    setState(() => _state = _state.copyWith(
      media: <ReasonMediaItem>[..._state.media, imported],
      primaryMediaId: _state.primaryMediaId ?? imported.id,
    ));
  }

  Future<void> _chooseVideo() async {
    if (!_hasPlus) { _message('Short video is included with Breakout Plus.'); return; }
    if (_state.media.length >= _maxMedia) { _message('You can save up to 10 photos or videos.'); return; }
    if (_state.media.any((item) => item.type == ReasonMediaType.video)) {
      _message('You can save one video in My Reasons.'); return;
    }
    final picked = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 60),
    );
    if (picked == null) return;
    final checker = VideoPlayerController.file(File(picked.path));
    try {
      await checker.initialize();
      if (checker.value.duration > const Duration(seconds: 60)) {
        _message('Choose a video that is 60 seconds or shorter.');
        return;
      }
    } finally {
      await checker.dispose();
    }
    final imported = await _repository.importVideo(picked);
    if (!mounted) return;
    setState(() => _state = _state.copyWith(
      media: <ReasonMediaItem>[..._state.media, imported],
      primaryMediaId: _state.primaryMediaId ?? imported.id,
    ));
  }

  Future<void> _removeMedia(ReasonMediaItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove this item?'),
        content: const Text('The private copy stored by Breakout will be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed != true) return;
    await _repository.deleteMedia(item);
    final remaining = _state.media.where((candidate) => candidate.id != item.id).toList();
    if (!mounted) return;
    setState(() => _state = _state.copyWith(
      media: remaining,
      primaryMediaId: remaining.isEmpty ? null : (item.id == _state.primaryMediaId ? remaining.first.id : _state.primaryMediaId),
      clearPrimaryMediaId: remaining.isEmpty,
    ));
  }

  Future<void> _editCaption(ReasonMediaItem item) async {
    final controller = TextEditingController(text: item.caption);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Media caption'),
        content: TextField(controller: controller, maxLength: 160, minLines: 2, maxLines: 4),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    if (value == null || !mounted) return;
    setState(() => _state = _state.copyWith(
      media: _state.media.map((candidate) => candidate.id == item.id ? candidate.copyWith(caption: value) : candidate).toList(),
    ));
  }

  Future<void> _addReason() async {
    if (!_hasPlus) { _message('Standard includes one written reason.'); return; }
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add another reason'),
        content: TextField(controller: controller, maxLength: 300, minLines: 3, maxLines: 6),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Add')),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value.isEmpty || !mounted) return;
    setState(() => _state = _state.copyWith(reasons: <String>[..._state.reasons, value]));
  }

  Future<void> _save() async {
    final primary = _reasonController.text.trim();
    if (primary.isEmpty) { _message('Add one personal reason before saving.'); return; }
    setState(() => _saving = true);
    final extra = _hasPlus ? _state.reasons.skip(1).where((item) => item.trim().isNotEmpty).toList() : <String>[];
    final media = _hasPlus ? _state.media.take(10).toList() : _state.media.where((item) => item.type == ReasonMediaType.photo).take(1).toList();
    final updated = _state.copyWith(
      reasons: <String>[primary, ...extra],
      media: media,
      primaryMediaId: media.any((item) => item.id == _state.primaryMediaId)
          ? _state.primaryMediaId
          : (media.isEmpty ? null : media.first.id),
      clearPrimaryMediaId: media.isEmpty,
    );
    await _repository.saveState(updated);
    await ReasonsToStopRepository().saveReasons(<String>[
      ...updated.reasons,
      ReasonsToStopRepository.otherReason,
    ]);
    if (!mounted) return;
    setState(() { _state = updated; _saving = false; });
    _message('My Reasons saved privately on this device.');
  }

  Widget _mediaTile(ReasonMediaItem item, int index) {
    final file = File(item.path);
    final isVideo = item.type == ReasonMediaType.video;
    return Card(
      key: ValueKey(item.id),
      child: ListTile(
        leading: SizedBox(
          width: 56,
          height: 56,
          child: isVideo
              ? const ColoredBox(color: Colors.black12, child: Icon(Icons.play_circle_outline))
              : ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(file, fit: BoxFit.cover)),
        ),
        title: Text(item.caption.isEmpty ? (isVideo ? 'Short video' : 'Photo ${index + 1}') : item.caption, maxLines: 2),
        subtitle: Text(item.id == _state.primaryMediaId ? 'Home cover' : 'Tap to view'),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReasonMediaViewer(item: item))),
        trailing: PopupMenuButton<String>(
          onSelected: (action) {
            if (action == 'cover') setState(() => _state = _state.copyWith(primaryMediaId: item.id));
            if (action == 'caption') _editCaption(item);
            if (action == 'remove') _removeMedia(item);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'cover', child: Text('Use as cover')),
            PopupMenuItem(value: 'caption', child: Text('Edit caption')),
            PopupMenuItem(value: 'remove', child: Text('Remove')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(appBar: AppBar(title: Text('My Reasons')), body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('My Reasons')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Remember why you started.', style: AppTypography.title),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _hasPlus
                ? 'Plus supports multiple reasons, up to 10 photos or videos, and one video up to 60 seconds.'
                : 'Standard includes one private photo. You can also save one written reason.',
            style: AppTypography.muted,
          ),
          const SizedBox(height: AppSpacing.lg),
          InfoCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Primary reason', style: AppTypography.section),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _reasonController,
                minLines: 3, maxLines: 6, maxLength: 300,
                decoration: const InputDecoration(hintText: 'Why does recovery matter to you?', border: OutlineInputBorder()),
              ),
              if (_hasPlus) ...[
                const SizedBox(height: AppSpacing.sm),
                for (final reason in _state.reasons.skip(1))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.favorite_outline),
                    title: Text(reason),
                    trailing: IconButton(
                      tooltip: 'Remove reason',
                      onPressed: () => setState(() => _state = _state.copyWith(reasons: _state.reasons.where((item) => item != reason).toList())),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                TextButton.icon(onPressed: _addReason, icon: const Icon(Icons.add), label: const Text('Add another reason')),
              ],
            ]),
          ),
          const SizedBox(height: AppSpacing.md),
          InfoCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Photos and video', style: AppTypography.section),
              const SizedBox(height: AppSpacing.xs),
              Text('${_state.media.length} of $_maxMedia saved', style: AppTypography.muted),
              const SizedBox(height: AppSpacing.sm),
              if (_state.media.isEmpty)
                const Text('Nothing added yet. Media is copied into private app storage.', style: AppTypography.muted)
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _state.media.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final items = [..._state.media];
                      final item = items.removeAt(oldIndex);
                      items.insert(newIndex, item);
                      _state = _state.copyWith(media: items);
                    });
                  },
                  itemBuilder: (context, index) => _mediaTile(_state.media[index], index),
                ),
              const SizedBox(height: AppSpacing.sm),
              Row(children: [
                Expanded(child: OutlinedButton.icon(onPressed: _choosePhoto, icon: const Icon(Icons.add_photo_alternate_outlined), label: const Text('Add Photo'))),
                if (_hasPlus) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: OutlinedButton.icon(onPressed: _chooseVideo, icon: const Icon(Icons.video_library_outlined), label: const Text('Add Video'))),
                ],
              ]),
            ]),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: _saving ? 'Saving...' : 'Save My Reasons',
            icon: Icons.favorite_outline,
            onPressed: _saving ? () {} : _save,
          ),
        ],
      ),
    );
  }
}
