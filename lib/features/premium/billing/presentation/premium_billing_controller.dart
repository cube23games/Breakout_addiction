import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/premium_plan.dart';
import '../data/billing_provider.dart';
import '../data/play_billing_provider.dart';
import '../domain/billing_purchase_event.dart';
import '../domain/billing_store_product.dart';
import '../domain/billing_store_snapshot.dart';

class PremiumBillingController extends ChangeNotifier {
  PremiumBillingController._();

  static final PremiumBillingController instance =
      PremiumBillingController._();

  BillingProvider _provider = PlayBillingProvider();
  StreamSubscription<BillingPurchaseEvent>? _subscription;
  BillingStoreSnapshot _storeSnapshot = BillingStoreSnapshot.idle();
  BillingPurchaseEvent? _latestEvent;
  bool _started = false;
  bool _busy = false;
  String _operationMessage = 'Billing is idle.';

  BillingStoreSnapshot get storeSnapshot => _storeSnapshot;
  BillingPurchaseEvent? get latestEvent => _latestEvent;
  bool get busy => _busy;
  bool get started => _started;
  String get operationMessage => _operationMessage;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    _subscription = _provider.purchaseEvents.listen(
      (event) {
        _latestEvent = event;
        _operationMessage = event.state == BillingPurchaseState.pending
            ? 'Payment is pending. No paid access was granted.'
            : 'A Play transaction was received. Secure verification is required before entitlement can change.';
        notifyListeners();
      },
      onError: (Object error, StackTrace stackTrace) {
        _operationMessage = 'Google Play Billing reported an error: $error';
        debugPrintStack(stackTrace: stackTrace);
        notifyListeners();
      },
    );
    await refreshProducts();
  }

  Future<void> refreshProducts() async {
    _busy = true;
    notifyListeners();
    try {
      _storeSnapshot = await _provider.connectAndLoad();
      _operationMessage = _storeSnapshot.message;
    } catch (error) {
      _storeSnapshot = BillingStoreSnapshot(
        connectionState: BillingConnectionState.error,
        products: const <BillingStoreProduct>[],
        missingProductIds: const <String>{},
        message: 'Billing connection failed: $error',
      );
      _operationMessage = _storeSnapshot.message;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> beginPurchase(PremiumPlan plan) {
    throw StateError(
      'Purchasing remains disabled until secure verification is connected.',
    );
  }

  Future<void> restore() async {
    await _provider.restore();
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    await _provider.dispose();
    _provider = PlayBillingProvider();
    _subscription = null;
    _started = false;
  }
}
