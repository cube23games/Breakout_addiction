import 'dart:async';

import '../../domain/premium_plan.dart';
import '../domain/billing_product_ids.dart';
import '../domain/billing_purchase_event.dart';
import '../domain/billing_store_product.dart';
import '../domain/billing_store_snapshot.dart';
import 'billing_provider.dart';

class QaBillingProvider implements BillingProvider {
  final StreamController<BillingPurchaseEvent> _events =
      StreamController<BillingPurchaseEvent>.broadcast();

  BillingPurchaseEvent? _lastPurchase;

  @override
  Stream<BillingPurchaseEvent> get purchaseEvents => _events.stream;

  @override
  Future<BillingStoreSnapshot> connectAndLoad() async {
    return const BillingStoreSnapshot(
      connectionState: BillingConnectionState.available,
      products: <BillingStoreProduct>[
        BillingStoreProduct(
          id: BillingProductIds.plusMonthly,
          plan: PremiumPlan.plus,
          title: 'Breakout Plus — QA product',
          description: 'Simulated monthly Plus subscription.',
          localizedPrice: r'$9.99/month — QA',
          rawPrice: 9.99,
          currencyCode: 'USD',
        ),
        BillingStoreProduct(
          id: BillingProductIds.plusAiMonthly,
          plan: PremiumPlan.plusAi,
          title: 'Breakout Plus AI — QA product',
          description: 'Simulated monthly Plus AI subscription.',
          localizedPrice: r'$14.99/month — QA',
          rawPrice: 14.99,
          currencyCode: 'USD',
        ),
      ],
      missingProductIds: <String>{},
      message:
          'QA billing simulation is active. No real charge will occur.',
    );
  }

  @override
  Future<void> purchase(PremiumPlan plan) async {
    final productId = BillingProductIds.forPlan(plan);
    final event = BillingPurchaseEvent(
      eventKey:
          'qa-purchase:${DateTime.now().microsecondsSinceEpoch}',
      productId: productId,
      state: BillingPurchaseState.purchased,
      serverVerificationData:
          'qa:$productId:${DateTime.now().millisecondsSinceEpoch}',
      localVerificationData: 'qa-local',
      source: 'qa-billing',
      purchaseId: 'QA-${DateTime.now().millisecondsSinceEpoch}',
      transactionDate:
          DateTime.now().toUtc().millisecondsSinceEpoch.toString(),
      pendingCompletion: false,
    );
    _lastPurchase = event;
    _events.add(event);
  }

  @override
  Future<void> restore() async {
    final previous = _lastPurchase;
    if (previous == null) {
      _events.add(
        BillingPurchaseEvent(
          eventKey:
              'qa-restore-empty:${DateTime.now().microsecondsSinceEpoch}',
          productId: '',
          state: BillingPurchaseState.canceled,
          serverVerificationData: '',
          localVerificationData: '',
          source: 'qa-billing',
          pendingCompletion: false,
          errorMessage: 'No simulated QA purchase exists to restore.',
        ),
      );
      return;
    }

    _events.add(
      BillingPurchaseEvent(
        eventKey:
            'qa-restore:${DateTime.now().microsecondsSinceEpoch}',
        productId: previous.productId,
        state: BillingPurchaseState.restored,
        serverVerificationData: previous.serverVerificationData,
        localVerificationData: previous.localVerificationData,
        source: previous.source,
        purchaseId: previous.purchaseId,
        transactionDate: previous.transactionDate,
        pendingCompletion: false,
      ),
    );
  }

  @override
  Future<void> complete(BillingPurchaseEvent event) async {}

  @override
  Future<void> dispose() {
    return _events.close();
  }
}
