import '../../domain/premium_plan.dart';
import 'subscription_lifecycle.dart';

class VerifiedEntitlement {
  final PremiumPlan plan;
  final SubscriptionLifecycle lifecycle;
  final String productId;
  final String? purchaseId;
  final DateTime verifiedAt;
  final DateTime? expiresAt;
  final String verificationSource;
  final bool serverAcknowledged;
  final String? serviceAccessToken;
  final DateTime? serviceAccessExpiresAt;

  const VerifiedEntitlement({
    required this.plan,
    required this.lifecycle,
    required this.productId,
    required this.verifiedAt,
    required this.verificationSource,
    required this.serverAcknowledged,
    this.purchaseId,
    this.expiresAt,
    this.serviceAccessToken,
    this.serviceAccessExpiresAt,
  });

  VerifiedEntitlement copyWith({
    PremiumPlan? plan,
    SubscriptionLifecycle? lifecycle,
    String? productId,
    String? purchaseId,
    DateTime? verifiedAt,
    DateTime? expiresAt,
    String? verificationSource,
    bool? serverAcknowledged,
    String? serviceAccessToken,
    DateTime? serviceAccessExpiresAt,
  }) {
    return VerifiedEntitlement(
      plan: plan ?? this.plan,
      lifecycle: lifecycle ?? this.lifecycle,
      productId: productId ?? this.productId,
      purchaseId: purchaseId ?? this.purchaseId,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      verificationSource:
          verificationSource ?? this.verificationSource,
      serverAcknowledged:
          serverAcknowledged ?? this.serverAcknowledged,
      serviceAccessToken:
          serviceAccessToken ?? this.serviceAccessToken,
      serviceAccessExpiresAt:
          serviceAccessExpiresAt ?? this.serviceAccessExpiresAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'plan': plan.name,
      'lifecycle': lifecycle.name,
      'productId': productId,
      'purchaseId': purchaseId,
      'verifiedAt': verifiedAt.toUtc().toIso8601String(),
      'expiresAt': expiresAt?.toUtc().toIso8601String(),
      'verificationSource': verificationSource,
      'serverAcknowledged': serverAcknowledged,
      'serviceAccessToken': serviceAccessToken,
      'serviceAccessExpiresAt':
          serviceAccessExpiresAt?.toUtc().toIso8601String(),
    };
  }

  factory VerifiedEntitlement.fromMap(Map<String, dynamic> map) {
    final planName = map['plan'] as String?;
    final plan = PremiumPlan.values.firstWhere(
      (value) => value.name == planName,
      orElse: () => PremiumPlan.none,
    );

    return VerifiedEntitlement(
      plan: plan,
      lifecycle: SubscriptionLifecycleX.fromName(
        map['lifecycle'] as String?,
      ),
      productId: (map['productId'] as String?) ?? '',
      purchaseId: map['purchaseId'] as String?,
      verifiedAt: DateTime.tryParse(
            (map['verifiedAt'] as String?) ?? '',
          )?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      expiresAt: DateTime.tryParse(
        (map['expiresAt'] as String?) ?? '',
      )?.toUtc(),
      verificationSource:
          (map['verificationSource'] as String?) ?? 'unknown',
      serverAcknowledged: map['serverAcknowledged'] == true,
      serviceAccessToken: map['serviceAccessToken'] as String?,
      serviceAccessExpiresAt: DateTime.tryParse(
        (map['serviceAccessExpiresAt'] as String?) ?? '',
      )?.toUtc(),
    );
  }

  bool hasUsableServiceAccess(DateTime now) {
    final token = serviceAccessToken?.trim() ?? '';
    if (token.isEmpty) {
      return false;
    }
    final expiration = serviceAccessExpiresAt;
    return expiration != null && expiration.isAfter(now.toUtc());
  }
}
