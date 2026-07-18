# BA-64 Premium Device QA Checklist

Use the QA APK first. Record PASS or FAIL and capture screenshots only when a
failure needs evidence. Never use a real payment method in QA simulation.

## Standard

- Set QA tier to Standard and clear simulated billing.
- Rescue opens and completes normally.
- Basic logging saves and can be edited/deleted.
- Privacy, Lock Mode, human support, and data deletion remain available.
- Premium Tools route shows an upgrade gate.
- Educate Me shows Plus tracks locked.
- AI coach explains why it is unavailable.

## Breakout Plus

- Simulate a Plus purchase and confirm Plus becomes active.
- Open Premium Tools.
- Open Local Recovery Guidance, add a new log, refresh, and confirm guidance remains local and updates from current data.
- Open Advanced Insights and verify the 30- and 90-day counts against known test logs.
- Complete/reset steps in every guided routine.
- Complete/reset secular journey steps.
- Toggle faith layer and confirm Christian journey visibility follows it.
- Open Educate Me Plus lessons.
- Save Premium Preferences and reopen the screen.
- Change widget focus and confirm Widget Preview content changes.
- Generate concise and detailed recovery reports.
- Copy a report and confirm the privacy warning appears.
- Confirm AI Personalization Tools remain locked.

## Breakout Plus AI

- Simulate a Plus AI purchase and confirm Plus features remain available.
- Open every AI Personalization Tool, including Rescue, encouragement, optional faith, and report interpretation, and confirm its starter prompt is loaded.
- In QA mock mode, send a safe non-identifying prompt.
- Confirm blocked content is stopped by guardrails.
- Confirm fair-use remaining count changes for remote-mode tests.
- Confirm AI outage/limit messaging points back to local tools and human support.

## Subscription lifecycle

For both Plus and Plus AI, simulate each state:

- Active: access granted.
- Canceled-active: access retained until verified expiration.
- Grace period: access retained with honest status.
- Pending: no paid access.
- Account hold: no paid access.
- Expired: no paid access.
- Revoked: no paid access.
- Verification unavailable: no new paid access.

## Integrity and update regression

- Integrity failure disables paid tools but leaves core Rescue available.
- Install the public baseline APK.
- Create representative free and premium-local data.
- Install the public update APK over it without uninstalling.
- Confirm local data survives and Android accepts the signature/update chain.

## Real Google Play internal test

Complete only after Play products, backend verification, and testers exist:

- Product titles and localized prices load from Google Play.
- Plus purchase verifies and unlocks only after completion.
- Plus AI purchase verifies and unlocks only after completion.
- Pending payment never unlocks.
- Automatic startup refresh and manual Restore both recover verified access after reinstall and on another licensed test device/account.
- Upgrade and downgrade use the intended Play replacement behavior.
- Cancellation, grace, hold, expiration, and revocation match backend truth.
- Subscription management opens the correct Play page.
- No provider API key or purchase-verification credential appears in APK/AAB.
