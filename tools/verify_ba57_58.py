#!/usr/bin/env python3
from __future__ import annotations

import importlib.util
import os
import subprocess
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
errors: list[str] = []


def require(path: str, snippets: list[str]) -> None:
    target = ROOT / path
    if not target.is_file():
        errors.append(f"missing file: {path}")
        return
    text = target.read_text(encoding="utf-8")
    for snippet in snippets:
        if snippet not in text:
            errors.append(f"{path} missing: {snippet}")


require("pubspec.yaml", ["version: 0.1.0+2"])
require(".gitignore", ["*.p12", "*.jks", "android/key.properties"])
require(
    "lib/main.dart",
    [
        "AppIntegrityController.instance.start()",
        "addPostFrameCallback",
        "_initializeNotificationsSafely",
    ],
)
require(
    "lib/app/breakout_app.dart",
    ["AppIntegrityBanner", "builder: (context, child)"],
)
require(
    "lib/app/config/qa_entitlement_gate.dart",
    [
        "BREAKOUT_QA_ENTITLEMENTS",
        "BREAKOUT_BUILD_CHANNEL",
        "_requested && _buildChannel == 'qa'",
    ],
)
require(
    "lib/features/premium/data/premium_access_repository.dart",
    [
        "PremiumPlan plan = PremiumPlan.none",
        "QaEntitlementGate.enabled && integrity.allowsPaidFeatures",
        "Local premium plan writes are disabled in public builds.",
        "setUpgradePrompts",
    ],
)
require(
    "lib/core/integrity/app_integrity_service.dart",
    [
        "BREAKOUT_EXPECTED_PACKAGE",
        "BREAKOUT_ALLOWED_SIGNING_SHA256",
        "AppIntegrityState.altered",
        "signingSha256",
        "!kReleaseMode",
    ],
)
require(
    "lib/core/integrity/app_integrity_banner.dart",
    [
        "App alteration detected",
        "premium features are disabled",
        "Rescue and core recovery tools stay available",
    ],
)
require(
    "tools/patch_android_release_security.py",
    [
        "com.slimnation.breakoutaddiction",
        'QA_ID = f"{PUBLIC_ID}.qa"',
        "BREAKOUT_APP_SIGNING_KEYSTORE_PATH",
        "GET_SIGNING_CERTIFICATES",
        "MethodChannel",
        "packageInfo.signingInfo ?: return emptyList()",
        "signerArray?.toList() ?: emptyList()",
        "packageInfo.signatures?.toList() ?: emptyList()",
        "--channel",
    ],
)
require(
    "tools/verify_android_release_artifact.py",
    [
        "def extract_apk_certificate_sha256",
        'marker = "certificate SHA-256 digest:"',
        "line.split(marker, 1)[1]",
        "if len(candidate) == 64",
        "apksigner output:",
    ],
)
require(
    ".github/workflows/ci.yml",
    [
        "BREAKOUT_APP_SIGNING_KEYSTORE_BASE64",
        "BREAKOUT_APP_SIGNING_CERT_SHA256",
        "BREAKOUT_PLAY_SIGNING_CERT_SHA256",
        "--channel qa",
        "--channel public",
        "BREAKOUT_QA_ENTITLEMENTS=true",
        "BREAKOUT_BUILD_CHANNEL=qa",
        "breakout-addiction-public-baseline.apk",
        "breakout-addiction-public-update.apk",
        "verify_android_release_artifact.py",
    ],
)

if (ROOT / "android").exists():
    errors.append("local android/ must remain absent from the repository")

patcher = ROOT / "tools/patch_android_release_security.py"
if patcher.is_file():
    with tempfile.TemporaryDirectory() as temp:
        work = Path(temp)
        env = os.environ.copy()
        env.update(
            {
                "BREAKOUT_APP_SIGNING_KEYSTORE_PATH": "/tmp/test.p12",
                "BREAKOUT_APP_SIGNING_STORE_PASSWORD": "test",
                "BREAKOUT_APP_SIGNING_KEY_PASSWORD": "test",
                "BREAKOUT_APP_SIGNING_KEY_ALIAS": "test",
            }
        )

        for mode in ("kts", "groovy"):
            case = work / mode
            app = case / "android/app"
            manifest = app / "src/main/AndroidManifest.xml"
            manifest.parent.mkdir(parents=True, exist_ok=True)
            manifest.write_text(
                '<manifest xmlns:android="http://schemas.android.com/apk/res/android">'
                '<application android:label="breakout_addiction" '
                'android:name="${applicationName}">'
                '<activity android:name=".MainActivity"/></application></manifest>',
                encoding="utf-8",
            )

            source = (
                app
                / "src/main/kotlin/com/example/breakout_addiction/MainActivity.kt"
            )
            source.parent.mkdir(parents=True, exist_ok=True)
            source.write_text(
                "package com.example.breakout_addiction\n"
                "import io.flutter.embedding.android.FlutterActivity\n"
                "class MainActivity: FlutterActivity()\n",
                encoding="utf-8",
            )

            if mode == "kts":
                gradle = app / "build.gradle.kts"
                gradle.write_text(
                    'android {\n'
                    '    namespace = "com.example.breakout_addiction"\n'
                    '    compileOptions {\n'
                    '    }\n'
                    '    defaultConfig {\n'
                    '        applicationId = "com.example.breakout_addiction"\n'
                    '    }\n'
                    '    buildTypes {\n'
                    '        release {\n'
                    '            signingConfig = signingConfigs.getByName("debug")\n'
                    '        }\n'
                    '    }\n'
                    '}\n',
                    encoding="utf-8",
                )
            else:
                gradle = app / "build.gradle"
                gradle.write_text(
                    'android {\n'
                    '    namespace "com.example.breakout_addiction"\n'
                    '    compileOptions {\n'
                    '    }\n'
                    '    defaultConfig {\n'
                    '        applicationId "com.example.breakout_addiction"\n'
                    '    }\n'
                    '    buildTypes {\n'
                    '        release {\n'
                    '            signingConfig signingConfigs.debug\n'
                    '        }\n'
                    '    }\n'
                    '}\n',
                    encoding="utf-8",
                )

            result = subprocess.run(
                [
                    "python3",
                    str(patcher),
                    "--channel",
                    "public",
                ],
                cwd=case,
                env=env,
                text=True,
                capture_output=True,
                check=False,
            )
            if result.returncode != 0:
                errors.append(
                    f"patcher synthetic {mode} test failed: "
                    f"{result.stdout}{result.stderr}"
                )
                continue

            updated = gradle.read_text(encoding="utf-8")
            if "com.slimnation.breakoutaddiction" not in updated:
                errors.append(
                    f"patcher {mode} did not set permanent identity"
                )
            if (
                "signingConfigs.getByName(\"release\")" not in updated
                and "signingConfig signingConfigs.release" not in updated
            ):
                errors.append(
                    f"patcher {mode} did not set release signing"
                )

            generated = (
                app
                / "src/main/kotlin/com/slimnation/"
                "breakoutaddiction/MainActivity.kt"
            )
            if not generated.is_file():
                errors.append(
                    f"patcher {mode} did not generate MainActivity"
                )
            else:
                generated_text = generated.read_text(encoding="utf-8")
                for snippet in (
                    "packageInfo.signingInfo ?: return emptyList()",
                    "signerArray?.toList() ?: emptyList()",
                    "packageInfo.signatures?.toList() ?: emptyList()",
                ):
                    if snippet not in generated_text:
                        errors.append(
                            f"patcher {mode} generated unsafe signing lookup: "
                            f"missing {snippet}"
                        )


artifact_verifier = ROOT / "tools/verify_android_release_artifact.py"
if artifact_verifier.is_file():
    spec = importlib.util.spec_from_file_location(
        "verify_android_release_artifact",
        artifact_verifier,
    )
    if spec is None or spec.loader is None:
        errors.append("could not import Android artifact verifier")
    else:
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)

        parser_cases = {
            (
                "Signer #1 certificate SHA-256 digest: "
                + "AB" * 32
            ): "AB" * 32,
            (
                "Signer (minSdkVersion=24, maxSdkVersion=32) "
                "certificate SHA-256 digest: "
                + "CD" * 32
            ): "CD" * 32,
        }

        for output, expected in parser_cases.items():
            actual = module.extract_apk_certificate_sha256(
                output,
                Path("synthetic.apk"),
            )
            if actual != expected:
                errors.append(
                    "APK certificate parser rejected a supported "
                    "apksigner signer label"
                )

if errors:
    print("BA-57/58 verification failed:")
    for error in errors:
        print(f" - {error}")
    raise SystemExit(1)

print(
    "BA-57/58 verification passed: permanent public and isolated QA "
    "identities, release signing, monotonic update artifacts, local package/"
    "certificate integrity checks, fail-closed public premium state, Rescue-"
    "preserving alteration messaging, and CI artifact verification are wired."
)
