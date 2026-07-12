import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/security/credential_input_mode.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/accountability_settings_repository.dart';

class AccountabilityPartnerAccessScreen extends StatefulWidget {
  const AccountabilityPartnerAccessScreen({super.key});

  @override
  State<AccountabilityPartnerAccessScreen> createState() =>
      _AccountabilityPartnerAccessScreenState();
}

class _AccountabilityPartnerAccessScreenState
    extends State<AccountabilityPartnerAccessScreen> {
  final AccountabilitySettingsRepository _repository =
      AccountabilitySettingsRepository();
  final TextEditingController _credentialController =
      TextEditingController();

  CredentialInputMode _credentialMode = CredentialInputMode.pin;
  bool _loading = true;
  bool _accessReady = false;
  bool _checking = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _loadAccessState();
  }

  @override
  void dispose() {
    _credentialController.dispose();
    super.dispose();
  }

  Future<void> _loadAccessState() async {
    final settings = await _repository.getSettings();
    final hasCredential = await _repository.hasPartnerPasscode();
    final mode = await _repository.getPartnerCredentialMode();

    if (!mounted) {
      return;
    }

    setState(() {
      _credentialMode = mode;
      _accessReady = settings.canUsePartnerAccess && hasCredential;
      _loading = false;
    });
  }

  Future<void> _verify() async {
    final value = _credentialController.text.trim();

    if (value.isEmpty) {
      setState(() {
        _errorText = 'Enter your partner ${_credentialMode.label}.';
      });
      return;
    }

    setState(() {
      _checking = true;
      _errorText = null;
    });

    final valid = await _repository.verifyPartnerPasscode(value);

    if (!mounted) {
      return;
    }

    if (!valid) {
      _credentialController.clear();
      setState(() {
        _checking = false;
        _errorText =
            'Incorrect partner ${_credentialMode.label}. Try again.';
      });
      return;
    }

    setState(() => _checking = false);
    Navigator.pushReplacementNamed(
      context,
      RouteNames.accountabilitySummary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPin = _credentialMode == CredentialInputMode.pin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accountability Partner'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Read-only support access',
                  style: AppTypography.section,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'This separate view only shows the summary areas approved by the recovery user. It never unlocks private app content.',
                  style: AppTypography.muted,
                ),
                const SizedBox(height: AppSpacing.md),
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (!_accessReady)
                  const Text(
                    'Accountability Partner access has not been set up.',
                    style: AppTypography.muted,
                  )
                else ...[
                  TextField(
                    controller: _credentialController,
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
                      labelText: 'Partner ${_credentialMode.label}',
                      errorText: _errorText,
                    ),
                    onSubmitted: _checking ? null : (_) => _verify(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: _checking
                        ? 'Checking...'
                        : 'Open Accountability Summary',
                    icon: Icons.visibility_outlined,
                    onPressed: _checking ? () {} : _verify,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const InfoCard(
            child: Text(
              'Support, not surveillance. The recovery user chooses what is shared and can turn this off.',
              style: AppTypography.muted,
            ),
          ),
        ],
      ),
    );
  }
}
