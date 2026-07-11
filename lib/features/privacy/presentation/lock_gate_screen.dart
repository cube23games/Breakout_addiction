import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../accountability/data/accountability_settings_repository.dart';

class LockGateScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final Future<bool> Function(String passcode) onUnlockAttempt;
  final VoidCallback onUnlockSuccess;

  const LockGateScreen({
    super.key,
    required this.title,
    required this.subtitle,
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
    setState(() {
      _isBusy = true;
      _errorText = null;
    });

    final ok = await widget.onUnlockAttempt(
      _controller.text.trim(),
    );

    if (!mounted) {
      return;
    }

    setState(() => _isBusy = false);

    if (ok) {
      widget.onUnlockSuccess();
      return;
    }

    setState(() => _errorText = 'That code does not match.');
  }

  void _openPartnerAccess() {
    Navigator.pushNamed(
      context,
      RouteNames.accountabilityPartnerAccess,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Passcode',
                      border: const OutlineInputBorder(),
                      errorText: _errorText,
                    ),
                    onSubmitted: (_) => _unlock(),
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
                      'Accountability Partner',
                      style: AppTypography.section,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Open the separate read-only partner view without unlocking private app content.',
                      style: AppTypography.muted,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _openPartnerAccess,
                        icon: const Icon(Icons.visibility_outlined),
                        label: const Text(
                          'Accountability Partner Access',
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
