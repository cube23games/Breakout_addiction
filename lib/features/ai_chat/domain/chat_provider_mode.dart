enum ChatProviderMode {
  secureGateway,
  mock,
  geminiPrototype,
  vertexPrivateReady,
}

extension ChatProviderModeX on ChatProviderMode {
  String get label {
    switch (this) {
      case ChatProviderMode.secureGateway:
        return 'Secure AI Gateway';
      case ChatProviderMode.mock:
        return 'Local Mock';
      case ChatProviderMode.geminiPrototype:
        return 'Gemini Prototype';
      case ChatProviderMode.vertexPrivateReady:
        return 'Vertex Private Ready';
    }
  }

  String get description {
    switch (this) {
      case ChatProviderMode.secureGateway:
        return 'Production path through a protected Breakout backend. No provider API key is stored in the app.';
      case ChatProviderMode.mock:
        return 'Local QA replies only. No cloud calls.';
      case ChatProviderMode.geminiPrototype:
        return 'Internal prototype path for sanitized test prompts only.';
      case ChatProviderMode.vertexPrivateReady:
        return 'Internal private-backend cutover stub.';
    }
  }
}
