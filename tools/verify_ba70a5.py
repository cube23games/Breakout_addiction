#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def require(path: str, *needles: str) -> str:
    text = (ROOT / path).read_text(encoding='utf-8')
    for needle in needles:
        if needle not in text:
            raise SystemExit(f'BA-70A5 missing {needle!r} in {path}')
    return text


require(
    'lib/features/home/presentation/home_screen.dart',
    'HomeTierSection',
    'const HomeHeroCard()',
    'const QuickActionsRow()',
)
home_tier = require(
    'lib/features/home/presentation/widgets/home_tier_section.dart',
    "import '../../../premium/domain/premium_plan.dart';",
    'if (status.hasPremium)',
    'Explore Breakout Plus',
    'QA access:',
)
premium = require(
    'lib/features/premium_tools/presentation/premium_tools_screen.dart',
    'if (!status.hasPremium)',
    'What Plus adds',
    'if (hasAi)',
    'AI support is separate from Breakout Plus',
    'Local Recovery Guidance',
    'Advanced Insights',
    'AI Personalization Tools',
    'Educate Me Plus',
    'Private Pattern Intelligence',
    'Advanced Risk Windows',
    'Advanced Recovery Plan Builder',
)
require(
    'lib/features/home/presentation/widgets/quick_actions_row.dart',
    'RouteNames.moodLog',
    'RouteNames.recoveryPlan',
    'RouteNames.educate',
)

home = (ROOT / 'lib/features/home/presentation/home_screen.dart').read_text(encoding='utf-8')
for forbidden in (
    'EntryStatusCard',
    'ProgressSnapshotCard',
    'Keep Moving Forward',
    "const Text('Learn and plan')",
):
    if forbidden in home:
        raise SystemExit(f'BA-70A5 Home clutter remains: {forbidden}')

standard_start = premium.index('Widget _standardView')
standard_end = premium.index('@override', standard_start)
standard = premium[standard_start:standard_end]
for paid_card in (
    'Local Recovery Guidance',
    'Advanced Insights',
    'AI Personalization Tools',
    'Educate Me Plus',
    'Private Pattern Intelligence',
    'Advanced Risk Windows',
    'Advanced Recovery Plan Builder',
):
    if paid_card in standard:
        raise SystemExit(
            f'BA-70A5 Standard view leaks a full paid tool card: {paid_card}'
        )

if "route: RouteNames.aiTools" not in premium:
    raise SystemExit('BA-70A5 AI Personalization Tools does not open the AI tools screen')

if "return const Scaffold(" in premium:
    raise SystemExit('BA-70A5 loading state still wraps AppBar in a const Scaffold')
if "appBar: const AppBar" in premium:
    raise SystemExit('BA-70A5 incorrectly calls the non-const AppBar constructor with const')
if "appBar: AppBar(title: const Text('Premium Tools'))" not in premium:
    raise SystemExit('BA-70A5 loading-state AppBar analyzer repair is missing')
if "Widget _standardView(BuildContext context, PremiumStatus status)" in premium:
    raise SystemExit('BA-70A5 Standard helper retains an unused status parameter')
if "body: _standardView(context, status)" in premium:
    raise SystemExit('BA-70A5 still passes the unused status argument')
if 'status.plan.label' in home_tier and 'premium_plan.dart' not in home_tier:
    raise SystemExit('BA-70A5 QA tier label is missing the PremiumPlan extension import')

print(
    'BA-70A5 verifier passed: Standard shows one compact Plus preview, '
    'Plus keeps every established local paid tool, and Plus AI keeps its '
    'separate AI Personalization Tools entry point, and both analyzer repairs are present.'
)
