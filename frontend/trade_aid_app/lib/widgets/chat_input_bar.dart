import 'package:flutter/material.dart';

class ChatInputBar extends StatelessWidget {
  final void Function(String)? onSend;

  const ChatInputBar({
    super.key,
    this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  final text = value.trim();
                  if (text.isNotEmpty) {
                    onSend?.call(text);
                    _controller.clear();
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.send,
                color: Color(0xFF119E90),
              ),
              onPressed: () {
                final text = _controller.text.trim();
                if (text.isNotEmpty) {
                  onSend?.call(text); // ✅ backend hook
                  _controller.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
