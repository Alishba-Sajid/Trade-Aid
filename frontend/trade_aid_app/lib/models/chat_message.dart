import 'package:supabase_flutter/supabase_flutter.dart';

class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final bool isMe;
  final DateTime createdAt;
  final String? mediaUrl;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.isMe,
    required this.createdAt,
    this.mediaUrl,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final myUserId = Supabase.instance.client.auth.currentUser!.id;

    return ChatMessage(
      id: json['id'],
      text: json['message_text'] ?? '',
      senderId: json['sender_id'],
      isMe: json['sender_id'] == myUserId,
      createdAt: DateTime.parse(json['created_at']),
      mediaUrl: json['media_url'],
    );
  }
}