# Breakout Addiction Secure AI Gateway and Fair Use

## Production rule

The public APK and AAB must not contain a Gemini, Vertex, or other model-provider
API key. The app calls a Breakout-controlled HTTPS gateway configured at build
time:

```text
--dart-define=BREAKOUT_AI_GATEWAY_URL=https://example.com/v1/recovery/chat
```

The gateway stores provider credentials, authenticates requests, independently
verifies Plus AI entitlement, enforces abuse controls, applies the authoritative
safety policy, and limits cost. Client-supplied policy values are hints only and
must never override gateway policy.

## App authentication

Each request includes a short-lived backend-issued token:

```text
Authorization: Bearer <serviceAccessToken>
```

The purchase-verification backend issues this token only for a currently
verified Breakout Plus AI entitlement. The AI gateway validates the token,
expiration, audience, and Plus AI scope before processing any prompt.

## App request

```json
{
  "messages": [
    {"role": "user", "text": "I am stressed and drifting."}
  ],
  "userInput": "I am stressed and drifting.",
  "policy": {
    "systemInstruction": "<Breakout recovery policy>",
    "maxOutputTokens": 240,
    "temperature": 0.6
  }
}
```

The app sends only recent sanitized chat context. It does not send files,
grounding data, maps, exact location, or hidden session memory.

## Gateway response

```json
{
  "reply": "Name the pressure first, then choose one physical interruption."
}
```

HTTP 429 means the backend fair-use or abuse limit was reached.

## Fair-use model

The app presents Plus AI as generous recovery support subject to fair use, not
literally unlimited token consumption.

The app-side safety limit is currently 40 remote requests per UTC day and 1,500
characters per user message. The backend must independently enforce:

- verified Plus AI entitlement
- user and device abuse controls
- request-rate and daily/monthly cost budgets
- maximum context and output size
- model allowlist
- safety review and emergency redirection
- logging that avoids raw sensitive recovery content where possible

A user reaching an AI limit still has Immediate Rescue, local guidance, saved
plans, routines, reports, human support, and emergency information.

## Internal-only legacy providers

The old local API-key prototype and transport stubs remain internal QA code.
Public navigation defaults to the secure gateway and cannot use mock or legacy
prototype providers.
