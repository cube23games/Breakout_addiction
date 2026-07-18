enum BillingPurchaseState {
  pending,
  purchased,
  restored,
  canceled,
  error,
}

class BillingPurchaseEvent {
  final String eventKey;
  final String productId;
  final BillingPurchaseState state;
  final String serverVerificationData;
  final String localVerificationData;
  final String source;
  final String? purchaseId;
  final String? transactionDate;
  final bool pendingCompletion;
  final String? errorMessage;

  const BillingPurchaseEvent({
    required this.eventKey,
    required this.productId,
    required this.state,
    required this.serverVerificationData,
    required this.localVerificationData,
    required this.source,
    required this.pendingCompletion,
    this.purchaseId,
    this.transactionDate,
    this.errorMessage,
  });
}
