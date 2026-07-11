import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../quotes/data/daily_quote_repository.dart';
import '../../../quotes/domain/daily_quote.dart';

class DailyQuoteCard extends StatelessWidget {
  const DailyQuoteCard({super.key});

  String _metadata(DailyQuote quote) {
    final religion = quote.religionTag?.trim();

    if (quote.mode == QuoteMode.faith &&
        religion != null &&
        religion.isNotEmpty) {
      return 'Changes daily • $religion focus';
    }

    return 'Changes daily';
  }

  @override
  Widget build(BuildContext context) {
    final repository = DailyQuoteRepository();

    return FutureBuilder<DailyQuote>(
      future: repository.getTodayQuote(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const InfoCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Focus',
                  style: AppTypography.section,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Loading encouragement...',
                  style: AppTypography.muted,
                ),
              ],
            ),
          );
        }

        final quote = snapshot.data;

        if (quote == null) {
          return const InfoCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Focus',
                  style: AppTypography.section,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Unable to load today’s focus.',
                  style: AppTypography.muted,
                ),
              ],
            ),
          );
        }

        return InfoCard(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Daily Focus',
                style: AppTypography.section,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                quote.text,
                style: AppTypography.body,
              ),
              const SizedBox(height: 6),
              Text(
                quote.focusLine,
                style: AppTypography.muted,
              ),
              if (quote.wisdomLine != null &&
                  quote.wisdomLine!
                      .trim()
                      .isNotEmpty) ...[
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                Text(
                  quote.wisdomLine!,
                  style: AppTypography.body,
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(
                    Icons.today_outlined,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _metadata(quote),
                      style: AppTypography.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
