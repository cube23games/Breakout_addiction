#!/usr/bin/env python3
from __future__ import annotations

import argparse
import os
import re
from pathlib import Path


PUBLIC_ID = "com.slimnation.breakoutaddiction"
QA_ID = f"{PUBLIC_ID}.qa"
NAMESPACE = PUBLIC_ID
CHANNEL = f"{PUBLIC_ID}/integrity"


def stop(message: str) -> None:
    raise SystemExit(message)


def require_env(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        stop(f"Required environment variable is missing: {name}")
    return value


def replace_once(text: str, pattern: str, replacement: str, label: str) -> str:
    updated, count = re.subn(
        pattern,
        replacement,
        text,
        count=1,
        flags=re.MULTILINE,
    )
    if count != 1:
        stop(f"Could not uniquely patch {label}.")
    return updated


def ensure_kts_desugaring(text: str) -> str:
    if "isCoreLibraryDesugaringEnabled = true" not in text:
        text = text.replace(
            "compileOptions {\n",
            "compileOptions {\n        isCoreLibraryDesugaringEnabled = true\n",
            1,
        )
    dependency = (
        'coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")'
    )
    if dependency not in text:
        if "dependencies {" in text:
            text = text.replace(
                "dependencies {\n",
                f"dependencies {{\n    {dependency}\n",
                1,
            )
        else:
            text += f"\n\ndependencies {{\n    {dependency}\n}}\n"
    return text


def ensure_groovy_desugaring(text: str) -> str:
    if "coreLibraryDesugaringEnabled true" not in text:
        text = text.replace(
            "compileOptions {\n",
            "compileOptions {\n        coreLibraryDesugaringEnabled true\n",
            1,
        )
    dependency = (
        "coreLibraryDesugaring "
        "'com.android.tools:desugar_jdk_libs:2.1.5'"
    )
    if dependency not in text:
        if "dependencies {" in text:
            text = text.replace(
                "dependencies {\n",
                f"dependencies {{\n    {dependency}\n",
                1,
            )
        else:
            text += f"\n\ndependencies {{\n    {dependency}\n}}\n"
    return text


def patch_kts(path: Path, app_id: str) -> None:
    text = path.read_text(encoding="utf-8")
    text = replace_once(
        text,
        r'^\s*namespace\s*=\s*"[^"]+"\s*$',
        f'    namespace = "{NAMESPACE}"',
        "Kotlin namespace",
    )
    text = replace_once(
        text,
        r'^\s*applicationId\s*=\s*"[^"]+"\s*$',
        f'        applicationId = "{app_id}"',
        "Kotlin applicationId",
    )

    if 'create("release")' not in text:
        marker = re.search(
            r'^\s*buildTypes\s*\{\s*$',
            text,
            re.MULTILINE,
        )
        if marker is None:
            stop("Kotlin buildTypes block was not found.")
        signing = '''    signingConfigs {
        create("release") {
            storeFile = file(System.getenv("BREAKOUT_APP_SIGNING_KEYSTORE_PATH"))
            storePassword = System.getenv("BREAKOUT_APP_SIGNING_STORE_PASSWORD")
            keyAlias = System.getenv("BREAKOUT_APP_SIGNING_KEY_ALIAS")
            keyPassword = System.getenv("BREAKOUT_APP_SIGNING_KEY_PASSWORD")
        }
    }

'''
        text = text[:marker.start()] + signing + text[marker.start():]

    text, count = re.subn(
        r'signingConfig\s*=\s*signingConfigs\.getByName\("debug"\)',
        'signingConfig = signingConfigs.getByName("release")',
        text,
        count=1,
    )
    if count == 0 and (
        'signingConfig = signingConfigs.getByName("release")'
        not in text
    ):
        stop("Kotlin release signingConfig line was not found.")

    path.write_text(ensure_kts_desugaring(text), encoding="utf-8")


def patch_groovy(path: Path, app_id: str) -> None:
    text = path.read_text(encoding="utf-8")
    text = replace_once(
        text,
        r'^\s*namespace\s+["\'][^"\']+["\']\s*$',
        f'    namespace "{NAMESPACE}"',
        "Groovy namespace",
    )
    text = replace_once(
        text,
        r'^\s*applicationId\s+["\'][^"\']+["\']\s*$',
        f'        applicationId "{app_id}"',
        "Groovy applicationId",
    )

    if "signingConfigs {" not in text:
        marker = re.search(
            r'^\s*buildTypes\s*\{\s*$',
            text,
            re.MULTILINE,
        )
        if marker is None:
            stop("Groovy buildTypes block was not found.")
        signing = '''    signingConfigs {
        release {
            storeFile file(System.getenv("BREAKOUT_APP_SIGNING_KEYSTORE_PATH"))
            storePassword System.getenv("BREAKOUT_APP_SIGNING_STORE_PASSWORD")
            keyAlias System.getenv("BREAKOUT_APP_SIGNING_KEY_ALIAS")
            keyPassword System.getenv("BREAKOUT_APP_SIGNING_KEY_PASSWORD")
        }
    }

'''
        text = text[:marker.start()] + signing + text[marker.start():]

    text, count = re.subn(
        r'signingConfig\s+signingConfigs\.debug',
        'signingConfig signingConfigs.release',
        text,
        count=1,
    )
    if count == 0 and (
        "signingConfig signingConfigs.release"
        not in text
    ):
        stop("Groovy release signingConfig line was not found.")

    path.write_text(ensure_groovy_desugaring(text), encoding="utf-8")


def patch_manifest(path: Path, label: str) -> None:
    text = path.read_text(encoding="utf-8")
    text, count = re.subn(
        r'android:label="[^"]*"',
        f'android:label="{label}"',
        text,
        count=1,
    )
    if count != 1:
        stop("Android application label was not found.")
    path.write_text(text, encoding="utf-8")


def write_main_activity(android: Path) -> None:
    for source_root in (
        android / "app/src/main/kotlin",
        android / "app/src/main/java",
    ):
        if source_root.exists():
            for candidate in source_root.rglob("MainActivity.*"):
                candidate.unlink()

    target = (
        android
        / "app/src/main/kotlin/com/slimnation/"
        "breakoutaddiction/MainActivity.kt"
    )
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(
        f'''package {NAMESPACE}

import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

class MainActivity : FlutterActivity() {{
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {{
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "{CHANNEL}"
        ).setMethodCallHandler {{ call, result ->
            if (call.method != "getIntegrityInfo") {{
                result.notImplemented()
                return@setMethodCallHandler
            }}

            try {{
                result.success(
                    mapOf(
                        "packageName" to applicationContext.packageName,
                        "debuggable" to isDebuggable(),
                        "signingSha256" to signingSha256()
                    )
                )
            }} catch (error: Exception) {{
                result.error(
                    "INTEGRITY_INFO_FAILED",
                    error.message,
                    null
                )
            }}
        }}
    }}

    private fun isDebuggable(): Boolean {{
        return (
            applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE
        ) != 0
    }}

    @Suppress("DEPRECATION")
    private fun signingSha256(): List<String> {{
        val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {{
            packageManager.getPackageInfo(
                packageName,
                PackageManager.GET_SIGNING_CERTIFICATES
            )
        }} else {{
            packageManager.getPackageInfo(
                packageName,
                PackageManager.GET_SIGNATURES
            )
        }}

        val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {{
            val signingInfo =
                packageInfo.signingInfo ?: return emptyList()
            val signerArray = if (signingInfo.hasMultipleSigners()) {{
                signingInfo.apkContentsSigners
            }} else {{
                signingInfo.signingCertificateHistory
            }}
            signerArray?.toList() ?: emptyList()
        }} else {{
            packageInfo.signatures?.toList() ?: emptyList()
        }}

        return signatures.map {{ signature ->
            MessageDigest.getInstance("SHA-256")
                .digest(signature.toByteArray())
                .joinToString("") {{ byte -> "%02X".format(byte) }}
        }}
    }}
}}
''',
        encoding="utf-8",
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--channel",
        choices=("public", "qa"),
        required=True,
    )
    args = parser.parse_args()

    for name in (
        "BREAKOUT_APP_SIGNING_KEYSTORE_PATH",
        "BREAKOUT_APP_SIGNING_STORE_PASSWORD",
        "BREAKOUT_APP_SIGNING_KEY_PASSWORD",
        "BREAKOUT_APP_SIGNING_KEY_ALIAS",
    ):
        require_env(name)

    android = Path("android")
    if not android.is_dir():
        stop("android/ was not generated before the release-security patch.")

    app_id = PUBLIC_ID if args.channel == "public" else QA_ID
    label = (
        "Breakout Addiction"
        if args.channel == "public"
        else "Breakout Addiction QA"
    )

    kts = android / "app/build.gradle.kts"
    groovy = android / "app/build.gradle"
    if kts.is_file():
        patch_kts(kts, app_id)
    elif groovy.is_file():
        patch_groovy(groovy, app_id)
    else:
        stop("android/app/build.gradle(.kts) was not found.")

    manifest = android / "app/src/main/AndroidManifest.xml"
    if not manifest.is_file():
        stop("AndroidManifest.xml was not found.")

    patch_manifest(manifest, label)
    write_main_activity(android)

    print(
        f"Configured Android {args.channel} release: "
        f"applicationId={app_id}, namespace={NAMESPACE}"
    )


if __name__ == "__main__":
    main()
