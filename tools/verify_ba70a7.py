#!/usr/bin/env python3
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def req(path,*needles):
    text=(ROOT/path).read_text()
    for needle in needles:
        if needle not in text: raise SystemExit(f'BA-70A7 missing {needle!r} in {path}')
req('pubspec.yaml','video_player: ^2.9.5','image_picker: ^1.1.2','path_provider: ^2.1.5')
req('lib/features/reasons/presentation/my_reasons_screen.dart','_maxMedia => _hasPlus ? 10 : 1','Duration(seconds: 60)','ReorderableListView.builder','Use as cover','Add Video','Standard includes one private photo','Standard includes one written reason')
req('lib/features/reasons/presentation/reason_media_viewer.dart','VideoPlayerController.file','InteractiveViewer','Play')
req('lib/features/reasons/data/my_reasons_repository.dart','importVideo','breakout_reasons')
print('BA-70A7 verifier passed.')
