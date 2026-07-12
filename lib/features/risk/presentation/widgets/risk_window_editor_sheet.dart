import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/risk_window.dart';

class RiskWindowEditorSheet extends StatefulWidget {
  const RiskWindowEditorSheet({
    required this.use24HourFormat,
    this.existing,
    super.key,
  });

  final RiskWindow? existing;
  final bool use24HourFormat;

  @override
  State<RiskWindowEditorSheet> createState() =>
      _RiskWindowEditorSheetState();
}

class _RiskWindowEditorSheetState
    extends State<RiskWindowEditorSheet> {
  late final TextEditingController _labelController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _enabled;

  String? _labelError;
  String? _timeError;

  @override
  void initState() {
    super.initState();

    final existing = widget.existing;
    _labelController = TextEditingController(
      text: existing?.label ?? '',
    );
    _startTime = TimeOfDay(
      hour: existing?.startHour ?? 22,
      minute: existing?.startMinute ?? 0,
    );
    _endTime = TimeOfDay(
      hour: existing?.endHour ?? 23,
      minute: existing?.endMinute ?? 0,
    );
    _enabled = existing?.isEnabled ?? true;
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay value) {
    return MaterialLocalizations.of(context).formatTimeOfDay(
      value,
      alwaysUse24HourFormat: widget.use24HourFormat,
    );
  }

  Future<TimeOfDay?> _pickTime(
    TimeOfDay initialTime,
  ) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            alwaysUse24HourFormat:
                widget.use24HourFormat,
          ),
          child: child!,
        );
      },
    );
  }

  Future<void> _chooseStartTime() async {
    final selected = await _pickTime(_startTime);
    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _startTime = selected;
      _timeError = null;
    });
  }

  Future<void> _chooseEndTime() async {
    final selected = await _pickTime(_endTime);
    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _endTime = selected;
      _timeError = null;
    });
  }

  void _save() {
    final label = _labelController.text.trim();
    final startMinutes =
        (_startTime.hour * 60) + _startTime.minute;
    final endMinutes =
        (_endTime.hour * 60) + _endTime.minute;

    setState(() {
      _labelError =
          label.isEmpty ? 'Add a label for this risk window.' : null;
      _timeError = startMinutes == endMinutes
          ? 'Start and end times must be different.'
          : null;
    });

    if (_labelError != null || _timeError != null) {
      return;
    }

    Navigator.pop(
      context,
      RiskWindow(
        id: widget.existing?.id ??
            DateTime.now()
                .microsecondsSinceEpoch
                .toString(),
        label: label,
        startHour: _startTime.hour,
        startMinute: _startTime.minute,
        endHour: _endTime.hour,
        endMinute: _endTime.minute,
        isEnabled: _enabled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets =
        MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        viewInsets + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.existing == null
                ? 'Add Risk Window'
                : 'Edit Risk Window',
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Tap a time to open the clock face. The picker also has a keyboard option for typed entry.',
            style: AppTypography.muted,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _labelController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Label',
              hintText: 'Example: Late Night',
              errorText: _labelError,
            ),
            onChanged: (_) {
              if (_labelError != null) {
                setState(() => _labelError = null);
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _TimePickerField(
            label: 'Start time',
            value: _formatTime(_startTime),
            icon: Icons.schedule_outlined,
            onTap: _chooseStartTime,
          ),
          const SizedBox(height: AppSpacing.md),
          _TimePickerField(
            label: 'End time',
            value: _formatTime(_endTime),
            icon: Icons.schedule_outlined,
            onTap: _chooseEndTime,
          ),
          if (_timeError != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              _timeError!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _enabled,
            onChanged: (value) {
              setState(() => _enabled = value);
            },
            title: const Text('Enabled'),
            subtitle: const Text(
              'Use this window for live reminders.',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: widget.existing == null
                ? 'Save Risk Window'
                : 'Update Risk Window',
            icon: Icons.schedule_outlined,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  const _TimePickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label, $value',
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: Icon(icon),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
