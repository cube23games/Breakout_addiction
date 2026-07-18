import '../../domain/premium_plan.dart';
import '../domain/billing_purchase_event.dart';
import '../domain/billing_store_snapshot.dart';

abstract class BillingProvider {
  Stream<BillingPurchaseEvent> get purchaseEvents;

  Future<BillingStoreSnapshot> connectAndLoad();

  Future<void> purchase(PremiumPlan plan);

  Future<void> restore();

  Future<void> complete(BillingPurchaseEvent event);

  Future<void> dispose();
}
