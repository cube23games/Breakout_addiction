#!/usr/bin/env python3
from __future__ import annotations

import argparse
import os
import re
import shutil
import subprocess
from pathlib import Path


def stop(message: str) -> None:
    raise SystemExit(message)


def run(command: list[str]) -> str:
    result = subprocess.run(
        command,
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        stop(
            f"Command failed ({result.returncode}): {' '.join(command)}\n"
            f"{result.stdout}{result.stderr}"
        )
    return result.stdout + result.stderr


def latest_tool(name: str) -> str:
    direct = shutil.which(name)
    if direct:
        return direct

    sdk = Path(
        os.environ.get("ANDROID_HOME")
        or os.environ.get("ANDROID_SDK_ROOT")
        or ""
    )
    candidates = list(sdk.glob(f"build-tools/*/{name}"))
    if not candidates:
        stop(f"Android SDK tool was not found: {name}")

    def version_key(path: Path):
        parts = re.split(r"[.-]", path.parent.name)
        return tuple(int(part) if part.isdigit() else part for part in parts)

    candidates.sort(key=version_key)
    return str(candidates[-1])


def normalize(value: str) -> str:
    return re.sub(r"[^A-Fa-f0-9]", "", value).upper()


def extract_apk_certificate_sha256(output: str, path: Path) -> str:
    marker = "certificate SHA-256 digest:"

    for line in output.splitlines():
        if marker not in line:
            continue

        candidate = normalize(line.split(marker, 1)[1])
        if len(candidate) == 64:
            return candidate

    stop(
        f"Could not read APK signing certificate from {path}.\n"
        f"apksigner output:\n{output}"
    )


def verify_apk(
    path: Path,
    expected_package: str,
    expected_version_code: int,
    expected_cert: str,
) -> None:
    aapt = latest_tool("aapt")
    apksigner = latest_tool("apksigner")

    badging = run([aapt, "dump", "badging", str(path)])
    match = re.search(
        r"package: name='([^']+)' versionCode='([^']+)'",
        badging,
    )
    if not match:
        stop(f"Could not read package/version from {path}.")

    package_name = match.group(1)
    version_code = int(match.group(2))

    if package_name != expected_package:
        stop(
            f"APK package mismatch: expected {expected_package}; "
            f"found {package_name}"
        )
    if version_code != expected_version_code:
        stop(
            f"APK versionCode mismatch: expected {expected_version_code}; "
            f"found {version_code}"
        )

    cert_output = run(
        [apksigner, "verify", "--print-certs", str(path)]
    )
    actual = extract_apk_certificate_sha256(cert_output, path)
    expected = normalize(expected_cert)
    if actual != expected:
        stop(
            "APK signing certificate mismatch: "
            f"expected {expected}; found {actual}"
        )

    print(
        f"PASS: {path.name} package={package_name} "
        f"versionCode={version_code} cert={actual}"
    )


def verify_aab(path: Path, expected_cert: str) -> None:
    jarsigner = shutil.which("jarsigner")
    keytool = shutil.which("keytool")
    if not jarsigner or not keytool:
        stop("jarsigner and keytool are required for AAB verification.")

    run([jarsigner, "-verify", str(path)])
    output = run([keytool, "-printcert", "-jarfile", str(path)])
    match = re.search(r"SHA256:\s*([A-Fa-f0-9:]+)", output)
    if not match:
        stop(f"Could not read AAB signing certificate from {path}.")

    actual = normalize(match.group(1))
    expected = normalize(expected_cert)
    if actual != expected:
        stop(
            "AAB signing certificate mismatch: "
            f"expected {expected}; found {actual}"
        )

    print(f"PASS: {path.name} cert={actual}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--artifact", required=True)
    parser.add_argument("--expected-cert", required=True)
    parser.add_argument("--expected-package")
    parser.add_argument("--expected-version-code", type=int)
    args = parser.parse_args()

    path = Path(args.artifact)
    if not path.is_file():
        stop(f"Artifact was not found: {path}")

    if path.suffix == ".apk":
        if not args.expected_package or args.expected_version_code is None:
            stop("APK verification requires package and version code.")
        verify_apk(
            path,
            args.expected_package,
            args.expected_version_code,
            args.expected_cert,
        )
    elif path.suffix == ".aab":
        verify_aab(path, args.expected_cert)
    else:
        stop(f"Unsupported artifact type: {path.suffix}")


if __name__ == "__main__":
    main()
