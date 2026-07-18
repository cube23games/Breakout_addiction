# BA-57/58 Security and Update Foundation

## Permanent Android identity
- Public package: `com.slimnation.breakoutaddiction`
- QA package: `com.slimnation.breakoutaddiction.qa`
- Both use the same permanent private signing key.
- QA installs separately and cannot overwrite the public package.

## Paid-access policy
Public builds no longer trust a local SharedPreferences plan value as a paid
entitlement. Local plan switching remains available only in the isolated QA
package when its QA compile-time flag is also present.

## Local integrity guard
Android reports the installed package name, debuggable state, and SHA-256
signing-certificate fingerprints through a generated MethodChannel. Release
builds compare them with compile-time trusted values.

A mismatch shows `App alteration detected` and disables premium access while
keeping Rescue and core recovery tools available.

## Security boundary
Client-side checks are tamper resistance, not an impossible-to-bypass
guarantee. Public purchase authority must ultimately use Google Play Billing
verification on a secure backend plus Play Integrity verdict evaluation.

## Play App Signing
When Play App Signing is enabled, add its app-signing certificate SHA-256
fingerprint to `BREAKOUT_PLAY_SIGNING_CERT_SHA256`.

## Update proof
Each green CI run builds a public baseline APK and a public update APK with
the same package and certificate but consecutive version codes. Install the
baseline, create test data, and then install the update over it.
