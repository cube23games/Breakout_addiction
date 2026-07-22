#!/usr/bin/env python3
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def req(path,*needles):
  text=(ROOT/path).read_text()
  for n in needles:
    if n not in text: raise SystemExit(f'BA-70A8 missing {n!r} in {path}')
req('pubspec.yaml','share_plus: ^10.1.4')
req('lib/features/accountability/presentation/accountability_center_screen.dart','_refreshing','Last updated','Accountability scorecard refreshed.','Refresh failed')
req('lib/features/premium_tools/presentation/recovery_report_screen.dart','Share With Approved Contact','Share With Someone Else','_confirmShare','Share.share',"scheme: 'sms'")
req('lib/features/premium_tools/data/premium_report_repository.dart','Private notes, faith content, media, and contact details are not included automatically.','RecoveryReportOptions')
print('BA-70A8 verifier passed.')
