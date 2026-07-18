# Breakout Addiction Premium QA and Value Matrix

## Locked product principles

- Immediate Rescue, basic logging, privacy, human support, emergency information,
  and personal-data deletion are never paywalled.
- Breakout Plus must be valuable without AI or token costs.
- Breakout Plus AI includes everything in Plus and adds optional AI
  personalization.
- Public entitlements must come from verified purchases, never a local toggle.
- App-integrity failure disables paid features but never disables core recovery.
- AI is recovery support, not therapy, diagnosis, or emergency care.
- AI access is generous for ordinary recovery use and subject to fair use.

## Standard

- Immediate Rescue
- Urge intensity, delay, breathing, Reasons to Stop, and next safe actions
- Basic recovery, mood, and cycle-stage logging
- Basic encouragement
- Privacy and Safety Center
- App Lock
- Human and emergency support
- Ability to delete personal data

## Breakout Plus

- Private 30- and 90-day insights, direction, and repeated-trigger review
- Advanced risk-window tools and local reminders
- Recovery-plan integration across routines and reports
- Guided recovery routines
- Secular and optional Christian recovery journeys
- Pattern-aware local guidance
- Expanded encouragement and faith-sensitive packs
- Educate Me Plus
- Privacy-controlled accountability summaries
- Recovery reports and approved sharing
- Expanded personalization and widget options

## Breakout Plus AI

Everything in Breakout Plus, plus:

- AI recovery chat
- AI-personalized Rescue guidance while core Rescue stays free
- AI recovery-plan assistance
- AI pattern interpretation
- AI weekly reviews
- AI-assisted reflection
- AI-adaptive routines and journeys
- AI accountability drafting that the user reviews before sharing
- AI-personalized encouragement without invented quotations
- Optional faith-sensitive AI reflection when the faith layer is chosen
- AI report interpretation that separates user-provided facts from suggestions
- Transparent fair-use status and local fallback guidance

## QA entitlement model

The QA override is available only when both are true:

```text
BREAKOUT_BUILD_CHANNEL=qa
BREAKOUT_QA_ENTITLEMENTS=true
```

It validates feature gating only. It does not simulate Play Billing.

## Public launch blockers

- Google Play subscription products and active base plans
- Product identifiers matching the app catalog
- Purchase, acknowledgement, restore, and lifecycle handling
- Secure server-side purchase verification
- Play internal-testing and license-tester validation
- Secure AI gateway with no provider secret in the APK
- Backend-enforced fair-use and abuse controls
- Tier-by-tier device QA
