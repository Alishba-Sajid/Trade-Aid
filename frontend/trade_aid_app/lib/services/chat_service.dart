import '../models/chat_message.dart';

class ChatService {
  /// Replace later with:
  /// - Firebase stream
  /// - WebSocket
  /// - REST polling
  Stream<List<ChatMessage>> getMessages(String chatId) async* {
    yield [
      ChatMessage(
        id: '1',
        text: 'Hello 👋',
        isMe: true,
        timestamp: DateTime.now(),
      ),
      ChatMessage(
        id: '2',
        text: 'Hi! How can I help?',
        isMe: false,
        timestamp: DateTime.now(),
      ),
    ];
  }

  /// Backend-compatible send
  Future<void> sendMessage(String chatId, String text) async {
   
    // POST /messages
    // firestore.collection('messages').add(...)
  }
}
