#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import struct
import sys

ROOT = Path.cwd()

REQUIRED_FILES = [
    '.github/workflows/ci.yml',
    'assets/branding/breakout_app_icon.png',
    'assets/branding/breakout_app_icon_adaptive_foreground.png',
    'assets/branding/play_store_icon_512.png',
    'lib/app/app_router.dart',
    'lib/features/about/data/demo_showcase_repository.dart',
    'lib/features/about/presentation/about_breakout_screen.dart',
    'lib/features/home/presentation/home_screen.dart',
    'lib/features/privacy/presentation/privacy_safety_center_screen.dart',
    'lib/features/support/presentation/support_screen.dart',
    'pubspec.yaml',
]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding='utf-8')


def png_info(path: Path) -> tuple[int, int, int]:
    data = path.read_bytes()
    if data[:8] != b'\x89PNG\r\n\x1a\n':
        raise ValueError('not a PNG file')
    if data[12:16] != b'IHDR':
        raise ValueError('missing PNG IHDR')
    width, height, bit_depth, color_type = struct.unpack('>IIBB', data[16:26])
    if bit_depth != 8:
        raise ValueError(f'expected 8-bit PNG, got {bit_depth}')
    return width, height, color_type


def main() -> int:
    failures: list[str] = []

    for relative in REQUIRED_FILES:
        if not (ROOT / relative).is_file():
            failures.append(f'missing file: {relative}')

    if failures:
        print('BA-53 verification failed:')
        for failure in failures:
            print(f' - {failure}')
        return 1

    pubspec = read('pubspec.yaml')
    for needle in [
        'flutter_launcher_icons: ^0.14.4',
        'flutter_launcher_icons:',
        'image_path: "assets/branding/breakout_app_icon.png"',
        'adaptive_icon_background: "#02071F"',
        'adaptive_icon_foreground: "assets/branding/breakout_app_icon_adaptive_foreground.png"',
    ]:
        if needle not in pubspec:
            failures.append(f'pubspec.yaml missing: {needle}')

    workflow = read('.github/workflows/ci.yml')
    for needle in [
        'Generate branded launcher icons',
        'dart run flutter_launcher_icons',
    ]:
        if needle not in workflow:
            failures.append(f'.github/workflows/ci.yml missing: {needle}')

    expected_pngs = {
        'assets/branding/breakout_app_icon.png': (1024, 1024, 2),
        'assets/branding/breakout_app_icon_adaptive_foreground.png': (1024, 1024, 6),
        'assets/branding/play_store_icon_512.png': (512, 512, 2),
    }
    for relative, expected in expected_pngs.items():
        try:
            actual = png_info(ROOT / relative)
        except Exception as exc:  # noqa: BLE001
            failures.append(f'{relative}: {exc}')
            continue
        if actual != expected:
            failures.append(f'{relative}: expected PNG {expected}, got {actual}')

    home = read('lib/features/home/presentation/home_screen.dart')
    for needle in [
        "tooltip: 'Open Support'",
        'Icons.support_agent_outlined',
        "const Text('Keep Moving Forward')",
    ]:
        if needle not in home:
            failures.append(f'home_screen.dart missing: {needle}')
    if 'Icons.settings_outlined' in home:
        failures.append('home_screen.dart still uses a misleading settings icon for Support')

    about_screen = read('lib/features/about/presentation/about_breakout_screen.dart')
    about_data = read('lib/features/about/data/demo_showcase_repository.dart')
    privacy = read('lib/features/privacy/presentation/privacy_safety_center_screen.dart')
    public_text = '\n'.join([about_screen, about_data, privacy])
    for forbidden in [
        'Demo framing',
        'core demo path',
        'Usage meter shows local/stub/live activity honestly.',
        'all real.',
    ]:
        if forbidden in public_text:
            failures.append(f'public-facing copy still contains: {forbidden}')

    support = read('lib/features/support/presentation/support_screen.dart')
    ai_block = """if (InternalSurfaceGate.showDevSurfaces) ...[\n                  const SizedBox(height: AppSpacing.sm),\n                  PrimaryButton(\n                    label: 'Open AI Recovery Coach'"""
    if ai_block not in support:
        failures.append('Support AI entry is not gated behind InternalSurfaceGate')

    router = read('lib/app/app_router.dart')
    for route_name in ['aiChat', 'releaseReadiness', 'widgetPreview']:
        route_marker = f'case RouteNames.{route_name}:'
        route_index = router.find(route_marker)
        if route_index < 0:
            failures.append(f'app_router.dart missing route: {route_marker}')
            continue
        guard_index = router.find('if (!InternalSurfaceGate.showDevSurfaces)', route_index)
        next_case = router.find('case RouteNames.', route_index + len(route_marker))
        if guard_index < 0 or (next_case >= 0 and guard_index > next_case):
            failures.append(f'app_router.dart does not gate {route_marker}')

    if failures:
        print('BA-53 verification failed:')
        for failure in failures:
            print(f' - {failure}')
        return 1

    print(
        'BA-53 verification passed: branded Android launcher assets, public-copy cleanup, '
        'Support clarity, and internal-surface route gates are wired.'
    )
    return 0


if __name__ == '__main__':
    sys.exit(main())
