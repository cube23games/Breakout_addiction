import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/info_card.dart';
import '../data/premium_report_repository.dart';

class RecoveryReportScreen extends StatefulWidget {
  const RecoveryReportScreen({super.key});

  @override
  State<RecoveryReportScreen> createState() =>
      _RecoveryReportScreenState();
}

class _RecoveryReportScreenState extends State<RecoveryReportScreen> {
  final PremiumReportRepository _repository =
      PremiumReportRepository();

  String _report = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _buildReport();
  }

  Future<void> _buildReport() async {
    final report = await _repository.buildReport();
    if (!mounted) {
      return;
    }
    setState(() {
      _report = report;
      _loading = false;
    });
  }

  Future<void> _copyReport() async {
    await Clipboard.setData(ClipboardData(text: _report));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Recovery report copied. Review it before sharing.',
        ),
      ),
    );
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
                Text(
                  'A readable view of your recovery data.',
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'This report stays on your device until you choose to copy it. It may contain highly private information.',
                  style: AppTypography.muted,
                ),
                const SizedBox(height: AppSpacing.lg),
                InfoCard(
                  child: SelectableText(
                    _report,
                    style: AppTypography.body,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _report.isEmpty ? null : _copyReport,
                    icon: const Icon(Icons.copy_all_outlined),
                    label: const Text('Copy Private Report'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _buildReport,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh From Current Data'),
                  ),
                ),
              ],
            ),
    );
  }
}
