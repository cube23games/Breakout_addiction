#!/usr/bin/env python3
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def req(path,*needles):
  text=(ROOT/path).read_text()
  for n in needles:
    if n not in text: raise SystemExit(f'BA-70A13 missing {n!r} in {path}')
req('lib/features/ai_chat/domain/ai_personalization_settings.dart','enabled = false','includeMoodNotes','includeRecoveryNotes','includeFaithPreference')
req('lib/features/ai_chat/data/ai_personalization_repository.dart','FlutterSecureStorage','clear()')
req('lib/features/ai_chat/data/ai_recovery_context_builder.dart','USER-APPROVED RECOVERY CONTEXT','email removed','phone removed','take(3)','2400')
req('lib/features/ai_chat/presentation/ai_chat_screen.dart','Off by default','Review What AI Will Receive','Clear AI Recovery Memory','providerInput','_premiumStatus.hasAiPremium')
req('lib/features/ai_chat/data/mock_recovery_coach_provider.dart','Prototype personalized response','USER-APPROVED RECOVERY CONTEXT')
print('BA-70A13 verifier passed.')
