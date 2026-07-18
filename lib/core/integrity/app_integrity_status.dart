enum AppIntegrityState {
  checking,
  trusted,
  altered,
  unavailable,
  configurationError,
}

class AppIntegrityStatus {
  final AppIntegrityState state;
  final String message;
  final String? actualPackage;
  final List<String> signingFingerprints;
  final bool debuggable;

  const AppIntegrityStatus({
    required this.state,
    required this.message,
    this.actualPackage,
    this.signingFingerprints = const <String>[],
    this.debuggable = false,
  });

  const AppIntegrityStatus.checking()
      : state = AppIntegrityState.checking,
        message = 'Checking app integrity.',
        actualPackage = null,
        signingFingerprints = const <String>[],
        debuggable = false;

  bool get isTrusted => state == AppIntegrityState.trusted;
  bool get allowsPaidFeatures => isTrusted;
  bool get detectedAlteration => state == AppIntegrityState.altered;
}
