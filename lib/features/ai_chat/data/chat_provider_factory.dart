import '../domain/chat_provider.dart';
import '../domain/chat_provider_mode.dart';
import 'backend_recovery_coach_provider.dart';
import 'gemini_http_transport.dart';
import 'gemini_prototype_provider.dart';
import 'mock_recovery_coach_provider.dart';
import 'vertex_private_ready_provider.dart';
import 'vertex_transport_stub.dart';

class ChatProviderFactory {
  static ChatProvider create(ChatProviderMode mode) {
    switch (mode) {
      case ChatProviderMode.secureGateway:
        return BackendRecoveryCoachProvider();
      case ChatProviderMode.mock:
        return MockRecoveryCoachProvider();
      case ChatProviderMode.geminiPrototype:
        return GeminiPrototypeProvider(
          transport: GeminiHttpTransport(),
        );
      case ChatProviderMode.vertexPrivateReady:
        return VertexPrivateReadyProvider(
          transport: VertexTransportStub(),
        );
    }
  }
}
