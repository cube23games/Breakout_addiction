import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/security/credential_input_mode.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/selectable_option_tile.dart';
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
  CredentialInputMode _partnerCredentialMode =
      CredentialInputMode.pin;
  CredentialInputMode _savedPartnerCredentialMode =
      CredentialInputMode.pin;
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
    final credentialMode =
        await _repository.getPartnerCredentialMode();

    if (!mounted) {
      return;
    }

    setState(() {
      _settings = settings;
      _hasPartnerPasscode = hasPartnerPasscode;
      _partnerCredentialMode = credentialMode;
      _savedPartnerCredentialMode = credentialMode;
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
    final credential = _partnerPasscodeController.text.trim();
    final isPin =
        _partnerCredentialMode == CredentialInputMode.pin;

    if (credential.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPin
                ? 'Use at least 4 digits.'
                : 'Use at least 4 characters.',
          ),
        ),
      );
      return;
    }

    await _repository.savePartnerPasscode(
      credential,
      mode: _partnerCredentialMode,
    );
    _partnerPasscodeController.clear();

    if (!mounted) {
      return;
    }

    setState(() {
      _hasPartnerPasscode = true;
      _savedPartnerCredentialMode = _partnerCredentialMode;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Partner ${_partnerCredentialMode.label} saved.',
        ),
      ),
    );
  }

  Future<void> _clearPartnerPasscode() async {
    await _repository.clearPartnerPasscode();

    if (!mounted) {
      return;
    }

    setState(() {
      _hasPartnerPasscode = false;
      _partnerCredentialMode = CredentialInputMode.pin;
      _savedPartnerCredentialMode = CredentialInputMode.pin;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Partner credential removed.')),
    );
  }

  void _toggleScope(AccountabilityScope scope, bool selected) {
    final nextScopes = Set<AccountabilityScope>.from(
      _settings.sharedScopes,
    );

    if (selected) {
      nextScopes.add(scope);
    } else {
      nextScopes.remove(scope);
    }

    _saveSettings(
      _settings.copyWith(sharedScopes: nextScopes),
    );
  }

  String _partnerCredentialStatus() {
    if (!_hasPartnerPasscode) {
      return 'Create a separate PIN or password for the read-only partner view.';
    }

    if (_partnerCredentialMode == _savedPartnerCredentialMode) {
      return 'A separate partner ${_savedPartnerCredentialMode.label} is saved.';
    }

    return 'A partner ${_savedPartnerCredentialMode.label} is saved. Save below to replace it with a ${_partnerCredentialMode.label}.';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isPin =
        _partnerCredentialMode == CredentialInputMode.pin;

    return Scaffold(
      appBar: AppBar(title: const Text('Accountability Mode')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Support, not surveillance',
                  style: AppTypography.section,
                ),
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
                    'Allows a trusted partner to open a separate read-only summary.',
                  ),
                  onChanged: (value) => _saveSettings(
                    _settings.copyWith(enabled: value),
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
                Text(
                  'Partner Access Credential',
                  style: AppTypography.section,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _partnerCredentialStatus(),
                  style: AppTypography.muted,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final option in CredentialInputMode.values)
                      ChoiceChip(
                        label: Text(option.label),
                        selected: _partnerCredentialMode == option,
                        onSelected: (selected) {
                          if (!selected ||
                              _partnerCredentialMode == option) {
                            return;
                          }

                          FocusScope.of(context).unfocus();
                          _partnerPasscodeController.clear();
                          setState(() {
                            _partnerCredentialMode = option;
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  key: ValueKey(_partnerCredentialMode),
                  controller: _partnerPasscodeController,
                  obscureText: true,
                  keyboardType:
                      isPin ? TextInputType.number : TextInputType.text,
                  inputFormatters: isPin
                      ? <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ]
                      : null,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText:
                        'Partner ${_partnerCredentialMode.label}',
                    hintText: isPin
                        ? 'At least 4 digits'
                        : 'At least 4 characters',
                  ),
                  onSubmitted: (_) => _savePartnerPasscode(),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label:
                      'Save Partner ${_partnerCredentialMode.label}',
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
                      label: const Text(
                        'Remove Partner Credential',
                      ),
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
                Text(
                  'What can they see?',
                  style: AppTypography.section,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Choose the read-only summary areas your accountability partner may view.',
                  style: AppTypography.muted,
                ),
                const SizedBox(height: AppSpacing.md),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = AppSpacing.sm;
                    final columns =
                        constraints.maxWidth >= 440 ? 2 : 1;
                    final tileWidth = columns == 1
                        ? constraints.maxWidth
                        : (constraints.maxWidth - spacing) / 2;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        for (final scope in AccountabilityScope.values)
                          SizedBox(
                            width: tileWidth,
                            child: SelectableOptionTile(
                              label: scope.label,
                              selected:
                                  _settings.sharedScopes.contains(scope),
                              onTap: () => _toggleScope(
                                scope,
                                !_settings.sharedScopes.contains(scope),
                              ),
                            ),
                          ),
                      ],
                    );
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
                Text(
                  'Private by default',
                  style: AppTypography.section,
                ),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile.adaptive(
                  value: _settings.sharePrivateNotes,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Share private notes'),
                  subtitle: const Text(
                    'Off by default. Use carefully.',
                  ),
                  onChanged: (value) => _saveSettings(
                    _settings.copyWith(
                      sharePrivateNotes: value,
                    ),
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
