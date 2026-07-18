import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/accountability_center_repository.dart';
import '../data/progress_scorecard_repository.dart';
import '../domain/accountability_check_in_plan.dart';
import '../domain/progress_scorecard.dart';

class AccountabilityCenterScreen extends StatefulWidget {
  const AccountabilityCenterScreen({super.key});

  @override
  State<AccountabilityCenterScreen> createState() =>
      _AccountabilityCenterScreenState();
}

class _AccountabilityCenterScreenState
    extends State<AccountabilityCenterScreen> {
  final AccountabilityCenterRepository _repository =
      AccountabilityCenterRepository();
  final ProgressScorecardRepository _scorecardRepository =
      ProgressScorecardRepository();

  final TextEditingController _partnerController =
      TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _winController = TextEditingController();
  final TextEditingController _riskController = TextEditingController();
  final TextEditingController _supportController =
      TextEditingController();
  final TextEditingController _commitmentController =
      TextEditingController();

  ProgressScorecard? _scorecard;
  DateTime? _nextCheckIn;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _partnerController.dispose();
    _goalController.dispose();
    _winController.dispose();
    _riskController.dispose();
    _supportController.dispose();
    _commitmentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final plan = await _repository.getPlan();
    final scorecard = await _scorecardRepository.build();
    if (!mounted) {
      return;
    }
    _partnerController.text = plan.partnerName;
    _goalController.text = plan.currentGoal;
    _winController.text = plan.winToShare;
    _riskController.text = plan.riskToDiscuss;
    _supportController.text = plan.supportRequest;
    _commitmentController.text = plan.nextCommitment;
    setState(() {
      _nextCheckIn = plan.nextCheckIn;
      _scorecard = scorecard;
      _loading = false;
    });
  }

  AccountabilityCheckInPlan _currentPlan() {
    return AccountabilityCheckInPlan(
      partnerName: _partnerController.text.trim(),
      nextCheckIn: _nextCheckIn,
      currentGoal: _goalController.text.trim(),
      winToShare: _winController.text.trim(),
      riskToDiscuss: _riskController.text.trim(),
      supportRequest: _supportController.text.trim(),
      nextCommitment: _commitmentController.text.trim(),
      updatedAt: DateTime.now().toUtc(),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await _repository.savePlan(_currentPlan());
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Accountability preparation saved.')),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _nextCheckIn ?? now.add(const Duration(days: 7)),
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (selected != null && mounted) {
      setState(() => _nextCheckIn = selected);
    }
  }

  String _summaryText() {
    final plan = _currentPlan();
    final scorecard = _scorecard;
    final date = plan.nextCheckIn == null
        ? 'Not scheduled'
        : '${plan.nextCheckIn!.month}/${plan.nextCheckIn!.day}/${plan.nextCheckIn!.year}';
    final lines = <String>[
      'BREAKOUT ADDICTION — ACCOUNTABILITY CHECK-IN',
      'Prepared for: ${plan.partnerName.isEmpty ? 'Trusted support' : plan.partnerName}',
      'Next check-in: $date',
      '',
      'CURRENT GOAL',
      plan.currentGoal.isEmpty ? 'Not added' : plan.currentGoal,
      '',
      'WIN TO SHARE',
      plan.winToShare.isEmpty ? 'Not added' : plan.winToShare,
      '',
      'RISK TO DISCUSS',
      plan.riskToDiscuss.isEmpty ? 'Not added' : plan.riskToDiscuss,
      '',
      'SUPPORT I AM ASKING FOR',
      plan.supportRequest.isEmpty ? 'Not added' : plan.supportRequest,
      '',
      'NEXT COMMITMENT',
      plan.nextCommitment.isEmpty ? 'Not added' : plan.nextCommitment,
    ];
    if (scorecard != null) {
      lines.addAll(<String>[
        '',
        'PRIVATE PROGRESS SNAPSHOT',
        '${scorecard.victories7} victories • ${scorecard.urges7} urges • ${scorecard.slips7} slips • ${scorecard.checkIns7} check-ins in the last 7 days',
        'Next focus: ${scorecard.nextFocus}',
      ]);
    }
    lines.addAll(const <String>[
      '',
      'PRIVACY NOTE',
      'Review this summary before sharing. Include only what you choose.',
    ]);
    return lines.join('\n');
  }

  Future<void> _copySummary() async {
    await Clipboard.setData(ClipboardData(text: _summaryText()));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Summary copied. Review the private details before sharing.',
        ),
      ),
    );
  }

  Widget _field({
    required String title,
    required String hint,
    required TextEditingController controller,
  }) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scorecardView(ProgressScorecard scorecard) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recovery Progress Scorecard',
              style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${scorecard.momentumLabel} • ${scorecard.engagementScore}/100',
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: scorecard.engagementScore / 100,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(scorecard.scoreMeaning, style: AppTypography.muted),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Last 7 days: ${scorecard.victories7} victories • '
            '${scorecard.urges7} urges • ${scorecard.slips7} slips • '
            '${scorecard.checkIns7} check-ins',
            style: AppTypography.body,
          ),
          const SizedBox(height: 6),
          Text(
            'Plan: ${scorecard.planSectionsCompleted}/${scorecard.planSectionsTotal} • '
            'Routine steps: ${scorecard.routineStepsCompleted}/${scorecard.routineStepsTotal} • '
            'Program steps: ${scorecard.programStepsCompleted}/${scorecard.programStepsTotal}',
            style: AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Milestones', style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          for (final milestone in scorecard.milestones)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('• $milestone', style: AppTypography.body),
            ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Next focus: ${scorecard.nextFocus}',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _scorecard == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Accountability Center')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final scorecard = _scorecard!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accountability Center'),
        actions: [
          IconButton(
            onPressed: _load,
            tooltip: 'Refresh scorecard',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Prepare an honest, useful check-in.',
              style: AppTypography.title),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'You control what is prepared, copied, and shared. Accountability should support recovery, not become surveillance.',
            style: AppTypography.muted,
          ),
          const SizedBox(height: AppSpacing.lg),
          _scorecardView(scorecard),
          const SizedBox(height: AppSpacing.md),
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Check-In Details', style: AppTypography.section),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _partnerController,
                  decoration: const InputDecoration(
                    labelText: 'Trusted person or group',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _nextCheckIn == null
                      ? 'Next check-in: not scheduled'
                      : 'Next check-in: ${_nextCheckIn!.month}/${_nextCheckIn!.day}/${_nextCheckIn!.year}',
                  style: AppTypography.body,
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.event_outlined),
                    label: const Text('Choose Check-In Date'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _field(
            title: 'Current Goal',
            hint: 'What are you actively working on right now?',
            controller: _goalController,
          ),
          const SizedBox(height: AppSpacing.md),
          _field(
            title: 'Win to Share',
            hint: 'What went better, even if it was small?',
            controller: _winController,
          ),
          const SizedBox(height: AppSpacing.md),
          _field(
            title: 'Risk to Discuss',
            hint: 'What pattern, trigger, or upcoming window needs honesty?',
            controller: _riskController,
          ),
          const SizedBox(height: AppSpacing.md),
          _field(
            title: 'Support I Am Asking For',
            hint: 'What specific support would actually help?',
            controller: _supportController,
          ),
          const SizedBox(height: AppSpacing.md),
          _field(
            title: 'Next Commitment',
            hint: 'What concrete action will you complete before the next check-in?',
            controller: _commitmentController,
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: _saving ? 'Saving...' : 'Save Check-In Preparation',
            icon: Icons.save_outlined,
            onPressed: _saving ? () {} : _save,
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _copySummary,
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Copy Reviewable Check-In Summary'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Privacy and Partner Access',
                    style: AppTypography.section),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Choose which categories a partner can see, or open the existing privacy-controlled summary.',
                  style: AppTypography.muted,
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      RouteNames.accountabilitySettings,
                    ),
                    icon: const Icon(Icons.privacy_tip_outlined),
                    label: const Text('Open Sharing Controls'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      RouteNames.accountabilitySummary,
                    ),
                    icon: const Icon(Icons.summarize_outlined),
                    label: const Text('Open Accountability Summary'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      RouteNames.recoveryReport,
                    ),
                    icon: const Icon(Icons.description_outlined),
                    label: const Text('Open Full Recovery Report'),
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
