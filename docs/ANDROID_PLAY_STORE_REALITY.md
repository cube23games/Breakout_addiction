# Breakout Addiction Android / Play Store Reality Pass

## Current Android build reality

Breakout Addiction does not currently commit a full Android platform folder.

The CI workflow creates Android platform files when missing:

flutter create --platforms=android --project-name breakout_addiction .

This is acceptable for current Flutter CI builds, but it means native Android changes are not durable unless they are either committed into an Android platform folder or re-applied in CI every build.

## Current artifacts

CI should produce two artifacts:

- breakout-addiction-apk for direct/manual Android testing
- breakout-addiction-aab for Play Console release tracks

The APK is useful for installing and smoke testing on a phone. The AAB is the Play Store upload artifact.

## Current app version

pubspec.yaml currently uses:

version: 0.1.0+1

Before public release, confirm:

- final package/applicationId
- final app display name
- versionName/versionCode progression
- release signing / Play App Signing flow
- privacy policy URL
- Data Safety answers
- app access instructions if lock/login flows are enabled

## Native Android feature caution

Features that require native Android files need an explicit platform strategy before implementation.

Examples:

- real home screen widget provider
- notification boot persistence receivers
- exact alarm permission handling
- VPN / Breakout Shield service
- native deep link intent filters
- Android manifest permissions

## Widget reality

The current Widget Preview is an in-app preview/demo concept. It is not the same as a real Android home screen widget.

A real Lifeline Widget will require native Android widget/provider files or a maintained Flutter/native widget bridge.

## Recommended release path

1. Keep CI producing APK and AAB.
2. Use APK for phone smoke tests.
3. Use AAB for Play Console internal/closed testing.
4. Delay VPN/Shield until after first release.
5. Decide whether to commit Android platform files before building native widgets.
