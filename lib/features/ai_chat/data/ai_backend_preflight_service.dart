import '../../../app/config/internal_surface_gate.dart';
import '../../../app/config/qa_billing_gate.dart';
import '../../premium/billing/data/verified_entitlement_repository.dart';
import '../../premium/data/premium_access_repository.dart';
import '../../premium/domain/premium_plan.dart';
import '../../settings/data/feature_control_settings_repository.dart';
import '../domain/ai_gateway_config.dart';
import '../domain/ai_preflight_status.dart';
import '../domain/chat_provider_mode.dart';
import 'ai_backend_config_repository.dart';
import 'ai_chat_settings_repository.dart';
import 'ai_runtime_gate_repository.dart';
import 'ai_usage_repository.dart';

class AiBackendPreflightService {
  final PremiumAccessRepository _premiumRepository =
      PremiumAccessRepository();
  final VerifiedEntitlementRepository _entitlementRepository =
      VerifiedEntitlementRepository();
  final AiChatSettingsRepository _settingsRepository =
      AiChatSettingsRepository();
  final AiBackendConfigRepository _backendRepository =
      AiBackendConfigRepository();
  final AiRuntimeGateRepository _runtimeGateRepository =
      AiRuntimeGateRepository();
  final FeatureControlSettingsRepository _featureRepository =
      FeatureControlSettingsRepository();
  final AiUsageRepository _usageRepository = AiUsageRepository();

  Future<AiPreflightStatus> run() async {
    final premium = await _premiumRepository.getStatus();
    final entitlement = await _entitlementRepository.read();
    final settings = await _settingsRepository.getSettings();
    final backend = await _backendRepository.getConfig();
    final remoteEnabled =
        await _runtimeGateRepository.getRemotePathEnabled();
    final featureSettings = await _featureRepository.getSettings();
    final usage = await _usageRepository.getSnapshot();

    final secureGateway =
        settings.providerMode == ChatProviderMode.secureGateway;
    final localMock = settings.providerMode == ChatProviderMode.mock;
    final internalPrototype =
        settings.providerMode == ChatProviderMode.geminiPrototype ||
            settings.providerMode == ChatProviderMode.vertexPrivateReady;
    final providerIsVertex =
        settings.providerMode == ChatProviderMode.vertexPrivateReady;

    final serviceAccessReady = entitlement != null &&
        entitlement.plan == PremiumPlan.plusAi &&
        entitlement.hasUsableServiceAccess(DateTime.now().toUtc());

    final riskyFeaturesForcedOff = !backend.allowGrounding &&
        !backend.allowMapsGrounding &&
        !backend.allowSessionMemory &&
        !backend.allowFileUploads;

    final blockers = <String>[];

    if (!premium.hasAiPremium) {
      blockers.add('Breakout Plus AI is not active.');
    }
    if (!featureSettings.aiChatEnabled) {
      blockers.add('AI chat is turned off.');
    }
    if (!featureSettings.remoteAiFeaturesEnabled) {
      blockers.add('Remote AI features are turned off.');
    }
    if (usage.fairUseReached) {
      blockers.add(
        'The app-side fair-use limit has been reached for today.',
      );
    }

    bool providerReady = false;

    if (secureGateway) {
      if (!AiGatewayConfig.isConfigured) {
        blockers.add('The secure AI gateway is not configured.');
      }
      if (!serviceAccessReady) {
        blockers.add(
          'Secure AI access needs a current backend-issued entitlement token.',
        );
      }
      providerReady = AiGatewayConfig.isConfigured && serviceAccessReady;
    } else if (localMock) {
      final internalAllowed =
          InternalSurfaceGate.showDevSurfaces || QaBillingGate.enabled;
      if (!internalAllowed) {
        blockers.add('Local mock mode is available only in internal builds.');
      }
      providerReady = internalAllowed;
    } else if (internalPrototype) {
      final internalAllowed =
          InternalSurfaceGate.showDevSurfaces || QaBillingGate.enabled;
      if (!internalAllowed) {
        blockers.add('Prototype providers are internal-only.');
      }
      if (!remoteEnabled) {
        blockers.add('Internal remote path is disabled.');
      }
      if (!backend.hasApiKey) {
        blockers.add('No internal prototype API key is saved.');
      }
      if (!riskyFeaturesForcedOff) {
        blockers.add('One or more risky prototype features are enabled.');
      }
      providerReady =
          (InternalSurfaceGate.showDevSurfaces || QaBillingGate.enabled) &&
          remoteEnabled &&
          backend.hasApiKey &&
          riskyFeaturesForcedOff;
    }

    final ready = premium.hasAiPremium &&
        featureSettings.aiChatEnabled &&
        featureSettings.remoteAiFeaturesEnabled &&
        !usage.fairUseReached &&
        providerReady;

    String summaryLine;
    if (ready && secureGateway) {
      summaryLine =
          'Secure Breakout AI gateway is ready. No provider API key is stored in the app.';
    } else if (ready && localMock) {
      summaryLine =
          'Internal local mock mode is ready. No cloud call will occur.';
    } else if (ready) {
      summaryLine =
          'Internal prototype provider is armed for sanitized QA prompts.';
    } else if (secureGateway) {
      summaryLine =
          'Secure AI is unavailable until every entitlement, configuration, and fair-use check passes.';
    } else {
      summaryLine =
          'The selected internal AI provider is blocked by one or more checks.';
    }

    return AiPreflightStatus(
      premiumUnlocked: premium.hasAiPremium,
      providerModeLabel: settings.providerMode.label,
      providerIsVertexPrivateReady: providerIsVertex,
      remotePathEnabled:
          secureGateway ? AiGatewayConfig.isConfigured : remoteEnabled,
      apiKeyPresent:
          secureGateway ? AiGatewayConfig.isConfigured : backend.hasApiKey,
      riskyFeaturesForcedOff: riskyFeaturesForcedOff,
      readyForRemoteStub: ready,
      summaryLine: summaryLine,
      blockerLines: blockers,
    );
  }
}
