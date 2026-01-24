import 'package:flutter/material.dart';

// 🌿 Theme Colors
const Color dark = Color(0xFF004D40);
const Color accent = Color(0xFF119E90);
const Color light = Color(0xFFF0F9F8);

class ChatScreen extends StatefulWidget {
  final String sellerName;

  const ChatScreen({super.key, required this.sellerName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: accent,
        title: Text(widget.sellerName),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[_messages.length - 1 - index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  // ───────────── MESSAGE INPUT ─────────────
  Widget _buildMessageInput() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: dark.withOpacity(0.3)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: accent,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── SEND MESSAGE ─────────────
  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        _ChatMessage(text: text, isSentByMe: true, time: DateTime.now()),
      );
      // Optionally, you can add a fake response from seller
      // _messages.add(_ChatMessage(
      //   text: "Seller reply",
      //   isSentByMe: false,
      //   time: DateTime.now(),
      // ));
    });

    _controller.clear();
  }

  // ───────────── MESSAGE BUBBLE ─────────────
  Widget _buildMessageBubble(_ChatMessage msg) {
    return Align(
      alignment: msg.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: msg.isSentByMe ? accent : Colors.grey.shade300,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(msg.isSentByMe ? 18 : 0),
            bottomRight: Radius.circular(msg.isSentByMe ? 0 : 18),
          ),
        ),
        child: Text(
          msg.text,
          style: TextStyle(color: msg.isSentByMe ? Colors.white : dark),
        ),
      ),
    );
  }
}

// ───────────── MESSAGE MODEL ─────────────
class _ChatMessage {
  final String text;
  final bool isSentByMe;
  final DateTime time;

  _ChatMessage({
    required this.text,
    required this.isSentByMe,
    required this.time,
  });
}
