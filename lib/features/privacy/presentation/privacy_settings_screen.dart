import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/security/credential_input_mode.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/lock_settings_repository.dart';
import '../domain/lock_scope.dart';
import '../domain/lock_settings.dart';
import 'lock_session_controller.dart';
import 'widgets/neutral_mode_preview_card.dart';
import 'widgets/privacy_status_card.dart';
import 'widgets/relock_timing_card.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState
    extends State<PrivacySettingsScreen> {
  final LockSettingsRepository _repository =
      LockSettingsRepository();

  LockSettings _settings = LockSettings.disabled();
  CredentialInputMode _credentialMode = CredentialInputMode.pin;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await _repository.getSettings();
    final credentialMode =
        await _repository.getCredentialInputMode();

    if (!mounted) {
      return;
    }

    setState(() {
      _settings = loaded;
      _credentialMode = credentialMode;
      _loading = false;
    });
  }

  Future<void> _saveSettings(LockSettings updated) async {
    await _repository.saveSettings(updated);
    LockSessionController.instance.updateGraceMinutes(
      updated.backgroundGraceMinutes,
    );

    if (!mounted) {
      return;
    }

    setState(() => _settings = updated);
  }

  Set<LockScope> _toggleScope(
    Set<LockScope> scopes,
    LockScope scope,
    bool enabled,
  ) {
    final next = <LockScope>{...scopes};
    if (enabled) {
      next.add(scope);
    } else {
      next.remove(scope);
    }
    return next;
  }

  Future<void> _showPasscodeSheet() async {
    final controller = TextEditingController();
    var mode = _credentialMode;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final isPin = mode == CredentialInputMode.pin;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                MediaQuery.of(sheetContext).viewInsets.bottom +
                    AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Set App Lock', style: AppTypography.title),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Choose a numeric PIN or a password. Breakout will use the same input type when you unlock the app.',
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
                          selected: mode == option,
                          onSelected: (selected) {
                            if (!selected || mode == option) {
                              return;
                            }

                            FocusScope.of(sheetContext).unfocus();
                            controller.clear();
                            setSheetState(() => mode = option);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    key: ValueKey(mode),
                    controller: controller,
                    obscureText: true,
                    keyboardType: isPin
                        ? TextInputType.number
                        : TextInputType.text,
                    inputFormatters: isPin
                        ? <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ]
                        : null,
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'App lock ${mode.label}',
                      hintText: isPin
                          ? 'At least 4 digits'
                          : 'At least 4 characters',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Save App Lock ${mode.label}',
                    icon: Icons.lock_outline,
                    onPressed: () async {
                      final value = controller.text.trim();
                      final minimumMessage = isPin
                          ? 'Use at least 4 digits.'
                          : 'Use at least 4 characters.';

                      if (value.length < 4) {
                        ScaffoldMessenger.of(sheetContext)
                            .showSnackBar(
                          SnackBar(
                            content: Text(minimumMessage),
                          ),
                        );
                        return;
                      }

                      await _repository.savePasscode(
                        value,
                        mode: mode,
                      );
                      if (!mounted) {
                        return;
                      }

                      setState(() => _credentialMode = mode);
                      await _saveSettings(
                        _settings.copyWith(hasPasscode: true),
                      );
                      if (!mounted) {
                        return;
                      }

                      if (sheetContext.mounted) {
                        Navigator.pop(sheetContext);
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'App lock ${mode.label} saved.',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    controller.dispose();
  }

  Future<void> _removePasscode() async {
    await _repository.clearPasscode();
    final cleared = _settings.copyWith(
      hasPasscode: false,
      isEnabled: false,
      enabledScopes: <LockScope>{},
    );
    await _saveSettings(cleared);

    if (!mounted) {
      return;
    }

    setState(() {
      _credentialMode = CredentialInputMode.pin;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'App lock credential removed and locks disabled.',
        ),
      ),
    );
  }

  Future<void> _resetDefaults() async {
    await _repository.resetToSafeDefaults();
    LockSessionController.instance
      ..updateGraceMinutes(0)
      ..lockNow();
    await _load();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy settings reset to safe defaults.'),
      ),
    );
  }

  Widget _buildScopeTile({
    required String title,
    required String subtitle,
    required LockScope scope,
  }) {
    final enabled = _settings.enabledScopes.contains(scope);

    return SwitchListTile(
      value: enabled,
      onChanged: !_settings.hasPasscode
          ? null
          : (value) => _saveSettings(
                _settings.copyWith(
                  enabledScopes: _toggleScope(
                    _settings.enabledScopes,
                    scope,
                    value,
                  ),
                ),
              ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Privacy Lock Mode')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Lock Mode')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const PrivacyStatusCard(),
          const SizedBox(height: AppSpacing.md),
          NeutralModePreviewCard(
            neutralMode: _settings.neutralPrivacyMode,
          ),
          const SizedBox(height: AppSpacing.md),
          const InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Layered Privacy',
                  style: AppTypography.section,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Choose whether to lock the whole app or only the private areas.',
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
                  'App Lock Credential',
                  style: AppTypography.section,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _settings.hasPasscode
                      ? 'An app lock ${_credentialMode.label} is currently set.'
                      : 'No app lock credential is set yet.',
                  style: AppTypography.muted,
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: _settings.hasPasscode
                      ? 'Update App Lock ${_credentialMode.label}'
                      : 'Set App Lock',
                  icon: Icons.password_outlined,
                  onPressed: _showPasscodeSheet,
                ),
                if (_settings.hasPasscode) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _removePasscode,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text(
                        'Remove App Lock Credential',
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
                  'Lock Master Switch',
                  style: AppTypography.section,
                ),
                SwitchListTile(
                  value: _settings.isEnabled,
                  onChanged: !_settings.hasPasscode
                      ? null
                      : (value) => _saveSettings(
                            _settings.copyWith(isEnabled: value),
                          ),
                  title: const Text('Enable Privacy Lock'),
                  subtitle: Text(
                    _settings.hasPasscode
                        ? 'Turn lock protection on or off.'
                        : 'Set an app lock credential first.',
                  ),
                ),
                SwitchListTile(
                  value: _settings.allowRescueWithoutUnlock,
                  onChanged: !_settings.hasPasscode
                      ? null
                      : (value) => _saveSettings(
                            _settings.copyWith(
                              allowRescueWithoutUnlock: value,
                            ),
                          ),
                  title: const Text(
                    'Allow Rescue Without Unlock',
                  ),
                  subtitle: const Text(
                    'Keep the Rescue area available even when private areas are locked.',
                  ),
                ),
                SwitchListTile(
                  value: _settings.neutralPrivacyMode,
                  onChanged: (value) => _saveSettings(
                    _settings.copyWith(
                      neutralPrivacyMode: value,
                    ),
                  ),
                  title: const Text('Use Neutral Labels'),
                  subtitle: const Text(
                    'Use lower-key wording across the app and widget labels.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          RelockTimingCard(
            selectedMinutes: _settings.backgroundGraceMinutes,
            enabled: _settings.hasPasscode,
            onSelected: (minutes) => _saveSettings(
              _settings.copyWith(
                backgroundGraceMinutes: minutes,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Protected Areas',
                  style: AppTypography.section,
                ),
                _buildScopeTile(
                  title: 'Lock Entire App',
                  subtitle: 'Require unlock across the whole app.',
                  scope: LockScope.app,
                ),
                _buildScopeTile(
                  title: 'Lock Private Logs',
                  subtitle: 'Protect stage logs and recovery logs.',
                  scope: LockScope.logs,
                ),
                _buildScopeTile(
                  title: 'Lock Cycle / History',
                  subtitle: 'Protect the cycle area.',
                  scope: LockScope.cycle,
                ),
                _buildScopeTile(
                  title: 'Lock Insights',
                  subtitle:
                      'Protect pattern summaries and analysis.',
                  scope: LockScope.insights,
                ),
                _buildScopeTile(
                  title: 'Lock Support Tools',
                  subtitle:
                      'Protect support, risk windows, and recovery plan.',
                  scope: LockScope.support,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reset', style: AppTypography.section),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Reset privacy settings to a safe default state while keeping your app lock credential intact.',
                  style: AppTypography.muted,
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _resetDefaults,
                    icon: const Icon(Icons.refresh_outlined),
                    label: const Text(
                      'Reset Privacy Defaults',
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
