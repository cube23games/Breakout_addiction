# Breakout Addiction Play Store Readiness Pack

Status: Draft for internal/closed testing preparation.

This pack prepares the Play Console listing, review notes, tester instructions, privacy-policy notes, Data Safety draft, and screenshot checklist for Breakout Addiction.

## 1. Store listing draft

### App name

Breakout Addiction

### Short description

A private recovery app with fast rescue tools, logs, reflection, and optional support features.

### Full description

Breakout Addiction is a privacy-conscious recovery support app designed to help users interrupt urges, reflect on patterns, and build a stronger recovery routine.

The app gives users fast access to rescue tools, personal reasons to stop, recovery logging, education, support resources, reminders, privacy controls, and optional accountability features.

Breakout Addiction is built around a simple idea: when the hard moment hits, help needs to be close, private, and easy to use.

Core features include:

- Rescue flow for urgent moments
- Personal Reasons to Stop
- Recovery event logging
- Mood and cycle tracking
- Risk window awareness
- Educational recovery content
- Support contact tools
- Privacy and safety settings
- Optional app lock
- Optional accountability partner summary
- Optional Christian support content
- Optional AI recovery coach prototype guardrails for supported builds

Breakout Addiction is not a medical device, emergency service, therapy replacement, or crisis response tool. It is a self-help and recovery support app.

If you are in immediate danger, considering self-harm, or experiencing an emergency, contact emergency services or a qualified crisis support resource.

### Suggested category

Health & Fitness

Alternate category to evaluate:

- Lifestyle

### Tags / keyword ideas

recovery, addiction recovery, habit change, urge support, accountability, privacy, self help, wellness, reflection, support

## 2. What's new draft

Initial internal testing release.

This build includes:

- Rescue tools
- Recovery logging
- Reasons to Stop
- Privacy and Safety Center
- App lock support
- Accountability Mode foundation
- Android APK and AAB build outputs

## 3. Privacy policy notes

A hosted privacy policy URL is required before release/testing submission.

Suggested privacy policy points:

- Breakout Addiction stores sensitive recovery-related information.
- Most MVP recovery data is stored locally on the user's device.
- The app may store logs, moods, reasons to stop, risk windows, support contacts, recovery plans, lock settings, accountability settings, and preferences.
- The app should not sell personal data.
- The app should not share recovery logs with advertisers.
- Accountability sharing is user-controlled.
- AI features, if enabled, may send user-entered text to an AI service or backend proxy for response generation.
- AI should be optional and clearly disclosed before public use.
- Users should avoid entering emergency, medical, legal, or highly identifying information into AI chat.
- The app may use basic technical data through Google Play, Android, and crash/reporting systems depending on release configuration.
- Users can delete/reset local app data through app/device settings.
- The app is not a medical provider, therapy provider, emergency service, or crisis hotline.

Privacy policy TODOs before submission:

- Add final company/developer name.
- Add contact email.
- Add hosted URL.
- Confirm whether analytics/crash reporting SDKs are included.
- Confirm whether AI is enabled, disabled, local mock only, or backend-proxied.
- Confirm whether any email capture is active.
- Confirm whether notifications are used.
- Confirm whether accountability mode remains local-device only.
- Confirm whether future VPN/Shield is excluded from first release.

## 4. Data Safety draft

Important: This is a draft. Final answers must match the actual shipped build and privacy policy.

### Data collected

Likely yes, if stored or processed by the app:

- Health and fitness / wellness-related recovery information
- App activity / in-app interactions
- User-provided content such as reasons, logs, notes, plans, and support settings
- Contact information only if the app collects email/contact fields or sends user-provided contact data
- Device or app diagnostics only if analytics/crash reporting is enabled

Likely no for first public MVP unless added later:

- Precise location
- Financial information
- Photos/videos uploaded to a server
- Browsing history
- Contacts address book upload
- Advertising ID for ad targeting
- VPN traffic logs
- Full AI chat sharing with accountability partners

### Data shared

Likely no by default for local-only MVP recovery logs.

Possible sharing only if enabled:

- AI prompt/response data may be sent to an AI provider or backend proxy if remote AI is enabled.
- Email capture may send user-provided email data to the configured email/contact system.
- Google Play may process app distribution, purchase, crash, diagnostic, and account-related platform data outside the app.

### Security practices

Recommended final disclosures:

- Data is encrypted in transit if remote services are used.
- Sensitive local data should be protected where supported.
- Users can request or perform data deletion depending on final storage design.
- Recovery data is not used for third-party advertising.

### Data Safety TODOs

Before Play submission, confirm:

- Is AI remote disabled for public build?
- Is email capture enabled?
- Are push/local notifications enabled?
- Is Firebase, analytics, crash reporting, ads, billing, or attribution included?
- Is any data sent to a backend?
- Is any data shared with accountability partners remotely?
- Does the app collect a user account login?
- Does the app collect payments or subscriptions?
- Does the app collect uploaded images?
- Does the app use device identifiers?

## 5. App access instructions draft

Use this if Play review needs access to locked/restricted areas.

### Reviewer instructions

Breakout Addiction may include app lock and accountability flows.

For review access:

1. Open the app.
2. Choose the main recovery-user path if prompted.
3. If a passcode is requested, use the test passcode provided in Play Console notes.
4. Visit Home, Rescue, Log, Educate Me, Support, Settings, Privacy & Safety, and Accountability Mode.
5. Accountability Partner Access is read-only and requires a separate partner passcode if enabled.
6. AI features may be disabled, local mock only, or prototype-guarded depending on build configuration.

### Test credentials placeholder

Main app passcode:

TODO

Accountability partner passcode:

TODO

Test email/account, if required:

TODO

### Review note

Breakout Addiction is a self-help recovery support app. It does not provide emergency services, medical diagnosis, therapy, or crisis intervention.

## 6. Closed/internal tester instructions

### Tester goal

Use the app like a real recovery support tool for a few minutes per day.

### What to test

- First launch and onboarding
- Rescue flow
- Reasons to Stop
- Recovery Event Log
- Mood/cycle logging
- Risk windows
- Support resources
- Privacy & Safety Center
- App lock
- Accountability Mode settings
- Accountability Partner Access summary
- Notifications/reminders if enabled
- Any AI surfaces if enabled for the test build

### What feedback we need

- What feels confusing?
- What feels helpful?
- What feels too intense or too weak?
- Did any private/sensitive wording appear where it should not?
- Did app lock behave correctly?
- Did recovery logs save correctly?
- Did edit/delete work correctly?
- Did the app ever crash, freeze, or lose data?
- Did anything look unprofessional in screenshots?

### Tester safety note

This app is for support and reflection only. It is not emergency care, therapy, or medical treatment. If a tester is in immediate danger or crisis, they should contact emergency services or crisis support.

## 7. Screenshot checklist

Recommended screenshots for Play listing:

1. Home / Recovery dashboard
2. Rescue flow start
3. Rescue action screen
4. Reasons to Stop
5. Recovery Event Log
6. Mood or cycle tracking
7. Educate Me / learning content
8. Support screen
9. Privacy & Safety Center
10. Accountability Mode settings or read-only partner summary

Screenshot rules:

- Do not show real user data.
- Do not show real phone numbers.
- Do not show real emails.
- Do not show API keys.
- Do not show backend/provider configuration.
- Do not show dev/demo/admin screens.
- Use clean sample data only.
- Prefer Discreet Mode language where possible.
- Avoid screenshots that imply therapy, diagnosis, emergency response, or guaranteed outcomes.

## 8. Launch readiness checklist

Before Play Console submission:

- BA-43 AAB artifact is green.
- AAB downloaded from GitHub Actions.
- Release signing / Play App Signing flow confirmed.
- Version code/version name confirmed.
- Privacy policy URL live.
- Data Safety form completed.
- App access instructions completed.
- Store listing completed.
- Screenshots prepared.
- Content rating completed.
- Target audience completed.
- Ads declaration completed.
- Sensitive permissions reviewed.
- AI public behavior confirmed.
- VPN/Shield excluded from first release.
- Accountability Mode reviewed for privacy.
- Manual smoke test completed from fresh install.
- Closed/internal testing path selected.

## 9. First-release risk notes

Do not ship first public release with:

- public hardcoded AI API keys
- visible backend/API config screens
- visible dev/demo/admin screens
- VPN/Shield claims before implementation
- unlimited AI promises
- emergency-service language
- therapy/diagnosis claims
- real user data in screenshots

## 10. Suggested Play Console review note

Breakout Addiction is a self-help recovery support app. It provides private reflection tools, urge interruption support, logging, education, and optional accountability features.

The app is not a medical device, therapy provider, emergency service, or crisis hotline.

Some features may be protected by app lock or accountability passcode flows. Test access instructions and passcodes are provided in the App access section of Play Console.

