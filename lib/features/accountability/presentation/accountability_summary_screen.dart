import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/info_card.dart';
import '../data/accountability_settings_repository.dart';
import '../domain/accountability_scope.dart';
import '../domain/accountability_settings.dart';

class AccountabilitySummaryScreen extends StatefulWidget {
  const AccountabilitySummaryScreen({super.key});

  @override
  State<AccountabilitySummaryScreen> createState() =>
      _AccountabilitySummaryScreenState();
}

class _AccountabilitySummaryScreenState
    extends State<AccountabilitySummaryScreen> {
  final AccountabilitySettingsRepository _repository =
      AccountabilitySettingsRepository();

  AccountabilitySettings _settings = AccountabilitySettings.defaults;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await _repository.getSettings();

    if (!mounted) {
      return;
    }

    setState(() {
      _settings = settings;
      _loading = false;
    });
  }

  Widget _summaryTile(AccountabilityScope scope) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(scope.label)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final scopes = _settings.sharedScopes.toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accountability Summary'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Approved read-only view',
                  style: AppTypography.section,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'This summary only shows the areas the recovery user chose to share. It does not allow editing, deleting, settings changes, or private app unlock.',
                  style: AppTypography.muted,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shared summary areas',
                  style: AppTypography.section,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (!_settings.enabled || scopes.isEmpty)
                  const Text(
                    'Accountability sharing is not currently enabled.',
                    style: AppTypography.muted,
                  )
                else
                  for (final scope in scopes) _summaryTile(scope),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy boundaries',
                  style: AppTypography.section,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _settings.sharePrivateNotes
                      ? 'Private notes sharing is enabled by the recovery user.'
                      : 'Private notes are not shared.',
                  style: AppTypography.muted,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Only the selected summary areas are shown.',
                  style: AppTypography.muted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
