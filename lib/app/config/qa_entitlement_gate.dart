class QaEntitlementGate {
  const QaEntitlementGate._();

  static const bool _requested = bool.fromEnvironment(
    'BREAKOUT_QA_ENTITLEMENTS',
    defaultValue: false,
  );

  static const String _buildChannel = String.fromEnvironment(
    'BREAKOUT_BUILD_CHANNEL',
    defaultValue: 'public',
  );

  static bool get enabled =>
      _requested && _buildChannel == 'qa';
}
