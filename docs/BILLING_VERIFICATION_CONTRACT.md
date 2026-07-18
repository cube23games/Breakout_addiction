# Breakout Addiction Billing Verification Contract

The Android app never embeds Google Play Developer API credentials and never
treats SharedPreferences as proof of ownership.

## Build configuration

The signed public build receives an HTTPS endpoint through:

```text
--dart-define=BREAKOUT_BILLING_VERIFY_URL=https://example.com/v1/billing/verify
```

When the endpoint is absent or invalid, the purchase button remains disabled.
This is intentional fail-closed behavior.

## Request

```json
{
  "packageName": "com.slimnation.breakoutaddiction",
  "productId": "breakout_plus_monthly",
  "purchaseToken": "<Google Play purchase token>",
  "purchaseId": "<optional order or transaction id>",
  "transactionDate": "<optional store timestamp>",
  "source": "google_play"
}
```

## Successful response

```json
{
  "verified": true,
  "plan": "plus",
  "lifecycle": "active",
  "expiresAt": "2026-08-18T00:00:00Z",
  "serverAcknowledged": true,
  "serviceAccessToken": "<short-lived opaque or signed token>",
  "serviceAccessExpiresAt": "2026-07-19T00:00:00Z",
  "message": "Purchase verified."
}
```

Allowed plan values:

```text
plus
plusAi
```

Allowed lifecycle values:

```text
pending
active
canceledActive
gracePeriod
accountHold
expired
revoked
verificationUnavailable
```

The backend must use the Google Play Developer API to verify package name,
product, purchase token, acknowledgement state, expiration, cancellation,
linked purchase tokens, and current entitlement before returning `verified`.

The backend should acknowledge each new purchase token after entitlement is
recorded. If it returns `serverAcknowledged: false`, the app calls
`completePurchase` only after successful verification.

For Breakout Plus AI, the backend also issues a short-lived service-access token.
The app stores it in secure storage and sends it to the Breakout AI gateway as a
Bearer token. The AI gateway must validate that token and its Plus AI scope on
every request. A missing or expired service-access token blocks remote AI while
local recovery tools remain available.

## Rejected response

```json
{
  "verified": false,
  "message": "Purchase is invalid, expired, or does not match this app."
}
```

The app grants no paid access on a rejected, malformed, unavailable, or
non-HTTPS verification response. On public startup, the app asks Google Play
for owned purchases so active entitlements can be reverified before the
three-day offline verification window expires.
