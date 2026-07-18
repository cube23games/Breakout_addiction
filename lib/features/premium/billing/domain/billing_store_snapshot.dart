import 'billing_store_product.dart';

enum BillingConnectionState {
  idle,
  connecting,
  available,
  unavailable,
  error,
}

class BillingStoreSnapshot {
  final BillingConnectionState connectionState;
  final List<BillingStoreProduct> products;
  final Set<String> missingProductIds;
  final String message;

  const BillingStoreSnapshot({
    required this.connectionState,
    required this.products,
    required this.missingProductIds,
    required this.message,
  });

  factory BillingStoreSnapshot.idle() {
    return const BillingStoreSnapshot(
      connectionState: BillingConnectionState.idle,
      products: <BillingStoreProduct>[],
      missingProductIds: <String>{},
      message: 'Google Play Billing has not connected yet.',
    );
  }

  BillingStoreProduct? productForId(String productId) {
    for (final product in products) {
      if (product.id == productId) {
        return product;
      }
    }
    return null;
  }
}
