# Breakout Addiction Closed Testing / Release QA Pack

Status: Draft for Play Console internal/closed testing preparation.

## Purpose

This pack gives Breakout Addiction a practical release QA checklist before handing an AAB to Play Console testers.

The goal is not to add new features. The goal is to confirm the current build is safe, testable, private, and ready for internal or closed testing.

## Play Console testing reality

Google Play release/testing preparation should assume:

- Play release uploads use the Android App Bundle / AAB flow.
- Internal testing is useful for fast smoke testing.
- Closed testing may be required before production access depending on developer account type.
- New personal developer accounts may need at least 12 opted-in testers for 14 continuous days before applying for production access.
- Data Safety, App Content, privacy policy, app access instructions, and content rating should be prepared before closed/open/production review.
- New Android apps must target Android 15 / API level 35 or higher.

## Required artifact

Use the GitHub Actions artifact:

- breakout-addiction-aab

The APK is mainly for manual sideload testing.

## Fresh install smoke test

Pass criteria:

- App opens without crash.
- Home opens cleanly.
- Rescue opens quickly.
- Rescue urge intensity slider is interactive.
- Reasons to Stop works.
- Recovery Event Log can create, edit, delete, and undo where available.
- Privacy & Safety Center opens.
- App lock protects Home.
- Accountability Mode opens.
- Partner Access is read-only.
- No dev/demo/admin/config screen appears in normal public flow.
- No public hardcoded API key is visible.
- AI is disabled, local mock only, or guarded.
- VPN/Shield is not claimed as active in the first release.
- The app does not claim therapy, medical treatment, emergency care, or guaranteed recovery.

## Tester recruitment target

Minimum practical target:

- 12 Android testers
- 14 continuous days
- testers opted in through Play testing link
- private feedback collected through DM, email, form, or direct message

Better target:

- 20 to 30 testers invited
- at least 12 reliable testers confirmed
- 3 to 5 testers asked to do deeper QA

## Tester instructions draft

Use Breakout Addiction privately for a few minutes each day.

Please test:

- opening the app
- Rescue
- Reasons to Stop
- Recovery Event Log
- editing/deleting logs
- Privacy & Safety Center
- App Lock
- Accountability Mode
- reminders if enabled

Please report:

- crashes
- confusing wording
- buttons that do nothing
- anything that looks unfinished
- anything that feels too public or not private enough
- anything that feels shaming, harsh, or unsafe
- whether the app helped you find a next right action quickly

Safety note:

Breakout Addiction is a self-help recovery support app. It is not therapy, medical treatment, emergency care, or a crisis service.

## Founder / publisher handoff checklist

Before the founder/publisher uploads:

- Give them the latest green AAB artifact.
- Give them the privacy policy URL.
- Give them the Play Store Readiness Pack.
- Give them this QA Pack.
- Give them screenshots.
- Give them app access instructions.
- Give them tester list or tester email group.
- Tell them whether AI is enabled or disabled.
- Tell them whether app lock is enabled by default.
- Tell them not to mention VPN/Shield as an active feature.
- Tell them not to promise unlimited AI.
- Tell them not to describe the app as therapy or medical treatment.

## Play Console release notes draft

Initial closed testing build.

Includes:

- Rescue tools
- Reasons to Stop
- Recovery Event Log
- Mood and recovery tracking
- Privacy & Safety Center
- App lock support
- Accountability Mode foundation
- AAB release artifact support

Known testing focus:

- app lock behavior
- recovery logging
- edit/delete/undo
- reminder clarity
- privacy-sensitive wording
- accountability read-only view
- fresh install stability

## Manual QA signoff template

Build version:

AAB artifact name:

Git commit:

Git tag:

Tester/device:

Android version:

Date tested:

Pass/fail:

Notes:

## Stop-ship issues

Do not upload to closed testing if any of these are true:

- App crashes on first launch.
- Home cannot open.
- Rescue cannot open.
- Rescue urge intensity slider is disabled.
- Log cannot save.
- App lock traps the user permanently.
- Visible dev/demo/admin/config screen appears in normal public flow.
- Public hardcoded AI API key is visible.
- Real personal data appears in screenshots.
- Privacy policy is missing when required.
- Data Safety answers are unknown.
- App makes therapy, medical, emergency, or guaranteed recovery claims.
- AAB artifact is missing.
- Target SDK/API requirement is not satisfied.
