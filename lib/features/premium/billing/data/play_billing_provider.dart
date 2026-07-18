import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../../domain/premium_plan.dart';
import '../domain/billing_product_ids.dart';
import '../domain/billing_purchase_event.dart';
import '../domain/billing_store_product.dart';
import '../domain/billing_store_snapshot.dart';
import 'billing_provider.dart';

class PlayBillingProvider implements BillingProvider {
  final InAppPurchase _store;
  final StreamController<BillingPurchaseEvent> _events =
      StreamController<BillingPurchaseEvent>.broadcast();
  final Map<String, ProductDetails> _products = <String, ProductDetails>{};
  final Map<String, PurchaseDetails> _purchaseDetails =
      <String, PurchaseDetails>{};

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  PlayBillingProvider({
    InAppPurchase? store,
  }) : _store = store ?? InAppPurchase.instance;

  @override
  Stream<BillingPurchaseEvent> get purchaseEvents => _events.stream;

  String _eventKey(PurchaseDetails details) {
    return details.purchaseID ??
        '${details.productID}:${details.transactionDate ?? 'unknown'}';
  }

  BillingPurchaseState _mapState(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.pending:
        return BillingPurchaseState.pending;
      case PurchaseStatus.purchased:
        return BillingPurchaseState.purchased;
      case PurchaseStatus.restored:
        return BillingPurchaseState.restored;
      case PurchaseStatus.canceled:
        return BillingPurchaseState.canceled;
      case PurchaseStatus.error:
        return BillingPurchaseState.error;
    }
  }

  int _transactionEpoch(PurchaseDetails details) {
    return int.tryParse(details.transactionDate ?? '') ?? 0;
  }

  void _onPurchaseUpdates(List<PurchaseDetails> purchases) {
    final ordered = <PurchaseDetails>[...purchases]
      ..sort(
        (left, right) =>
            _transactionEpoch(left).compareTo(_transactionEpoch(right)),
      );

    for (final details in ordered) {
      final key = _eventKey(details);
      _purchaseDetails[key] = details;
      _events.add(
        BillingPurchaseEvent(
          eventKey: key,
          productId: details.productID,
          state: _mapState(details.status),
          serverVerificationData:
              details.verificationData.serverVerificationData,
          localVerificationData:
              details.verificationData.localVerificationData,
          source: details.verificationData.source,
          purchaseId: details.purchaseID,
          transactionDate: details.transactionDate,
          pendingCompletion: details.pendingCompletePurchase,
          errorMessage: details.error?.message,
        ),
      );
    }
  }

  @override
  Future<BillingStoreSnapshot> connectAndLoad() async {
    _subscription ??= _store.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (Object error, StackTrace stackTrace) {
        _events.add(
          BillingPurchaseEvent(
            eventKey: 'stream-error:${DateTime.now().microsecondsSinceEpoch}',
            productId: '',
            state: BillingPurchaseState.error,
            serverVerificationData: '',
            localVerificationData: '',
            source: 'play',
            pendingCompletion: false,
            errorMessage: error.toString(),
          ),
        );
      },
    );

    final available = await _store.isAvailable();
    if (!available) {
      return const BillingStoreSnapshot(
        connectionState: BillingConnectionState.unavailable,
        products: <BillingStoreProduct>[],
        missingProductIds: BillingProductIds.all,
        message:
            'Google Play Billing is unavailable on this installation or account.',
      );
    }

    final response =
        await _store.queryProductDetails(BillingProductIds.all);
    if (response.error != null) {
      return BillingStoreSnapshot(
        connectionState: BillingConnectionState.error,
        products: const <BillingStoreProduct>[],
        missingProductIds: response.notFoundIDs.toSet(),
        message: response.error!.message,
      );
    }

    _products
      ..clear()
      ..addEntries(
        response.productDetails.map(
          (details) => MapEntry<String, ProductDetails>(details.id, details),
        ),
      );

    final products = response.productDetails
        .map((details) {
          final plan = BillingProductIds.planFor(details.id);
          if (plan == null) {
            return null;
          }
          return BillingStoreProduct(
            id: details.id,
            plan: plan,
            title: details.title,
            description: details.description,
            localizedPrice: details.price,
            rawPrice: details.rawPrice,
            currencyCode: details.currencyCode,
          );
        })
        .whereType<BillingStoreProduct>()
        .toList()
      ..sort((a, b) => a.plan.accessLevel.compareTo(b.plan.accessLevel));

    return BillingStoreSnapshot(
      connectionState: BillingConnectionState.available,
      products: products,
      missingProductIds: response.notFoundIDs.toSet(),
      message: response.notFoundIDs.isEmpty
          ? 'Google Play products loaded.'
          : 'Google Play connected, but one or more subscription products are missing.',
    );
  }

  GooglePlayPurchaseDetails? _activeAndroidSubscription() {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return null;
    }

    final candidates = _purchaseDetails.values
        .whereType<GooglePlayPurchaseDetails>()
        .where(
          (details) =>
              BillingProductIds.planFor(details.productID) != null &&
              (details.status == PurchaseStatus.purchased ||
                  details.status == PurchaseStatus.restored),
        )
        .toList()
      ..sort(
        (left, right) =>
            _transactionEpoch(right).compareTo(_transactionEpoch(left)),
      );

    return candidates.isEmpty ? null : candidates.first;
  }

  @override
  Future<void> purchase(PremiumPlan plan) async {
    final productId = BillingProductIds.forPlan(plan);
    final product = _products[productId];
    if (product == null) {
      throw StateError(
        'Google Play product $productId is not loaded. '
        'Confirm the product exists and its base plan is active.',
      );
    }

    PurchaseParam parameter = PurchaseParam(productDetails: product);

    if (defaultTargetPlatform == TargetPlatform.android) {
      final oldSubscription = _activeAndroidSubscription();
      final offerToken =
          product is GooglePlayProductDetails ? product.offerToken : null;
      parameter = GooglePlayPurchaseParam(
        productDetails: product,
        offerToken: offerToken,
        changeSubscriptionParam: oldSubscription == null ||
                oldSubscription.productID == product.id
            ? null
            : ChangeSubscriptionParam(
                oldPurchaseDetails: oldSubscription,
                replacementMode: ReplacementMode.withTimeProration,
              ),
      );
    }

    final launched = await _store.buyNonConsumable(
      purchaseParam: parameter,
    );
    if (!launched) {
      throw StateError('Google Play did not launch the purchase flow.');
    }
  }

  @override
  Future<void> restore() {
    return _store.restorePurchases();
  }

  @override
  Future<void> complete(BillingPurchaseEvent event) async {
    final details = _purchaseDetails[event.eventKey];
    if (details == null) {
      throw StateError('Purchase details are no longer available.');
    }
    if (details.pendingCompletePurchase) {
      await _store.completePurchase(details);
    }
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _events.close();
  }
}
