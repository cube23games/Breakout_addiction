import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/info_card.dart';
import '../../support/data/support_contact_repository.dart';
import '../data/premium_report_repository.dart';
import '../domain/recovery_report_options.dart';

class RecoveryReportScreen extends StatefulWidget {
  const RecoveryReportScreen({super.key});
  @override
  State<RecoveryReportScreen> createState() => _RecoveryReportScreenState();
}

class _RecoveryReportScreenState extends State<RecoveryReportScreen> {
  final PremiumReportRepository _repository = PremiumReportRepository();
  final SupportContactRepository _contactRepository = SupportContactRepository();
  RecoveryReportOptions _options = const RecoveryReportOptions();
  String _report = '';
  bool _loading = true;

  @override
  void initState() { super.initState(); _buildReport(); }

  Future<void> _buildReport() async {
    setState(() => _loading = true);
    final report = await _repository.buildReport(options: _options);
    if (!mounted) return;
    setState(() { _report = report; _loading = false; });
  }

  Future<bool> _confirmShare(String destination) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Share with $destination?'),
        content: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Review the exact report below. Private notes, faith content, media, and contact details are excluded unless shown here.'),
            const SizedBox(height: 12),
            SelectableText(_report),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Share')),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _copyReport() async {
    await Clipboard.setData(ClipboardData(text: _report));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report copied. Review it before sharing.')));
  }

  Future<void> _shareElsewhere() async {
    if (!await _confirmShare('another app or person')) return;
    await Share.share(_report, subject: 'Breakout Addiction recovery report');
  }

  Future<void> _shareWithTrustedContact() async {
    final contact = await _contactRepository.getContact();
    if (!mounted) return;
    if (contact == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add an approved support contact first.')));
      return;
    }
    if (!await _confirmShare(contact.name)) return;
    final uri = Uri(scheme: 'sms', path: contact.phone, queryParameters: <String, String>{'body': _report});
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open messaging on this device.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recovery Report')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text('Review before you share.', style: AppTypography.title),
                const SizedBox(height: AppSpacing.xs),
                const Text('Choose what to include. Nothing is sent until you confirm a destination.', style: AppTypography.muted),
                const SizedBox(height: AppSpacing.lg),
                InfoCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Include in this report', style: AppTypography.section),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _options.includeDetailedPlan,
                      title: const Text('Selected recovery-plan details'),
                      subtitle: const Text('May include warning signs, triggers, commitments, and plan readiness.'),
                      onChanged: (value) { _options = _options.copyWith(includeDetailedPlan: value ?? false); _buildReport(); },
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _options.includeRiskWindows,
                      title: const Text('Enabled risk windows'),
                      onChanged: (value) { _options = _options.copyWith(includeRiskWindows: value ?? false); _buildReport(); },
                    ),
                    const Text('Notes, faith content, My Reasons media, and trusted-contact details are never included automatically.', style: AppTypography.muted),
                  ]),
                ),
                const SizedBox(height: AppSpacing.md),
                InfoCard(child: SelectableText(_report, style: AppTypography.body)),
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(onPressed: _report.isEmpty ? null : _shareWithTrustedContact, icon: const Icon(Icons.person_outline), label: const Text('Share With Approved Contact')),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(onPressed: _report.isEmpty ? null : _shareElsewhere, icon: const Icon(Icons.share_outlined), label: const Text('Share With Someone Else')),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(onPressed: _report.isEmpty ? null : _copyReport, icon: const Icon(Icons.copy_all_outlined), label: const Text('Copy Private Report')),
              ],
            ),
    );
  }
}
