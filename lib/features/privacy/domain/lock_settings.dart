import 'lock_scope.dart';

class LockSettings {
  static const Set<int> supportedGraceMinutes = <int>{0, 1, 2, 5, 10};

  final bool isEnabled;
  final Set<LockScope> enabledScopes;
  final bool allowRescueWithoutUnlock;
  final bool useBiometrics;
  final bool hasPasscode;
  final bool neutralPrivacyMode;
  final int backgroundGraceMinutes;

  const LockSettings({
    required this.isEnabled,
    required this.enabledScopes,
    required this.allowRescueWithoutUnlock,
    required this.useBiometrics,
    required this.hasPasscode,
    required this.neutralPrivacyMode,
    required this.backgroundGraceMinutes,
  });

  factory LockSettings.disabled() {
    return const LockSettings(
      isEnabled: false,
      enabledScopes: <LockScope>{},
      allowRescueWithoutUnlock: true,
      useBiometrics: false,
      hasPasscode: false,
      neutralPrivacyMode: true,
      backgroundGraceMinutes: 0,
    );
  }

  LockSettings copyWith({
    bool? isEnabled,
    Set<LockScope>? enabledScopes,
    bool? allowRescueWithoutUnlock,
    bool? useBiometrics,
    bool? hasPasscode,
    bool? neutralPrivacyMode,
    int? backgroundGraceMinutes,
  }) {
    return LockSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      enabledScopes: enabledScopes ?? this.enabledScopes,
      allowRescueWithoutUnlock:
          allowRescueWithoutUnlock ?? this.allowRescueWithoutUnlock,
      useBiometrics: useBiometrics ?? this.useBiometrics,
      hasPasscode: hasPasscode ?? this.hasPasscode,
      neutralPrivacyMode: neutralPrivacyMode ?? this.neutralPrivacyMode,
      backgroundGraceMinutes:
          backgroundGraceMinutes ?? this.backgroundGraceMinutes,
    );
  }

  bool shouldLock(LockScope scope) {
    return isEnabled &&
        (enabledScopes.contains(LockScope.app) || enabledScopes.contains(scope));
  }

  static int normalizeGraceMinutes(int value) {
    return supportedGraceMinutes.contains(value) ? value : 0;
  }
}
