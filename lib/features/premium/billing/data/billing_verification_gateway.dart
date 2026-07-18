import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/premium_plan.dart';
import '../domain/billing_product_ids.dart';
import '../domain/billing_purchase_event.dart';
import '../domain/billing_verification_result.dart';
import '../domain/subscription_lifecycle.dart';
import '../domain/verified_entitlement.dart';

class BillingVerificationGateway {
  static const String _configuredUrl = String.fromEnvironment(
    'BREAKOUT_BILLING_VERIFY_URL',
    defaultValue: '',
  );

  static const String packageName =
      'com.slimnation.breakoutaddiction';

  final http.Client _client;
  final String _endpoint;

  BillingVerificationGateway({
    http.Client? client,
    String endpoint = _configuredUrl,
  })  : _client = client ?? http.Client(),
        _endpoint = endpoint;

  bool get isConfigured {
    final uri = Uri.tryParse(_endpoint);
    return uri != null &&
        uri.isAbsolute &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty;
  }

  Future<BillingVerificationResult> verify(
    BillingPurchaseEvent event,
  ) async {
    if (!isConfigured) {
      return BillingVerificationResult.rejected(
        'Secure purchase verification is not configured. '
        'No paid access was granted.',
      );
    }

    if (event.serverVerificationData.trim().isEmpty) {
      return BillingVerificationResult.rejected(
        'Google Play did not provide a purchase token.',
      );
    }

    try {
      final response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: const <String, String>{
              'content-type': 'application/json',
              'accept': 'application/json',
            },
            body: jsonEncode(<String, dynamic>{
              'packageName': packageName,
              'productId': event.productId,
              'purchaseToken': event.serverVerificationData,
              'purchaseId': event.purchaseId,
              'transactionDate': event.transactionDate,
              'source': event.source,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return BillingVerificationResult.rejected(
          'Purchase verification failed with status '
          '${response.statusCode}. No paid access was granted.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        return BillingVerificationResult.rejected(
          'Purchase verification returned an invalid response.',
        );
      }
      final map = Map<String, dynamic>.from(decoded);
      if (map['verified'] != true) {
        return BillingVerificationResult.rejected(
          (map['message'] as String?) ??
              'The purchase could not be verified.',
        );
      }

      final planName = map['plan'] as String?;
      final plan = PremiumPlan.values.firstWhere(
        (value) => value.name == planName,
        orElse: () => PremiumPlan.none,
      );
      if (plan == PremiumPlan.none) {
        return BillingVerificationResult.rejected(
          'The verification service did not grant a paid tier.',
        );
      }
      final expectedPlan = BillingProductIds.planFor(event.productId);
      if (expectedPlan == null || expectedPlan != plan) {
        return BillingVerificationResult.rejected(
          'The verified tier does not match the Google Play product.',
        );
      }

      final entitlement = VerifiedEntitlement(
        plan: plan,
        lifecycle: SubscriptionLifecycleX.fromName(
          map['lifecycle'] as String?,
        ),
        productId: event.productId,
        purchaseId: event.purchaseId,
        verifiedAt: DateTime.now().toUtc(),
        expiresAt: DateTime.tryParse(
          (map['expiresAt'] as String?) ?? '',
        )?.toUtc(),
        verificationSource: 'secure-backend',
        serverAcknowledged: map['serverAcknowledged'] == true,
        serviceAccessToken: map['serviceAccessToken'] as String?,
        serviceAccessExpiresAt: DateTime.tryParse(
          (map['serviceAccessExpiresAt'] as String?) ?? '',
        )?.toUtc(),
      );

      return BillingVerificationResult.accepted(
        entitlement,
        (map['message'] as String?) ?? 'Purchase verified.',
      );
    } on FormatException {
      return BillingVerificationResult.rejected(
        'Purchase verification returned unreadable data.',
      );
    } catch (_) {
      return BillingVerificationResult.rejected(
        'Purchase verification is temporarily unavailable. '
        'Existing verified access is preserved when allowed.',
      );
    }
  }

  void close() {
    _client.close();
  }
}
