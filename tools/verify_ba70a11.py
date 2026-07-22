#!/usr/bin/env python3
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def req(path,*needles):
  text=(ROOT/path).read_text()
  for n in needles:
    if n not in text: raise SystemExit(f'BA-70A11 missing {n!r} in {path}')
req('lib/features/faith/domain/public_domain_verse.dart','World English Bible (WEB)')
req('lib/features/faith/data/public_domain_verse_repository.dart','Psalm 34:18','1 Corinthians 10:13','Philippians 4:8')
req('lib/features/faith/presentation/faith_reflection_card.dart','Optional faith reflection','Reflection:')
req('lib/features/premium_tools/presentation/recovery_programs_screen.dart','FaithReflectionCard','program.faithSensitive && isActive && _faithLayerEnabled')
req('lib/features/educate/presentation/educate_screen.dart','ExpansionTile','Lessons stay collapsed','Educate Me Plus')
print('BA-70A11 verifier passed.')
