import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/config/qa_billing_gate.dart';
import '../../data/premium_access_repository.dart';
import '../../domain/premium_plan.dart';
import '../data/billing_provider.dart';
import '../data/billing_provider_factory.dart';
import '../data/billing_verification_gateway.dart';
import '../data/verified_entitlement_repository.dart';
import '../domain/billing_product_ids.dart';
import '../domain/billing_purchase_event.dart';
import '../domain/billing_store_product.dart';
import '../domain/billing_store_snapshot.dart';
import '../domain/subscription_lifecycle.dart';
import '../domain/verified_entitlement.dart';

class PremiumBillingController extends ChangeNotifier {
  PremiumBillingController._();

  static final PremiumBillingController instance =
      PremiumBillingController._();

  BillingProvider _provider = BillingProviderFactory.create();
  BillingVerificationGateway _verificationGateway =
      BillingVerificationGateway();
  final VerifiedEntitlementRepository _entitlementRepository =
      VerifiedEntitlementRepository();
  final PremiumAccessRepository _accessRepository =
      PremiumAccessRepository();

  StreamSubscription<BillingPurchaseEvent>? _subscription;
  final Set<String> _processingEventKeys = <String>{};
  Future<void> _eventQueue = Future<void>.value();

  BillingStoreSnapshot _storeSnapshot = BillingStoreSnapshot.idle();
  BillingPurchaseEvent? _latestEvent;
  bool _started = false;
  bool _busy = false;
  String _operationMessage = 'Billing is idle.';

  BillingStoreSnapshot get storeSnapshot => _storeSnapshot;
  BillingPurchaseEvent? get latestEvent => _latestEvent;
  bool get busy => _busy;
  bool get started => _started;
  bool get isQaBilling => QaBillingGate.enabled;
  bool get verificationConfigured =>
      isQaBilling || _verificationGateway.isConfigured;
  String get operationMessage => _operationMessage;

  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;
    _subscription = _provider.purchaseEvents.listen(
      (event) {
        _latestEvent = event;
        _eventQueue = _eventQueue
            .then((_) => _handlePurchaseEvent(event))
            .catchError((Object error, StackTrace stackTrace) {
          debugPrint('Billing event processing failed: $error');
          debugPrintStack(stackTrace: stackTrace);
        });
      },
      onError: (Object error, StackTrace stackTrace) {
        _operationMessage =
            'Google Play Billing reported a stream error: $error';
        debugPrintStack(stackTrace: stackTrace);
        notifyListeners();
      },
    );
    await refreshProducts();
    if (!isQaBilling &&
        verificationConfigured &&
        _storeSnapshot.connectionState ==
            BillingConnectionState.available) {
      _operationMessage =
          'Refreshing verified subscription access from Google Play…';
      notifyListeners();
      try {
        await _provider.restore();
      } catch (error) {
        _operationMessage =
            'Subscription refresh is temporarily unavailable: $error';
        notifyListeners();
      }
    }
  }

  Future<void> refreshProducts() async {
    _busy = true;
    _storeSnapshot = const BillingStoreSnapshot(
      connectionState: BillingConnectionState.connecting,
      products: <BillingStoreProduct>[],
      missingProductIds: <String>{},
      message: 'Connecting to Google Play Billing…',
    );
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

  Future<void> beginPurchase(PremiumPlan plan) async {
    if (!verificationConfigured) {
      throw StateError(
        'Secure purchase verification is not configured. '
        'The purchase flow remains disabled so an unverified transaction '
        'cannot be accepted.',
      );
    }

    _busy = true;
    _operationMessage = isQaBilling
        ? 'Starting a no-charge QA purchase for ${plan.label}…'
        : 'Opening Google Play for ${plan.label}…';
    notifyListeners();
    try {
      await _provider.purchase(plan);
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> restore() async {
    _busy = true;
    _operationMessage = isQaBilling
        ? 'Restoring the last simulated QA purchase…'
        : 'Asking Google Play to restore purchases…';
    notifyListeners();
    try {
      await _provider.restore();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> setQaLifecycle({
    required PremiumPlan plan,
    required SubscriptionLifecycle lifecycle,
  }) async {
    if (!isQaBilling) {
      throw StateError('QA billing simulation is not enabled.');
    }

    if (plan == PremiumPlan.none) {
      await _entitlementRepository.clear();
      _operationMessage = 'QA billing reset to Standard.';
      notifyListeners();
      return;
    }

    final productId = BillingProductIds.forPlan(plan);
    await _entitlementRepository.save(
      VerifiedEntitlement(
        plan: plan,
        lifecycle: lifecycle,
        productId: productId,
        purchaseId: 'QA-LIFECYCLE',
        verifiedAt: DateTime.now().toUtc(),
        expiresAt: DateTime.now().toUtc().add(const Duration(days: 30)),
        verificationSource: 'qa-billing',
        serverAcknowledged: true,
      ),
    );
    _operationMessage =
        'QA lifecycle set to ${lifecycle.label} for ${plan.label}.';
    notifyListeners();
  }

  Future<void> clearQaSimulation() async {
    if (!isQaBilling) {
      return;
    }
    await _entitlementRepository.clear();
    _operationMessage = 'QA billing simulation cleared.';
    notifyListeners();
  }

  Future<bool> manageSubscription(PremiumPlan plan) async {
    final productId = BillingProductIds.forPlan(plan);
    final uri = Uri.https(
      'play.google.com',
      '/store/account/subscriptions',
      <String, String>{
        'sku': productId,
        'package': BillingVerificationGateway.packageName,
      },
    );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _handlePurchaseEvent(
    BillingPurchaseEvent event,
  ) async {
    if (_processingEventKeys.contains(event.eventKey)) {
      return;
    }

    if (event.state == BillingPurchaseState.pending) {
      _operationMessage =
          'Payment is pending. Paid access will not unlock until Google Play '
          'marks the purchase complete and the backend verifies it.';
      notifyListeners();
      return;
    }

    if (event.state == BillingPurchaseState.canceled) {
      _operationMessage =
          event.errorMessage ?? 'The purchase was canceled. No access changed.';
      notifyListeners();
      return;
    }

    if (event.state == BillingPurchaseState.error) {
      _operationMessage =
          event.errorMessage ?? 'Google Play reported a purchase error.';
      notifyListeners();
      return;
    }

    _processingEventKeys.add(event.eventKey);
    _busy = true;
    _operationMessage = isQaBilling
        ? 'Verifying the simulated QA purchase…'
        : 'Verifying the Google Play purchase securely…';
    notifyListeners();

    try {
      VerifiedEntitlement? entitlement;
      String verificationMessage;

      if (isQaBilling &&
          event.serverVerificationData.startsWith('qa:')) {
        final plan = BillingProductIds.planFor(event.productId);
        if (plan == null) {
          throw StateError('QA purchase used an unknown product.');
        }
        entitlement = VerifiedEntitlement(
          plan: plan,
          lifecycle: SubscriptionLifecycle.active,
          productId: event.productId,
          purchaseId: event.purchaseId,
          verifiedAt: DateTime.now().toUtc(),
          expiresAt:
              DateTime.now().toUtc().add(const Duration(days: 30)),
          verificationSource: 'qa-billing',
          serverAcknowledged: true,
        );
        verificationMessage = 'QA purchase verified locally.';
      } else {
        final verification =
            await _verificationGateway.verify(event);
        entitlement = verification.entitlement;
        verificationMessage = verification.message;
        if (!verification.verified || entitlement == null) {
          _operationMessage = verification.message;
          return;
        }
      }

      var finalizedEntitlement = entitlement;
      if (event.pendingCompletion && !entitlement.serverAcknowledged) {
        await _provider.complete(event);
        finalizedEntitlement = entitlement.copyWith(
          serverAcknowledged: true,
        );
      }

      await _entitlementRepository.save(finalizedEntitlement);

      final status = await _accessRepository.getStatus();
      _operationMessage =
          '$verificationMessage ${status.plan.label} is now active.';
    } catch (error) {
      _operationMessage =
          'The purchase could not be safely finished: $error';
    } finally {
      _processingEventKeys.remove(event.eventKey);
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    await _provider.dispose();
    _verificationGateway.close();
    _verificationGateway = BillingVerificationGateway();
    _provider = BillingProviderFactory.create();
    _subscription = null;
    _eventQueue = Future<void>.value();
    _started = false;
  }
}
