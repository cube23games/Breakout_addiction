# Breakout Addiction Premium Implementation Map

## Standard — free and safety-preserving

The following remain available without a purchase and remain available when
paid entitlement or app-integrity verification fails:

- Immediate Rescue and urge interruption
- Basic mood, cycle-stage, urge, victory, and slip logging
- Human, professional, and emergency support
- Privacy and Safety Center, Lock Mode, and data deletion

## Breakout Plus — local value without AI

| Feature | Implementation |
| --- | --- |
| Pattern-aware local guidance | Dedicated Plus screen generated locally from current insights, pressure drivers, encouragement, and optional faith settings |
| Expanded encouragement and faith-sensitive packs | Local Plus guidance includes practical encouragement and an optional Christian reflection without a cloud call |
| Educate Me Plus | Two locked deeper tracks with five Plus lessons |
| Guided routines | Four routines with on-device progress and reset |
| Recovery journeys | Secular and optional Christian journeys with progress |
| Recovery-plan integration | Existing saved plan is incorporated into premium reports and linked from Premium Tools |
| Advanced insights | Dedicated on-device 30- and 90-day trend screen with counts, pressure context, repeated trigger, period direction, and next focus |
| Advanced risk windows | Existing local window/reminder tools linked from Premium Tools |
| Accountability | Existing privacy-controlled accountability tools linked from Premium Tools |
| Recovery reports | Concise or detailed private report with explicit copy action |
| Expanded personalization | Routine focus, report detail, and widget focus preferences |
| Enhanced widget options | Premium widget focus changes real widget snapshot content and includes preview |

## Breakout Plus AI — Plus plus secure optional AI

- Secure AI recovery chat through `BREAKOUT_AI_GATEWAY_URL`
- Recovery-plan helper
- Non-shaming pattern reflection
- Weekly recovery review
- Accountability-message drafting
- High-risk-window preparation
- Rescue personalization while core Rescue remains free
- Personalized encouragement without invented quotes
- Optional faith-sensitive reflection
- Report-interpretation helper
- App-side fair-use visibility and bounded input
- Backend 429 handling and local recovery fallback

The AI tool cards provide reviewable starter prompts. They never send a message
or contact a person without the user opening the coach and choosing to send.

## External launch configuration still required

Repository implementation cannot replace these controlled external systems:

- Active Play Console subscriptions/base plans for both product IDs
- Google Play license testers and internal-testing installation
- HTTPS purchase-verification service using the Play Developer API
- Subscription lifecycle/RTDN processing on that backend
- HTTPS AI gateway with backend-enforced fair use and abuse controls

Public purchase buttons fail closed until the verification URL is configured.
Public AI fails closed until the AI gateway URL is configured. QA builds use
compile-time, channel-gated simulations and never make a real charge.
