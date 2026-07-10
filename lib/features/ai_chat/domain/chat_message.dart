import '../../../core/storage/local_data_safety.dart';

enum ChatRole {
  user,
  assistant,
}

class ChatMessage {
  final ChatRole role;
  final String text;
  final DateTime timestamp;

  const ChatMessage({
    required this.role,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'role': role.name,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      role: LocalDataSafety.enumByName(
        ChatRole.values,
        map['role'] as String?,
        ChatRole.assistant,
      ),
      text: (map['text'] as String?) ?? '',
      timestamp: LocalDataSafety.dateTime(
        map['timestamp'],
        DateTime.now(),
      ),
    );
  }
}
