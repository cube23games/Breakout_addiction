import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/info_card.dart';
import '../data/accountability_settings_repository.dart';
import '../data/accountability_summary_repository.dart';
import '../domain/accountability_scope.dart';
import '../domain/accountability_settings.dart';
import '../domain/accountability_summary_item.dart';
import 'widgets/accountability_summary_item_card.dart';

class AccountabilitySummaryScreen extends StatefulWidget {
  const AccountabilitySummaryScreen({super.key});

  @override
  State<AccountabilitySummaryScreen> createState() =>
      _AccountabilitySummaryScreenState();
}

class _AccountabilitySummaryScreenState
    extends State<AccountabilitySummaryScreen> {
  final AccountabilitySettingsRepository _settingsRepository =
      AccountabilitySettingsRepository();
  final AccountabilitySummaryRepository _summaryRepository =
      AccountabilitySummaryRepository();

  AccountabilitySettings _settings =
      AccountabilitySettings.defaults;
  List<AccountabilitySummaryItem> _items =
      <AccountabilitySummaryItem>[];
  bool _loading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _loadFailed = false;
      });
    }

    try {
      final settings =
          await _settingsRepository.getSettings();
      final items = settings.enabled
          ? await _summaryRepository.buildItems(settings)
          : <AccountabilitySummaryItem>[];

      if (!mounted) {
        return;
      }

      setState(() {
        _settings = settings;
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _loadFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accountability Summary'),
        actions: [
          IconButton(
            tooltip: 'Refresh shared data',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.all(AppSpacing.lg),
                children: [
                  InfoCard(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Approved read-only view',
                          style: AppTypography.section,
                        ),
                        const SizedBox(
                          height: AppSpacing.sm,
                        ),
                        const Text(
                          'This summary only shows the areas the recovery user chose to share. It does not allow editing, deleting, settings changes, or private app unlock.',
                          style: AppTypography.muted,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Shared summary areas',
                    style: AppTypography.title,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (_loadFailed)
                    const AccountabilitySummaryItemCard(
                      item: AccountabilitySummaryItem(
                        scope:
                            AccountabilityScope.progress,
                        status:
                            AccountabilityDataStatus.unavailable,
                        summary:
                            'Shared data could not be loaded right now. Pull down or tap Refresh to try again.',
                      ),
                    )
                  else if (!_settings.enabled ||
                      _settings.sharedScopes.isEmpty)
                    const InfoCard(
                      child: Text(
                        'Accountability sharing is not currently enabled.',
                        style: AppTypography.muted,
                      ),
                    )
                  else
                    for (final item in _items) ...[
                      AccountabilitySummaryItemCard(
                        item: item,
                      ),
                      const SizedBox(
                        height: AppSpacing.md,
                      ),
                    ],
                  InfoCard(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Privacy boundaries',
                          style: AppTypography.section,
                        ),
                        const SizedBox(
                          height: AppSpacing.sm,
                        ),
                        Text(
                          _settings.sharePrivateNotes
                              ? 'Private notes are shared only where they are included in the selected recovery data.'
                              : 'Private notes are not shared.',
                          style: AppTypography.muted,
                        ),
                        const SizedBox(
                          height: AppSpacing.sm,
                        ),
                        const Text(
                          'Only the selected summary areas are shown.',
                          style: AppTypography.muted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
