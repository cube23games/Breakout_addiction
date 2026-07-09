import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/accountability_settings_repository.dart';
import '../domain/accountability_scope.dart';
import '../domain/accountability_settings.dart';

class AccountabilitySettingsScreen extends StatefulWidget {
  const AccountabilitySettingsScreen({super.key});

  @override
  State<AccountabilitySettingsScreen> createState() =>
      _AccountabilitySettingsScreenState();
}

class _AccountabilitySettingsScreenState
    extends State<AccountabilitySettingsScreen> {
  final AccountabilitySettingsRepository _repository =
      AccountabilitySettingsRepository();
  final TextEditingController _partnerPasscodeController =
      TextEditingController();

  AccountabilitySettings _settings = AccountabilitySettings.defaults;
  bool _loading = true;
  bool _hasPartnerPasscode = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _partnerPasscodeController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final settings = await _repository.getSettings();
    final hasPartnerPasscode = await _repository.hasPartnerPasscode();

    if (!mounted) {
      return;
    }

    setState(() {
      _settings = settings;
      _hasPartnerPasscode = hasPartnerPasscode;
      _loading = false;
    });
  }

  Future<void> _saveSettings(AccountabilitySettings settings) async {
    await _repository.saveSettings(settings);

    if (!mounted) {
      return;
    }

    setState(() => _settings = settings);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Accountability settings saved.')),
    );
  }

  Future<void> _savePartnerPasscode() async {
    final passcode = _partnerPasscodeController.text.trim();

    if (passcode.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Use at least 4 characters.')),
      );
      return;
    }

    await _repository.savePartnerPasscode(passcode);
    _partnerPasscodeController.clear();

    if (!mounted) {
      return;
    }

    setState(() => _hasPartnerPasscode = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Partner passcode saved.')),
    );
  }

  Future<void> _clearPartnerPasscode() async {
    await _repository.clearPartnerPasscode();

    if (!mounted) {
      return;
    }

    setState(() => _hasPartnerPasscode = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Partner passcode removed.')),
    );
  }

  void _toggleScope(AccountabilityScope scope, bool selected) {
    final nextScopes = Set<AccountabilityScope>.from(_settings.sharedScopes);

    if (selected) {
      nextScopes.add(scope);
    } else {
      nextScopes.remove(scope);
    }

    _saveSettings(_settings.copyWith(sharedScopes: nextScopes));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Accountability Mode')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Support, not surveillance',
                    style: AppTypography.section),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Let someone support you without giving them your whole private world. You choose what your accountability partner can see.',
                  style: AppTypography.muted,
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile.adaptive(
                  value: _settings.enabled,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable Accountability Mode'),
                  subtitle: const Text(
                    'Adds a separate read-only support role later.',
                  ),
                  onChanged: (value) =>
                      _saveSettings(_settings.copyWith(enabled: value)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Partner Passcode', style: AppTypography.section),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _hasPartnerPasscode
                      ? 'A separate partner passcode is saved.'
                      : 'Create a separate passcode for the future Accountability Partner login.',
                  style: AppTypography.muted,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _partnerPasscodeController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Partner passcode',
                    hintText: 'At least 4 characters',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Save Partner Passcode',
                  icon: Icons.lock_outline,
                  onPressed: _savePartnerPasscode,
                ),
                if (_hasPartnerPasscode) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _clearPartnerPasscode,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Remove Partner Passcode'),
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
                Text('What can they see?', style: AppTypography.section),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Choose the read-only summary areas your accountability partner may view later.',
                  style: AppTypography.muted,
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final scope in AccountabilityScope.values)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _settings.sharedScopes.contains(scope),
                    title: Text(scope.label),
                    onChanged: (value) => _toggleScope(scope, value ?? false),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Private by default', style: AppTypography.section),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile.adaptive(
                  value: _settings.sharePrivateNotes,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Share private notes'),
                  subtitle: const Text('Off by default. Use carefully.'),
                  onChanged: (value) => _saveSettings(
                    _settings.copyWith(sharePrivateNotes: value),
                  ),
                ),
                SwitchListTile.adaptive(
                  value: _settings.shareAiChatHistory,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Share AI chat history'),
                  subtitle: const Text(
                    'Off by default. Not recommended for MVP.',
                  ),
                  onChanged: (value) => _saveSettings(
                    _settings.copyWith(shareAiChatHistory: value),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
