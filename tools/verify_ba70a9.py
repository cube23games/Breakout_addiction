#!/usr/bin/env python3
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def req(path,*needles):
  text=(ROOT/path).read_text()
  for n in needles:
    if n not in text: raise SystemExit(f'BA-70A9 missing {n!r} in {path}')
req('lib/core/widgets/tag_chip_input.dart',"split(',')",'InputChip','onSubmitted','value.endsWith')
req('lib/features/risk/domain/risk_window.dart','earlyWarningSigns','preparationAction','supportAction')
req('lib/features/risk/presentation/widgets/risk_window_editor_sheet.dart','Start with the signs','Early warning signs','TimePickerEntryMode.dial','Preparation action')
req('lib/features/support/presentation/recovery_plan_screen.dart','Press comma, Enter, or Add','TagChipInput','Add at least one recovery plan entry')
plan=(ROOT/'lib/features/support/presentation/recovery_plan_screen.dart').read_text()
if 'Comma-separated' in plan: raise SystemExit('BA-70A9 comma-separated wording remains')

if "return const Scaffold(" in plan or "appBar:const AppBar" in plan:
  raise SystemExit('BA-70A9 loading state uses an invalid const Scaffold/AppBar')
if "appBar:AppBar(title:const Text('Recovery Plan'))" not in plan:
  raise SystemExit('BA-70A9 loading-state AppBar repair is missing')

print('BA-70A9 verifier passed.')
