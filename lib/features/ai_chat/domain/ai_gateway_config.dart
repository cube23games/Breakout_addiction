class AiGatewayConfig {
  const AiGatewayConfig._();

  static const String endpoint = String.fromEnvironment(
    'BREAKOUT_AI_GATEWAY_URL',
    defaultValue: '',
  );

  static bool get isConfigured {
    final uri = Uri.tryParse(endpoint);
    return uri != null &&
        uri.isAbsolute &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty;
  }
}
