import 'accountability_scope.dart';

class AccountabilitySettings {
  final bool enabled;
  final Set<AccountabilityScope> sharedScopes;
  final bool sharePrivateNotes;
  final bool shareAiChatHistory;

  const AccountabilitySettings({
    required this.enabled,
    required this.sharedScopes,
    this.sharePrivateNotes = false,
    this.shareAiChatHistory = false,
  });

  static const AccountabilitySettings defaults = AccountabilitySettings(
    enabled: false,
    sharedScopes: <AccountabilityScope>{},
  );

  bool get canUsePartnerAccess => enabled && sharedScopes.isNotEmpty;

  AccountabilitySettings copyWith({
    bool? enabled,
    Set<AccountabilityScope>? sharedScopes,
    bool? sharePrivateNotes,
    bool? shareAiChatHistory,
  }) {
    return AccountabilitySettings(
      enabled: enabled ?? this.enabled,
      sharedScopes: sharedScopes ?? this.sharedScopes,
      sharePrivateNotes: sharePrivateNotes ?? this.sharePrivateNotes,
      shareAiChatHistory: shareAiChatHistory ?? this.shareAiChatHistory,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'enabled': enabled,
      'sharedScopes': sharedScopes.map((scope) => scope.name).toList(),
      'sharePrivateNotes': sharePrivateNotes,
      'shareAiChatHistory': shareAiChatHistory,
    };
  }

  factory AccountabilitySettings.fromMap(Map<String, dynamic> map) {
    return AccountabilitySettings(
      enabled: map['enabled'] == true,
      sharedScopes: _parseScopes(map['sharedScopes']),
      sharePrivateNotes: map['sharePrivateNotes'] == true,
      shareAiChatHistory: map['shareAiChatHistory'] == true,
    );
  }

  static Set<AccountabilityScope> _parseScopes(Object? raw) {
    if (raw is! List) {
      return <AccountabilityScope>{};
    }

    return raw
        .whereType<String>()
        .map(_parseScope)
        .whereType<AccountabilityScope>()
        .toSet();
  }

  static AccountabilityScope? _parseScope(String name) {
    for (final scope in AccountabilityScope.values) {
      if (scope.name == name) {
        return scope;
      }
    }
    return null;
  }
}
