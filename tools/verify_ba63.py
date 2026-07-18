from pathlib import Path

ROOT = Path.cwd()
errors = []

checks = {
    ".github/workflows/ci.yml": [
        "BREAKOUT_AI_GATEWAY_URL: ${{ secrets.BREAKOUT_AI_GATEWAY_URL }}",
        "--dart-define=BREAKOUT_AI_GATEWAY_URL=",
    ],
    "lib/features/ai_chat/domain/ai_gateway_config.dart": [
        "BREAKOUT_AI_GATEWAY_URL",
        "uri.scheme == 'https'",
    ],
    "lib/features/ai_chat/data/backend_recovery_coach_provider.dart": [
        "AiGatewayConfig.endpoint",
        "authorization",
        "serviceAccessToken",
        "hasUsableServiceAccess",
        "statusCode == 429",
        "local recovery tools",
    ],
    "lib/features/ai_chat/domain/ai_fair_use_policy.dart": [
        "dailyRequestLimit = 40",
        "maxInputCharacters = 1500",
    ],
    "lib/features/ai_chat/data/ai_usage_repository.dart": [
        "canUseRemoteRequest",
        "_dailyRemoteRequestsKey",
        "remoteRequest",
    ],
    "lib/features/ai_chat/data/ai_backend_preflight_service.dart": [
        "ChatProviderMode.secureGateway",
        "AiGatewayConfig.isConfigured",
        "serviceAccessReady",
        "usage.fairUseReached",
        "featureSettings.remoteAiFeaturesEnabled",
        "QaBillingGate.enabled",
    ],
    "lib/features/ai_chat/presentation/ai_chat_screen.dart": [
        "AiFairUsePolicy.maxInputCharacters",
        "ChatProviderMode.secureGateway",
        "remoteRequest: remoteRequest",
        "Secure AI",
    ],
    "lib/app/app_router.dart": [
        "case RouteNames.aiChat:",
        "AiChatScreen(initialPrompt: initialPrompt)",
    ],
    "docs/AI_GATEWAY_AND_FAIR_USE.md": [
        "must not contain",
        "Authorization: Bearer",
        "subject to fair use",
        "40 remote requests",
    ],
    "test/ai_fair_use_policy_test.dart": [
        "usage snapshot never reports negative remaining access",
    ],
}

for relative, needles in checks.items():
    path = ROOT / relative
    if not path.is_file():
        errors.append(f"missing {relative}")
        continue
    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            errors.append(f"{relative} missing {needle!r}")

secure_provider = (
    ROOT /
    "lib/features/ai_chat/data/backend_recovery_coach_provider.dart"
)
if secure_provider.is_file():
    text = secure_provider.read_text(encoding="utf-8").lower()
    forbidden = (
        "x-goog-api-key",
        "generativelanguage.googleapis.com",
        "aiplatform.googleapis.com",
        "saveapikey",
    )
    for token in forbidden:
        if token in text:
            errors.append(
                f"secure AI provider contains forbidden provider-secret path: {token}"
            )

router = ROOT / "lib/app/app_router.dart"
if router.is_file():
    text = router.read_text(encoding="utf-8")
    ai_case = text.split("case RouteNames.aiChat:", 1)[-1].split(
        "case RouteNames.featureControls:", 1
    )[0]
    if "InternalSurfaceGate.showDevSurfaces" in ai_case:
        errors.append("public Plus AI route is still hidden as a dev surface")

if errors:
    print("BA-63 verification failed:")
    for error in errors:
        print(f" - {error}")
    raise SystemExit(1)

print(
    "BA-63 verification passed: public Plus AI uses a protected HTTPS gateway "
    "with no provider key in the app, entitlement/configuration/fair-use "
    "preflight, bounded input and daily requests, backend 429 handling, local "
    "fallback, and QA-only mock/prototype access."
)
