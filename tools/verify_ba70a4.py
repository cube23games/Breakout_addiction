from pathlib import Path

ROOT = Path.cwd()
errors: list[str] = []

home = ROOT / "lib/features/home/presentation/home_screen.dart"
entry = ROOT / "lib/features/onboarding/presentation/home_entry_screen.dart"
ci = ROOT / ".github/workflows/ci.yml"

if not home.is_file():
    errors.append("missing Home screen")
else:
    text = home.read_text(encoding="utf-8")
    required = [
        "this.onStartupNoticeReady",
        "final VoidCallback? onStartupNoticeReady;",
        "void _notifyStartupNoticeReady()",
        "widget.onStartupNoticeReady?.call();",
        "showModalBottomSheet<void>(",
        "_notifyStartupNoticeReady();",
    ]
    for needle in required:
        if needle not in text:
            errors.append(f"Home startup coordination missing {needle!r}")
    if "allowStartupNotice" in text:
        errors.append("Home still delays the startup notice behind the welcome banner")
    show_index = text.find("showModalBottomSheet<void>(")
    notify_index = text.find("_notifyStartupNoticeReady();", show_index)
    if show_index < 0 or notify_index < show_index:
        errors.append("Welcome readiness is not signaled after the startup modal is opened")

if not entry.is_file():
    errors.append("missing Home entry screen")
else:
    text = entry.read_text(encoding="utf-8")
    required = [
        "OverlayEntry? _welcomeOverlayEntry;",
        "Overlay.of(context, rootOverlay: true)",
        "onStartupNoticeReady: _showWelcomeOverlay",
        "overlay.insert(entry);",
        "entry.remove();",
        "_welcomeOverlayEntry?.remove();",
    ]
    for needle in required:
        if needle not in text:
            errors.append(f"Layered welcome overlay missing {needle!r}")
    if "IgnorePointer(" in text:
        errors.append("Welcome overlay is still non-interactive and cannot be closed")
    if "HomeScreen(allowStartupNotice:" in text:
        errors.append("Obsolete wait-until-banner-finishes startup behavior remains")
    if "onComplete:" not in text:
        errors.append("Welcome overlay no longer controls its own timeout/close completion")

if not ci.is_file():
    errors.append("missing CI workflow")
else:
    text = ci.read_text(encoding="utf-8")
    for needle in [
        "python3 tools/verify_ba70a2.py",
        "python3 tools/verify_ba70a3.py",
        "python3 tools/verify_ba70a4.py",
    ]:
        if needle not in text:
            errors.append(f"CI missing {needle!r}")

if errors:
    print("BA-70A4 verification failed:")
    for error in errors:
        print(f" - {error}")
    raise SystemExit(1)

print(
    "BA-70A4 verification passed: the startup notice opens normally, the "
    "welcome banner is inserted afterward in the root overlay above it, and "
    "the banner remains independently dismissible by timeout or user action."
)
