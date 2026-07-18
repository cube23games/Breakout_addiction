enum SubscriptionLifecycle {
  none,
  pending,
  active,
  canceledActive,
  gracePeriod,
  accountHold,
  expired,
  revoked,
  verificationUnavailable,
}

extension SubscriptionLifecycleX on SubscriptionLifecycle {
  String get label {
    switch (this) {
      case SubscriptionLifecycle.none:
        return 'No subscription';
      case SubscriptionLifecycle.pending:
        return 'Payment pending';
      case SubscriptionLifecycle.active:
        return 'Active';
      case SubscriptionLifecycle.canceledActive:
        return 'Canceled — access remains until expiration';
      case SubscriptionLifecycle.gracePeriod:
        return 'Payment issue — grace period';
      case SubscriptionLifecycle.accountHold:
        return 'Account hold';
      case SubscriptionLifecycle.expired:
        return 'Expired';
      case SubscriptionLifecycle.revoked:
        return 'Revoked';
      case SubscriptionLifecycle.verificationUnavailable:
        return 'Verification unavailable';
    }
  }

  static SubscriptionLifecycle fromName(String? value) {
    for (final lifecycle in SubscriptionLifecycle.values) {
      if (lifecycle.name == value) {
        return lifecycle;
      }
    }
    return SubscriptionLifecycle.verificationUnavailable;
  }
}
