import 'dart:convert';

import 'package:breakout_addiction/features/premium/billing/data/billing_verification_gateway.dart';
import 'package:breakout_addiction/features/premium/billing/domain/billing_purchase_event.dart';
import 'package:breakout_addiction/features/premium/domain/premium_plan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

BillingPurchaseEvent _event(String productId) {
  return BillingPurchaseEvent(
    eventKey: 'event-1',
    productId: productId,
    state: BillingPurchaseState.purchased,
    serverVerificationData: 'play-token',
    localVerificationData: '',
    source: 'google_play',
    pendingCompletion: true,
  );
}

void main() {
  test('verified Plus AI response carries scoped service access', () async {
    final client = MockClient((request) async {
      expect(request.headers['content-type'], 'application/json');
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['purchaseToken'], 'play-token');
      return http.Response(
        jsonEncode(<String, dynamic>{
          'verified': true,
          'plan': 'plusAi',
          'lifecycle': 'active',
          'expiresAt': '2026-08-18T00:00:00Z',
          'serverAcknowledged': true,
          'serviceAccessToken': 'short-lived-service-token',
          'serviceAccessExpiresAt': '2026-07-19T00:00:00Z',
        }),
        200,
      );
    });

    final result = await BillingVerificationGateway(
      client: client,
      endpoint: 'https://billing.example.test/verify',
    ).verify(_event('breakout_plus_ai_monthly'));

    expect(result.verified, isTrue);
    expect(result.entitlement?.plan, PremiumPlan.plusAi);
    expect(
      result.entitlement?.serviceAccessToken,
      'short-lived-service-token',
    );
  });

  test('backend tier must match the Google Play product', () async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode(<String, dynamic>{
          'verified': true,
          'plan': 'plusAi',
          'lifecycle': 'active',
          'serverAcknowledged': true,
        }),
        200,
      );
    });

    final result = await BillingVerificationGateway(
      client: client,
      endpoint: 'https://billing.example.test/verify',
    ).verify(_event('breakout_plus_monthly'));

    expect(result.verified, isFalse);
    expect(result.message, contains('does not match'));
  });
}
