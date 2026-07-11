import 'package:flutter/material.dart';

import '../data/insights_repository.dart';
import '../domain/insight_summary.dart';
import 'widgets/insights_bottom_navigation.dart';
import 'widgets/insights_content.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = InsightsRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
      ),
      body: FutureBuilder<InsightSummary>(
        future: repository.buildSummary(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final summary =
              snapshot.data ?? InsightSummary.empty();

          return InsightsContent(
            summary: summary,
          );
        },
      ),
      bottomNavigationBar:
          const InsightsBottomNavigation(),
    );
  }
}
