#!/usr/bin/env python3
from pathlib import Path
import sys

CHECKS = {'lib/core/constants/route_names.dart': ['static const widgetPreview = '
                                         "'/widget-preview';"],
 'lib/features/widget/domain/widget_snapshot.dart': ['class WidgetSnapshot'],
 'lib/features/widget/data/widget_snapshot_repository.dart': ['class '
                                                              'WidgetSnapshotRepository'],
 'lib/features/widget/presentation/widget_preview_screen.dart': ['Widget Preview'],
 'lib/app/app_router.dart': ['case RouteNames.widgetPreview:'],
 'android_widget_overlay/README_WIDGET_SETUP.md': ['Android Widget Overlay']}

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

if failures:
    print('BA17 verification failed:')

    for failure in failures:
        print(f' - {failure}')

    sys.exit(1)

print('BA-17 widget implementation verification passed.')
