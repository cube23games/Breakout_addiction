#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

def require(path, needles):
    rel = ROOT / path
    if not rel.exists():
        print(f"FAIL missing file: {path}")
        sys.exit(1)

    text = rel.read_text()
    failures = [needle for needle in needles if needle not in text]
    if failures:
        for needle in failures:
            print(f"FAIL {path} missing: {needle}")
        sys.exit(1)

require(
    "lib/app/theme/app_theme.dart",
    [
        "snackBarTheme: const SnackBarThemeData",
        "behavior: SnackBarBehavior.floating",
        "backgroundColor: Color(0xFF13212C)",
        "contentTextStyle: TextStyle(color: AppColors.textPrimary)",
        "actionTextColor: AppColors.accent",
        "borderRadius: BorderRadius.all(Radius.circular(16))",
    ],
)

print("BA-38 verification passed: global snackbar polish is wired.")
