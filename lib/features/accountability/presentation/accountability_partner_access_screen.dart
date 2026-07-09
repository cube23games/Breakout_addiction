import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/route_names.dart';
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
  final TextEditingController _passcodeController = TextEditingController();

  bool _checking = false;

  @override
  void dispose() {
    _passcodeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() => _checking = true);

    final settings = await _repository.getSettings();
    final valid =
        settings.canUsePartnerAccess &&
        await _repository.verifyPartnerPasscode(_passcodeController.text);

    if (!mounted) {
      return;
    }

    setState(() => _checking = false);

    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Accountability access is not enabled or the passcode is incorrect.'),
        ),
      );
      return;
    }

    Navigator.pushReplacementNamed(context, RouteNames.accountabilitySummary);
  }

  @override
  Widget build(BuildContext context) {
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
                Text('Read-only support access', style: AppTypography.section),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'This view is for an accountability partner invited by the recovery user. It only shows the approved summary areas and never unlocks the private app.',
                  style: AppTypography.muted,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _passcodeController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Partner passcode',
                  ),
                  onSubmitted: (_) => _verify(),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: _checking ? 'Checking...' : 'Open Accountability Summary',
                  icon: Icons.visibility_outlined,
                  onPressed: _checking ? () {} : _verify,
                ),
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
