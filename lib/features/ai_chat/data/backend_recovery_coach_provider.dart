import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../premium/billing/data/verified_entitlement_repository.dart';
import '../../premium/domain/premium_plan.dart';
import '../domain/ai_fair_use_policy.dart';
import '../domain/ai_gateway_config.dart';
import '../domain/ai_recovery_coach_policy.dart';
import '../domain/chat_message.dart';
import '../domain/chat_provider.dart';

class BackendRecoveryCoachProvider implements ChatProvider {
  final http.Client _client;
  final VerifiedEntitlementRepository _entitlementRepository;

  BackendRecoveryCoachProvider({
    http.Client? client,
    VerifiedEntitlementRepository? entitlementRepository,
  })  : _client = client ?? http.Client(),
        _entitlementRepository =
            entitlementRepository ?? VerifiedEntitlementRepository();

  List<Map<String, String>> _recentMessages(
    List<ChatMessage> messages,
  ) {
    final recent = messages.length > AiFairUsePolicy.recentMessageLimit
        ? messages.sublist(
            messages.length - AiFairUsePolicy.recentMessageLimit,
          )
        : messages;

    return recent
        .map(
          (message) => <String, String>{
            'role': message.role == ChatRole.user ? 'user' : 'assistant',
            'text': message.text,
          },
        )
        .toList();
  }

  @override
  Future<ChatMessage> generateReply({
    required List<ChatMessage> messages,
    required String userInput,
  }) async {
    if (!AiGatewayConfig.isConfigured) {
      return ChatMessage(
        role: ChatRole.assistant,
        text:
            'Secure AI support is not configured yet. Use Rescue, your recovery plan, or local guidance instead.',
        timestamp: DateTime.now(),
      );
    }

    final entitlement = await _entitlementRepository.read();
    final serviceToken = entitlement?.serviceAccessToken?.trim() ?? '';
    if (entitlement == null ||
        entitlement.plan != PremiumPlan.plusAi ||
        !entitlement.hasUsableServiceAccess(DateTime.now().toUtc())) {
      return ChatMessage(
        role: ChatRole.assistant,
        text:
            'Secure AI access needs to be refreshed. Restore purchases from Premium, then try again. Local Rescue, routines, reports, and human support remain available.',
        timestamp: DateTime.now(),
      );
    }

    try {
      final response = await _client
          .post(
            Uri.parse(AiGatewayConfig.endpoint),
            headers: <String, String>{
              'content-type': 'application/json',
              'accept': 'application/json',
              'authorization': 'Bearer $serviceToken',
            },
            body: jsonEncode(<String, dynamic>{
              'messages': _recentMessages(messages),
              'userInput': userInput,
              'policy': <String, dynamic>{
                'systemInstruction':
                    AiRecoveryCoachPolicy.systemInstruction,
                'maxOutputTokens':
                    AiRecoveryCoachPolicy.maxOutputTokens,
                'temperature': AiRecoveryCoachPolicy.temperature,
              },
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 429) {
        return ChatMessage(
          role: ChatRole.assistant,
          text:
              'AI support has reached its fair-use limit for now. Your local Rescue, plan, guidance, and human-support tools remain available.',
          timestamp: DateTime.now(),
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return ChatMessage(
          role: ChatRole.assistant,
          text:
              'Secure AI support is temporarily unavailable. Use one local next step: leave the risky setting, open Rescue, or contact someone safe.',
          timestamp: DateTime.now(),
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const FormatException('Invalid AI gateway response.');
      }
      final reply = decoded['reply'];
      if (reply is! String || reply.trim().isEmpty) {
        throw const FormatException('AI gateway returned no reply.');
      }

      return ChatMessage(
        role: ChatRole.assistant,
        text: reply.trim(),
        timestamp: DateTime.now(),
      );
    } on TimeoutException {
      return ChatMessage(
        role: ChatRole.assistant,
        text:
            'Secure AI support timed out. Use Rescue or one action from your saved recovery plan.',
        timestamp: DateTime.now(),
      );
    } catch (_) {
      return ChatMessage(
        role: ChatRole.assistant,
        text:
            'Secure AI support could not connect. Your local recovery tools are still ready.',
        timestamp: DateTime.now(),
      );
    }
  }
}
