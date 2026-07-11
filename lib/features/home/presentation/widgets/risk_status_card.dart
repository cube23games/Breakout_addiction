import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/privacy/neutral_labels.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../log/data/mood_log_repository.dart';
import '../../../log/domain/mood_entry.dart';
import '../../../privacy/data/privacy_label_repository.dart';
import '../../domain/risk_status_summary.dart';

class RiskStatusCard extends StatelessWidget {
  const RiskStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final moodRepository = MoodLogRepository();
    final privacyRepository =
        PrivacyLabelRepository();

    return FutureBuilder<List<dynamic>>(
      future: Future.wait<dynamic>([
        moodRepository.getEntries(),
        privacyRepository.isNeutralModeEnabled(),
      ]),
      builder: (context, snapshot) {
        final data = snapshot.data;

        final entries =
            data != null && data.isNotEmpty
                ? data[0] as List<MoodEntry>
                : <MoodEntry>[];

        final neutralMode =
            data != null && data.length > 1
                ? data[1] as bool
                : true;

        final summary =
            RiskStatusSummary.fromEntries(entries);

        return InfoCard(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Risk Status',
                style: AppTypography.section,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 22,
                  ),
                  const SizedBox(
                    width: AppSpacing.sm,
                  ),
                  Expanded(
                    child: Text(
                      summary.label,
                      style: AppTypography.title,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                summary.detail,
                style: AppTypography.muted,
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: NeutralLabels.riskCardAction(
                  neutralMode,
                ),
                icon: Icons.mood_outlined,
                onPressed: () => Navigator.pushNamed(
                  context,
                  RouteNames.moodLog,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
