#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def require(path: str, *needles: str) -> None:
    text = (ROOT / path).read_text(encoding='utf-8')
    for needle in needles:
        if needle not in text:
            raise SystemExit(f'BA-70A6 missing {needle!r} in {path}')

require('pubspec.yaml', 'image_picker:', 'path_provider:')
require(
    'lib/features/reasons/data/my_reasons_repository.dart',
    'getApplicationDocumentsDirectory',
    'importPhoto',
    'breakout_reasons',
)
require(
    'lib/features/reasons/presentation/my_reasons_screen.dart',
    'Add one personal reason before saving.',
    'Standard includes one private photo.',
    'Save My Reason',
)
require(
    'lib/features/rescue/presentation/widgets/reasons_to_stop_card.dart',
    'View My Reasons',
    'MyReasonsScreen',
)
require(
    'lib/features/home/presentation/home_screen.dart',
    'MyReasonsHomeCard',
)
print('BA-70A6 verifier passed.')
