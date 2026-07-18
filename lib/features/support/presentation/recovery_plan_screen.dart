import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../premium/data/premium_access_repository.dart';
import '../../premium/domain/premium_status.dart';
import '../data/recovery_plan_repository.dart';
import '../domain/recovery_plan.dart';

class RecoveryPlanScreen extends StatefulWidget {
  const RecoveryPlanScreen({super.key});

  @override
  State<RecoveryPlanScreen> createState() => _RecoveryPlanScreenState();
}

class _RecoveryPlanScreenState extends State<RecoveryPlanScreen> {
  final RecoveryPlanRepository _repository = RecoveryPlanRepository();
  final PremiumAccessRepository _premiumRepository =
      PremiumAccessRepository();

  final TextEditingController _riskyPlacesController =
      TextEditingController();
  final TextEditingController _firstActionController =
      TextEditingController();
  final TextEditingController _secondActionController =
      TextEditingController();
  final TextEditingController _groundingActionController =
      TextEditingController();
  final TextEditingController _supportPersonController =
      TextEditingController();
  final TextEditingController _fallbackPlanController =
      TextEditingController();
  final TextEditingController _warningSignsController =
      TextEditingController();
  final TextEditingController _triggersController =
      TextEditingController();
  final TextEditingController _highRiskTimesController =
      TextEditingController();
  final TextEditingController _postSlipPlanController =
      TextEditingController();
  final TextEditingController _morningCommitmentController =
      TextEditingController();
  final TextEditingController _eveningCommitmentController =
      TextEditingController();

  RecoveryPlan _loadedPlan = RecoveryPlan.defaults();
  PremiumStatus _premium = PremiumStatus.defaults();
  DateTime? _reviewDate;
  bool _loading = true;
  bool _saving = false;

  bool get _hasPlus => _premium.hasPremium;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _riskyPlacesController.dispose();
    _firstActionController.dispose();
    _secondActionController.dispose();
    _groundingActionController.dispose();
    _supportPersonController.dispose();
    _fallbackPlanController.dispose();
    _warningSignsController.dispose();
    _triggersController.dispose();
    _highRiskTimesController.dispose();
    _postSlipPlanController.dispose();
    _morningCommitmentController.dispose();
    _eveningCommitmentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final plan = await _repository.getPlan();
    final premium = await _premiumRepository.getStatus();
    if (!mounted) {
      return;
    }

    _loadedPlan = plan;
    _premium = premium;
    _riskyPlacesController.text = plan.riskyPlaces.join(', ');
    _firstActionController.text = plan.firstAction;
    _secondActionController.text = plan.secondAction;
    _groundingActionController.text = plan.groundingAction;
    _supportPersonController.text = plan.supportPerson;
    _fallbackPlanController.text = plan.fallbackPlan;
    _warningSignsController.text = plan.warningSigns.join(', ');
    _triggersController.text = plan.triggers.join(', ');
    _highRiskTimesController.text = plan.highRiskTimes.join(', ');
    _postSlipPlanController.text = plan.postSlipPlan;
    _morningCommitmentController.text = plan.morningCommitment;
    _eveningCommitmentController.text = plan.eveningCommitment;
    _reviewDate = plan.reviewDate;

    setState(() => _loading = false);
  }

  List<String> _splitList(String raw) {
    return raw
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final plan = RecoveryPlan(
      riskyPlaces: _splitList(_riskyPlacesController.text),
      firstAction: _firstActionController.text.trim(),
      secondAction: _secondActionController.text.trim(),
      groundingAction: _groundingActionController.text.trim(),
      supportPerson: _supportPersonController.text.trim(),
      fallbackPlan: _fallbackPlanController.text.trim(),
      warningSigns: _hasPlus
          ? _splitList(_warningSignsController.text)
          : _loadedPlan.warningSigns,
      triggers: _hasPlus
          ? _splitList(_triggersController.text)
          : _loadedPlan.triggers,
      highRiskTimes: _hasPlus
          ? _splitList(_highRiskTimesController.text)
          : _loadedPlan.highRiskTimes,
      postSlipPlan: _hasPlus
          ? _postSlipPlanController.text.trim()
          : _loadedPlan.postSlipPlan,
      morningCommitment: _hasPlus
          ? _morningCommitmentController.text.trim()
          : _loadedPlan.morningCommitment,
      eveningCommitment: _hasPlus
          ? _eveningCommitmentController.text.trim()
          : _loadedPlan.eveningCommitment,
      reviewDate: _hasPlus ? _reviewDate : _loadedPlan.reviewDate,
      updatedAt: DateTime.now().toUtc(),
    );

    await _repository.savePlan(plan);
    if (!mounted) {
      return;
    }

    setState(() {
      _loadedPlan = plan;
      _saving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recovery plan saved.')),
    );
  }

  Future<void> _pickReviewDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _reviewDate ?? now.add(const Duration(days: 30)),
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 730)),
    );
    if (selected != null && mounted) {
      setState(() => _reviewDate = selected);
    }
  }

  Widget _field({
    required String title,
    required String hint,
    required TextEditingController controller,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller,
            minLines: minLines,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _advancedLockedCard() {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Advanced Recovery Plan Builder',
              style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Breakout Plus adds warning signs, trigger plans, high-risk times, morning and evening commitments, post-slip rebuilding, review dates, and plan readiness.',
            style: AppTypography.muted,
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: 'Open Breakout Plus',
            icon: Icons.workspace_premium_outlined,
            onPressed: () =>
                Navigator.pushNamed(context, RouteNames.premium),
          ),
        ],
      ),
    );
  }

  Widget _readinessCard() {
    final preview = RecoveryPlan(
      riskyPlaces: _splitList(_riskyPlacesController.text),
      firstAction: _firstActionController.text.trim(),
      secondAction: _secondActionController.text.trim(),
      groundingAction: _groundingActionController.text.trim(),
      supportPerson: _supportPersonController.text.trim(),
      fallbackPlan: _fallbackPlanController.text.trim(),
      warningSigns: _splitList(_warningSignsController.text),
      triggers: _splitList(_triggersController.text),
      highRiskTimes: _splitList(_highRiskTimesController.text),
      postSlipPlan: _postSlipPlanController.text.trim(),
      morningCommitment: _morningCommitmentController.text.trim(),
      eveningCommitment: _eveningCommitmentController.text.trim(),
      reviewDate: _reviewDate,
    );
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Plan Readiness', style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(value: preview.completion),
          const SizedBox(height: 6),
          Text(
            '${preview.completedSections} of ${preview.totalSections} plan sections ready',
            style: AppTypography.muted,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _reviewDate == null
                ? 'No review date selected.'
                : 'Review on ${_reviewDate!.month}/${_reviewDate!.day}/${_reviewDate!.year}.',
            style: AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickReviewDate,
              icon: const Icon(Icons.event_outlined),
              label: const Text('Choose Review Date'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Recovery Plan')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Recovery Plan')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Make the next right step obvious.',
              style: AppTypography.title),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'The basic action plan remains available to everyone. Breakout Plus adds a complete private planning system around it.',
            style: AppTypography.muted,
          ),
          const SizedBox(height: AppSpacing.lg),
          _field(
            title: 'Risky Places',
            hint:
                'Example: bedroom alone at night, parked car, bathroom, couch after midnight',
            controller: _riskyPlacesController,
            minLines: 2,
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.md),
          _field(
            title: 'What do I do first?',
            hint:
                'Example: leave the room, put the phone away, stand up immediately',
            controller: _firstActionController,
            minLines: 2,
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.md),
          _field(
            title: 'What is my backup step?',
            hint:
                'Example: text someone, open Rescue, go outside for 5 minutes',
            controller: _secondActionController,
            minLines: 2,
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.md),
          _field(
            title: 'Grounding Action',
            hint:
                'Example: breathe 4-4-6, cold water, 20 pushups, short walk',
            controller: _groundingActionController,
            minLines: 2,
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.md),
          _field(
            title: 'Support Person',
            hint: 'Who should I contact when I am slipping?',
            controller: _supportPersonController,
          ),
          const SizedBox(height: AppSpacing.md),
          _field(
            title: 'Fallback Plan',
            hint: 'If I still feel unstable, what do I do next?',
            controller: _fallbackPlanController,
            minLines: 3,
            maxLines: 5,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (!_hasPlus)
            _advancedLockedCard()
          else ...[
            Text('Breakout Plus Plan Builder',
                style: AppTypography.title),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Name the signals and commitments that should be visible before a high-risk moment.',
              style: AppTypography.muted,
            ),
            const SizedBox(height: AppSpacing.md),
            _readinessCard(),
            const SizedBox(height: AppSpacing.md),
            _field(
              title: 'Early Warning Signs',
              hint:
                  'Comma-separated: hiding phone, restless scrolling, isolating, bargaining',
              controller: _warningSignsController,
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.md),
            _field(
              title: 'Primary Triggers',
              hint:
                  'Comma-separated: stress, loneliness, boredom, conflict, fatigue',
              controller: _triggersController,
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.md),
            _field(
              title: 'High-Risk Times',
              hint:
                  'Comma-separated: late night, after arguments, weekends alone',
              controller: _highRiskTimesController,
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.md),
            _field(
              title: 'Morning Commitment',
              hint:
                  'One small action that protects recovery before the day gets busy',
              controller: _morningCommitmentController,
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.md),
            _field(
              title: 'Evening Commitment',
              hint:
                  'One boundary that reduces fatigue, privacy, and late-night negotiation',
              controller: _eveningCommitmentController,
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.md),
            _field(
              title: 'Post-Slip Rebuild Plan',
              hint:
                  'What will I do in the first 15 minutes after a slip to stop, learn, and reconnect?',
              controller: _postSlipPlanController,
              minLines: 3,
              maxLines: 5,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: _saving ? 'Saving...' : 'Save Recovery Plan',
            icon: Icons.save_outlined,
            onPressed: _saving ? () {} : _save,
          ),
        ],
      ),
    );
  }
}
