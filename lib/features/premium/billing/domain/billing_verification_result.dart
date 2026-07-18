import 'verified_entitlement.dart';

class BillingVerificationResult {
  final bool verified;
  final VerifiedEntitlement? entitlement;
  final String message;

  const BillingVerificationResult({
    required this.verified,
    required this.message,
    this.entitlement,
  });

  factory BillingVerificationResult.rejected(String message) {
    return BillingVerificationResult(
      verified: false,
      message: message,
    );
  }

  factory BillingVerificationResult.accepted(
    VerifiedEntitlement entitlement,
    String message,
  ) {
    return BillingVerificationResult(
      verified: true,
      entitlement: entitlement,
      message: message,
    );
  }
}
