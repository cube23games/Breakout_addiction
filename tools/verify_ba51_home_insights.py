#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {
    'lib/features/home/presentation/widgets/daily_quote_card.dart': [
        'FutureBuilder<DailyQuote>',
        'Changes daily',
        'Icons.today_outlined',
    ],
    'lib/features/home/presentation/widgets/home_hero_card.dart': [
        'Private by design',
        'Built for action',
        'class _HeroMetadata',
    ],
    'lib/features/home/domain/risk_status_summary.dart': [
        'class RiskStatusSummary',
        'Not enough data yet',
        'High Risk',
    ],
    'lib/features/home/presentation/widgets/risk_status_card.dart': [
        'RiskStatusSummary.fromEntries',
        'Icons.shield_outlined',
    ],
    'lib/features/insights/presentation/insights_screen.dart': [
        'InsightsContent',
        'InsightsBottomNavigation',
    ],
    'lib/features/insights/presentation/widgets/insight_event_summary_grid.dart': [
        'LayoutBuilder',
        'Wrap(',
        'constraints.maxWidth >= 720',
        'constraints.maxWidth >= 440',
    ],
    'lib/features/insights/presentation/widgets/insight_risk_summary_card.dart': [
        'Recent Risk Summary',
        'Icons.shield_outlined',
    ],
    'lib/features/insights/presentation/widgets/insight_next_action_card.dart': [
        'Next Best Action',
    ],
}

BANNED = {
    'lib/features/quotes/data/daily_quote_repository.dart': [
        'A craving is a wave, not a command.',
    ],
    'lib/features/home/presentation/widgets/daily_quote_card.dart': [
        'Chip(',
        'QuotePreferencesRepository',
    ],
    'lib/features/home/presentation/widgets/home_hero_card.dart': [
        'Recovery-first',
        'Chip(',
    ],
    'lib/features/home/presentation/widgets/risk_status_card.dart': [
        'Chip(',
    ],
    'lib/features/insights/presentation/insights_screen.dart': [
        '_eventCard',
        'return Expanded(',
        'Chip(',
    ],
}

LIMITS = {
    'lib/features/home/presentation/widgets/daily_quote_card.dart': 140,
    'lib/features/home/presentation/widgets/home_hero_card.dart': 130,
    'lib/features/home/domain/risk_status_summary.dart': 90,
    'lib/features/home/presentation/widgets/risk_status_card.dart': 120,
    'lib/features/insights/presentation/insights_screen.dart': 80,
    'lib/features/insights/presentation/widgets/insights_content.dart': 130,
    'lib/features/insights/presentation/widgets/insights_bottom_navigation.dart': 100,
    'lib/features/insights/presentation/widgets/insight_event_summary_grid.dart': 140,
    'lib/features/insights/presentation/widgets/insight_metric_card.dart': 70,
    'lib/features/insights/presentation/widgets/insight_risk_summary_card.dart': 80,
    'lib/features/insights/presentation/widgets/insight_mood_averages_card.dart': 80,
    'lib/features/insights/presentation/widgets/insight_next_action_card.dart': 60,
}

failures = []

for filename, needles in CHECKS.items():
    path = Path(filename)

    if not path.exists():
        failures.append(f'missing file: {filename}')
        continue

    text = path.read_text(encoding='utf-8')

    for needle in needles:
        if needle not in text:
            failures.append(
                f'{filename} missing: {needle}'
            )

for filename, needles in BANNED.items():
    path = Path(filename)

    if not path.exists():
        continue

    text = path.read_text(encoding='utf-8')

    for needle in needles:
        if needle in text:
            failures.append(
                f'{filename} still contains: {needle}'
            )

for filename, maximum in LIMITS.items():
    path = Path(filename)

    if not path.exists():
        failures.append(f'missing file: {filename}')
        continue

    line_count = len(
        path.read_text(
            encoding='utf-8'
        ).splitlines()
    )

    if line_count > maximum:
        failures.append(
            f'{filename} is {line_count} lines; '
            f'maximum is {maximum}'
        )

if failures:
    print(
        'BA-51 Home/Insights verification failed:'
    )

    for failure in failures:
        print(f' - {failure}')

    sys.exit(1)

print(
    'BA-51 Home/Insights verification passed: '
    'focused Home widgets and responsive Insights '
    'are wired.'
)
