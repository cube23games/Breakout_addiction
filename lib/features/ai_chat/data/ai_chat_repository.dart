import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/local_data_safety.dart';
import '../domain/chat_message.dart';

class AiChatRepository {
  static const String _storageKey = 'ai_chat_messages';

  Future<List<ChatMessage>> getMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    final messages = LocalDataSafety.decodeMappedList<ChatMessage>(
      raw,
      (map) => ChatMessage.fromMap(map),
    );

    return messages..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> saveMessages(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(messages.map((item) => item.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> clearMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
