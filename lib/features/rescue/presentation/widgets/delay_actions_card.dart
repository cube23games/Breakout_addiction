import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/widgets/info_card.dart';

class DelayActionsCard extends StatefulWidget {
  const DelayActionsCard({super.key});

  @override
  State<DelayActionsCard> createState() => _DelayActionsCardState();
}

class _DelayActionsCardState extends State<DelayActionsCard> {
  Timer? _timer;
  Duration? _selectedDuration;
  Duration _remaining = Duration.zero;
  bool _completed = false;

  bool get _isActive => _timer != null && _remaining.inSeconds > 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startDelay(int minutes) {
    final duration = Duration(minutes: minutes);
    _timer?.cancel();

    setState(() {
      _selectedDuration = duration;
      _remaining = duration;
      _completed = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF13212C),
        content: Text('Good call. Delay for $minutes minutes and stay with the plan.'),
      ),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remaining.inSeconds <= 1) {
        timer.cancel();
        setState(() {
          _timer = null;
          _remaining = Duration.zero;
          _completed = true;
        });
        return;
      }

      setState(() {
        _remaining = Duration(seconds: _remaining.inSeconds - 1);
      });
    });
  }

  void _cancelDelay() {
    _timer?.cancel();
    setState(() {
      _timer = null;
      _selectedDuration = null;
      _remaining = Duration.zero;
      _completed = false;
    });
  }

  String _formatRemaining(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double _progressValue() {
    final selected = _selectedDuration;
    if (selected == null || selected.inSeconds == 0) {
      return 0;
    }

    final elapsed = selected.inSeconds - _remaining.inSeconds;
    return (elapsed / selected.inSeconds).clamp(0.0, 1.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_isActive ? 'Delay Active' : 'Delay Actions', style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          if (_isActive) ...[
            Text('${_formatRemaining(_remaining)} remaining', style: AppTypography.title),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(value: _progressValue()),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'You are creating space between the urge and the action.',
              style: AppTypography.muted,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                OutlinedButton(
                  onPressed: _cancelDelay,
                  child: const Text('Cancel timer'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, RouteNames.support),
                  child: const Text('Open Support'),
                ),
              ],
            ),
          ] else if (_completed) ...[
            Text('Delay complete.', style: AppTypography.section),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Check in. If the urge is still strong, breathe, read your reasons, log this moment, or contact support.',
              style: AppTypography.muted,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                OutlinedButton(
                  onPressed: () => _startDelay(3),
                  child: const Text('Delay 3 more'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, RouteNames.recoveryEventLog),
                  child: const Text('Log this'),
                ),
                OutlinedButton(
                  onPressed: _cancelDelay,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ] else ...[
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton(
                  onPressed: () => _startDelay(3),
                  child: const Text('Delay 3 min'),
                ),
                OutlinedButton(
                  onPressed: () => _startDelay(10),
                  child: const Text('Delay 10 min'),
                ),
                OutlinedButton(
                  onPressed: () => _startDelay(15),
                  child: const Text('Delay 15 min'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
