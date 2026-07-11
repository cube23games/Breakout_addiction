# Breakout Addiction Premium QA and Value Matrix

## Current testing model

Breakout currently supports three local entitlement states:

- Standard
- Breakout Plus
- Breakout Plus AI

The QA entitlement override is available only in builds compiled with:

```text
BREAKOUT_QA_ENTITLEMENTS=true
```

It does not simulate billing, subscription renewal, cancellation, refunds, grace periods, or Google Play purchases.

Normal release builds default new users to Standard and hide the QA selector.

## Current implementation reality

### Standard currently includes

- Rescue tools
- Urge intensity slider
- Delay timer
- Breathing exercise
- Reasons to Stop
- Recovery logging
- Support resources
- Privacy and Safety Center
- App lock
- Basic quotes and preferences

These core recovery and safety features should remain available without payment.

### Breakout Plus currently adds

- Curated local premium guidance
- Pattern-aware local guidance packs
- Faith-sensitive local guidance packs
- A premium experience that does not require AI

Current assessment: Plus needs more implemented value before public paid launch.

### Breakout Plus AI currently adds

- AI chat entitlement
- Mock and local AI testing paths
- Guarded prototype provider paths
- AI safety and usage gates

Current assessment: Plus AI is suitable for internal testing, but production remote AI still requires a private backend or proxy, billing controls, quotas, privacy disclosures, and abuse protection.

## Recommended tier boundaries

### Standard

Keep these accessible:

- Immediate Rescue access
- Basic breathing
- Basic delay actions
- Basic Reasons to Stop
- Basic recovery logging
- Privacy and safety information
- Human support access
- Emergency and crisis guidance
- App lock
- Basic encouragement

### Breakout Plus

Recommended paid depth:

- Full personalized delay-card library
- Recovery, motivational, and faith-sensitive card packs
- Advanced insights and longer trend history
- Advanced risk-window tools
- Deeper accountability summaries
- Advanced reminder schedules
- Premium local guidance packs
- Additional personalization and themes
- Data export and richer progress summaries

### Breakout Plus AI

Recommended AI value:

- Everything in Breakout Plus
- AI recovery chat
- AI-personalized delay cards
- AI-assisted reflection summaries
- AI pattern and risk-window observations
- AI-generated next-step suggestions
- Fair-use limits and a transparent usage meter

## What not to paywall

Do not place these behind payment:

- Immediate Rescue access
- Basic breathing
- Basic delay tools
- Basic logging
- Privacy information
- Human support access
- Crisis or emergency information
- Ability to delete personal data

## Testing questions

For each tier, verify:

- Does the tier feel clearly different?
- Is the upgrade explanation honest?
- Does Standard remain genuinely useful?
- Does Plus provide enough non-AI value?
- Does Plus AI add convenience and personalization rather than replacing safety?
- Are locked features clearly labeled?
- Are QA entitlement controls absent from normal release builds?

## Public launch blockers

Do not sell premium publicly until:

- Google Play Billing or another approved billing system is implemented.
- Entitlements come from verified purchases rather than local preferences.
- Restore Purchases exists.
- Subscription cancellation and renewal behavior is handled.
- Premium access survives reinstall or account restoration appropriately.
- Plus has enough implemented non-AI value.
- Plus AI has production-safe backend infrastructure.
