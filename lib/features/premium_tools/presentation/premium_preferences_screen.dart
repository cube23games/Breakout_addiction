import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/widgets/info_card.dart';
import '../data/premium_preferences_repository.dart';
import '../domain/premium_preferences.dart';

class PremiumPreferencesScreen extends StatefulWidget {
  const PremiumPreferencesScreen({super.key});

  @override
  State<PremiumPreferencesScreen> createState() =>
      _PremiumPreferencesScreenState();
}

class _PremiumPreferencesScreenState
    extends State<PremiumPreferencesScreen> {
  final PremiumPreferencesRepository _repository =
      PremiumPreferencesRepository();

  PremiumPreferences _preferences = PremiumPreferences.defaults();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final preferences = await _repository.getPreferences();
    if (!mounted) {
      return;
    }
    setState(() {
      _preferences = preferences;
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await _repository.save(_preferences);
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Premium preferences saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium Preferences')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(
                  'Choose how premium depth shows up.',
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'These preferences stay on this device and never alter core Rescue access.',
                  style: AppTypography.muted,
                ),
                const SizedBox(height: AppSpacing.lg),
                InfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Routine focus', style: AppTypography.section),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<PremiumRoutineFocus>(
                        initialValue: _preferences.routineFocus,
                        items: [
                          for (final value in PremiumRoutineFocus.values)
                            DropdownMenuItem(
                              value: value,
                              child: Text(value.label),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _preferences = _preferences.copyWith(
                                routineFocus: value,
                              );
                            });
                          }
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
                      Text('Recovery report', style: AppTypography.section),
                      const SizedBox(height: AppSpacing.sm),
                      SegmentedButton<PremiumReportDetail>(
                        segments: [
                          for (final value in PremiumReportDetail.values)
                            ButtonSegment(
                              value: value,
                              label: Text(value.label),
                            ),
                        ],
                        selected: {_preferences.reportDetail},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _preferences = _preferences.copyWith(
                              reportDetail: selection.first,
                            );
                          });
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
                      Text('Widget focus', style: AppTypography.section),
                      const SizedBox(height: AppSpacing.sm),
                      for (final value in PremiumWidgetFocus.values)
                        RadioListTile<PremiumWidgetFocus>(
                          contentPadding: EdgeInsets.zero,
                          value: value,
                          groupValue: _preferences.widgetFocus,
                          onChanged: (selected) {
                            if (selected != null) {
                              setState(() {
                                _preferences = _preferences.copyWith(
                                  widgetFocus: selected,
                                );
                              });
                            }
                          },
                          title: Text(value.label),
                        ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          RouteNames.widgetPreview,
                        ),
                        icon: const Icon(Icons.widgets_outlined),
                        label: const Text('Preview Widget Content'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(_saving ? 'Saving…' : 'Save Preferences'),
                  ),
                ),
              ],
            ),
    );
  }
}
