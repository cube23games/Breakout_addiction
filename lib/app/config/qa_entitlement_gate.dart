class QaEntitlementGate {
  const QaEntitlementGate._();

  static const bool enabled = bool.fromEnvironment(
    'BREAKOUT_QA_ENTITLEMENTS',
    defaultValue: false,
  );
}
