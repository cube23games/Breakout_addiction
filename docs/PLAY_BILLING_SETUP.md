# Breakout Addiction Google Play Billing Setup

## Permanent Android identity

```text
com.slimnation.breakoutaddiction
```

## Subscription product identifiers

Create these exact subscription products in Google Play Console:

```text
breakout_plus_monthly
breakout_plus_ai_monthly
```

Each product needs an active monthly auto-renewing base plan before Play can return
localized product details to the app.

Suggested initial U.S. prices discussed during planning:

- Breakout Plus: $9.99/month
- Breakout Plus AI: $14.99/month

Google Play Console remains the source of truth for pricing. The app displays the
localized price returned by Play rather than hard-coding a currency amount.

## Required Play test sequence

1. Upload the signed public AAB to Internal testing.
2. Create and activate both subscription products and base plans.
3. Add license testers.
4. Install from the Play internal-testing link.
5. Confirm both products load.
6. Test purchase, pending payment, cancellation, upgrade, downgrade, restore,
   grace period, account hold, and expiration.
7. Confirm purchase tokens are verified by the secure backend before access is
   granted.
8. Confirm each new purchase token is acknowledged only after verification.

The QA entitlement override does not replace this sequence.
