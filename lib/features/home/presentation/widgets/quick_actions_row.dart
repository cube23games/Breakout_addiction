import 'package:flutter/material.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/privacy/neutral_labels.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../privacy/data/privacy_label_repository.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  Widget _button({required Widget child}) {
    return SizedBox(width: double.infinity, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: PrivacyLabelRepository().isNeutralModeEnabled(),
      builder: (context, snapshot) {
        final neutralMode = snapshot.data ?? true;
        return InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quick Actions'),
              const SizedBox(height: 12),
              _button(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    RouteNames.moodLog,
                  ),
                  icon: const Icon(Icons.mood_outlined),
                  label: Text(NeutralLabels.moodLog(neutralMode)),
                ),
              ),
              const SizedBox(height: 10),
              _button(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    RouteNames.recoveryPlan,
                  ),
                  icon: const Icon(Icons.assignment_outlined),
                  label: const Text('Recovery Plan'),
                ),
              ),
              const SizedBox(height: 10),
              _button(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    RouteNames.educate,
                  ),
                  icon: const Icon(Icons.menu_book_outlined),
                  label: const Text('Learn'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
