import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/recovery_event_repository.dart';
import '../domain/recovery_event_entry.dart';

class RecoveryEventLogScreen extends StatefulWidget {
  const RecoveryEventLogScreen({
    super.key,
    this.initialEntry,
  });

  final RecoveryEventEntry? initialEntry;

  @override
  State<RecoveryEventLogScreen> createState() => _RecoveryEventLogScreenState();
}

class _RecoveryEventLogScreenState extends State<RecoveryEventLogScreen> {
  static const String _otherReason = 'Other';

  static const List<String> _reasonOptions = <String>[
    'Stress',
    'Loneliness',
    'Boredom',
    'Anger',
    'Late night',
    'Social media',
    _otherReason,
  ];

  final RecoveryEventRepository _repository = RecoveryEventRepository();

  late final TextEditingController _contextController;
  late final TextEditingController _noteController;
  late final TextEditingController _customReasonController;

  RecoveryEventType _type = RecoveryEventType.urge;
  double _intensity = 5;
  String _reason = 'Stress';
  DateTime? _originalTimestamp;
  bool _saving = false;

  bool get _isEditing => widget.initialEntry != null;

  @override
  void initState() {
    super.initState();

    final entry = widget.initialEntry;
    _contextController = TextEditingController(text: entry?.context ?? '');
    _noteController = TextEditingController(text: entry?.note ?? '');
    _customReasonController = TextEditingController();

    if (entry != null) {
      _originalTimestamp = entry.timestamp;
      _type = entry.type;
      _intensity = entry.intensity.toDouble();

      final cleanedReason = entry.reason.trim();
      if (cleanedReason.isNotEmpty && _reasonOptions.contains(cleanedReason)) {
        _reason = cleanedReason;
      } else if (cleanedReason.isNotEmpty) {
        _reason = _otherReason;
        _customReasonController.text = cleanedReason;
      } else {
        _reason = _otherReason;
      }
    }
  }

  @override
  void dispose() {
    _contextController.dispose();
    _noteController.dispose();
    _customReasonController.dispose();
    super.dispose();
  }

  String _effectiveReason() {
    if (_reason != _otherReason) {
      return _reason;
    }

    final custom = _customReasonController.text.trim();
    return custom.isEmpty ? _otherReason : custom;
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final entry = RecoveryEventEntry(
      timestamp: _isEditing ? _originalTimestamp ?? DateTime.now() : DateTime.now(),
      type: _type,
      intensity: _intensity.round(),
      reason: _effectiveReason(),
      trigger: _contextController.text.trim(),
      context: _contextController.text.trim(),
      note: _noteController.text.trim(),
    );

    if (_isEditing && _originalTimestamp != null) {
      await _repository.updateEntry(
        originalTimestamp: _originalTimestamp!,
        entry: entry,
      );
    } else {
      await _repository.saveEntry(entry);
    }

    if (!mounted) {
      return;
    }

    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF13212C),
        content: Text(
          _isEditing
              ? 'Updated ${entry.type.label.toLowerCase()} log.'
              : 'Saved ${entry.type.label.toLowerCase()} log.',
        ),
      ),
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteNames.logHub,
      (route) => route.settings.name == RouteNames.home || route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final actionLabel = _isEditing ? 'Update Recovery Event' : 'Save Recovery Event';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Recovery Event' : 'Recovery Event Log'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              _isEditing ? 'Correct the log honestly.' : 'Capture the moment honestly.',
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Urges, slips, and wins all teach you something if you name them clearly.',
              style: AppTypography.muted,
            ),
            const SizedBox(height: AppSpacing.lg),
            InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Event Type', style: AppTypography.section),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<RecoveryEventType>(
                    initialValue: _type,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: RecoveryEventType.values
                        .map(
                          (item) => DropdownMenuItem<RecoveryEventType>(
                            value: item,
                            child: Text(item.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _type = value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reason / Trigger', style: AppTypography.section),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: _reason,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: _reasonOptions
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _reason = value);
                    },
                  ),
                  if (_reason == _otherReason) ...[
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _customReasonController,
                      minLines: 1,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Name your reason in your own words...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Intensity', style: AppTypography.section),
                  const SizedBox(height: AppSpacing.sm),
                  Text('${_intensity.round()} / 10', style: AppTypography.body),
                  Slider(
                    value: _intensity,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: _intensity.round().toString(),
                    onChanged: (value) {
                      setState(() => _intensity = value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trigger', style: AppTypography.section),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _contextController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Example: alone late at night, stressed after work, bored on couch...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notes', style: AppTypography.section),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _noteController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'What happened? What did you notice? What helped or failed?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: _saving ? 'Saving...' : actionLabel,
              icon: Icons.save_outlined,
              onPressed: _saving ? () {} : _save,
            ),
            if (_isEditing) ...[
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_outlined),
                  label: const Text('Cancel Edit'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
