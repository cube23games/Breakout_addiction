import 'package:flutter/material.dart';

import '../data/recovery_event_repository.dart';
import '../domain/recovery_event_entry.dart';
import '../domain/recovery_event_save_result.dart';
import 'recovery_event_form_controller.dart';
import 'widgets/recovery_event/recovery_event_form_content.dart';

class RecoveryEventLogScreen extends StatefulWidget {
  const RecoveryEventLogScreen({
    super.key,
    this.initialEntry,
  });

  final RecoveryEventEntry? initialEntry;

  @override
  State<RecoveryEventLogScreen> createState() =>
      _RecoveryEventLogScreenState();
}

class _RecoveryEventLogScreenState
    extends State<RecoveryEventLogScreen> {
  final RecoveryEventRepository _repository =
      RecoveryEventRepository();

  late final RecoveryEventFormController _form;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _form = RecoveryEventFormController(
      initialEntry: widget.initialEntry,
    );
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final entry = _form.buildEntry();

    if (_form.isEditing) {
      await _repository.updateEntry(
        originalTimestamp:
            widget.initialEntry!.timestamp,
        entry: entry,
      );
    } else {
      await _repository.saveEntry(entry);
    }

    if (!mounted) {
      return;
    }

    Navigator.pop(
      context,
      RecoveryEventSaveResult(
        entry: entry,
        updated: _form.isEditing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _form.isEditing
              ? 'Edit Recovery Event'
              : 'Recovery Event Log',
        ),
      ),
      body: SafeArea(
        child: RecoveryEventFormContent(
          controller: _form,
          saving: _saving,
          onTypeChanged: (value) {
            setState(() => _form.type = value);
          },
          onReasonChanged: (value) {
            setState(() => _form.reason = value);
          },
          onIntensityChanged: (value) {
            setState(() => _form.intensity = value);
          },
          onSave: _save,
          onCancel: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
