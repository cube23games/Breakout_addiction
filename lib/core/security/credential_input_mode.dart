enum CredentialInputMode {
  pin,
  password;

  String get label {
    switch (this) {
      case CredentialInputMode.pin:
        return 'PIN';
      case CredentialInputMode.password:
        return 'Password';
    }
  }

  static CredentialInputMode fromStored(
    String? stored, {
    String? existingCredential,
  }) {
    for (final mode in CredentialInputMode.values) {
      if (mode.name == stored) {
        return mode;
      }
    }

    final existing = existingCredential?.trim() ?? '';
    if (existing.isEmpty || RegExp(r'^\d+$').hasMatch(existing)) {
      return CredentialInputMode.pin;
    }

    return CredentialInputMode.password;
  }
}
