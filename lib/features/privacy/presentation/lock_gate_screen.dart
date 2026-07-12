import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/security/credential_input_mode.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../accountability/data/accountability_settings_repository.dart';

class LockGateScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final CredentialInputMode credentialMode;
  final Future<bool> Function(String passcode) onUnlockAttempt;
  final VoidCallback onUnlockSuccess;

  const LockGateScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.credentialMode,
    required this.onUnlockAttempt,
    required this.onUnlockSuccess,
  });

  @override
  State<LockGateScreen> createState() => _LockGateScreenState();
}

class _LockGateScreenState extends State<LockGateScreen> {
  final TextEditingController _controller = TextEditingController();
  final AccountabilitySettingsRepository _accountabilityRepository =
      AccountabilitySettingsRepository();

  bool _isBusy = false;
  bool _partnerAccessAvailable = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _loadPartnerAccess();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadPartnerAccess() async {
    final settings = await _accountabilityRepository.getSettings();
    final hasPasscode =
        await _accountabilityRepository.hasPartnerPasscode();

    if (!mounted) {
      return;
    }

    setState(() {
      _partnerAccessAvailable =
          settings.canUsePartnerAccess && hasPasscode;
    });
  }

  Future<void> _unlock() async {
    final value = _controller.text.trim();

    if (value.isEmpty) {
      setState(() {
        _errorText =
            'Enter your app lock ${widget.credentialMode.label}.';
      });
      return;
    }

    setState(() {
      _isBusy = true;
      _errorText = null;
    });

    final ok = await widget.onUnlockAttempt(value);

    if (!mounted) {
      return;
    }

    if (ok) {
      setState(() => _isBusy = false);
      widget.onUnlockSuccess();
      return;
    }

    _controller.clear();
    setState(() {
      _isBusy = false;
      _errorText =
          'Incorrect app lock ${widget.credentialMode.label}. Try again.';
    });
  }

  void _openPartnerAccess() {
    Navigator.pushNamed(
      context,
      RouteNames.accountabilityPartnerAccess,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPin = widget.credentialMode == CredentialInputMode.pin;

    return Scaffold(
      appBar: AppBar(title: const Text('Protected')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: InfoCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: AppTypography.title),
                  const SizedBox(height: AppSpacing.sm),
                  Text(widget.subtitle, style: AppTypography.muted),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _controller,
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
                          'App lock ${widget.credentialMode.label}',
                      border: const OutlineInputBorder(),
                      errorText: _errorText,
                    ),
                    onSubmitted: _isBusy ? null : (_) => _unlock(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: _isBusy ? 'Unlocking...' : 'Unlock App',
                    icon: Icons.lock_open,
                    onPressed: _isBusy ? () {} : _unlock,
                  ),
                  if (_partnerAccessAvailable) ...[
                    const SizedBox(height: AppSpacing.lg),
                    const Divider(),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Partner View',
                      style: AppTypography.section,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Partner access uses its own PIN or password and opens only the approved read-only summary.',
                      style: AppTypography.muted,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: Semantics(
                        label: 'Accountability Partner Access',
                        button: true,
                        child: OutlinedButton.icon(
                          onPressed: _openPartnerAccess,
                          icon: const Icon(Icons.visibility_outlined),
                          label: const Text('Open Partner View'),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
