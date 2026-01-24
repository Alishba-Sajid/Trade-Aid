import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final bool isMe;
  final String message;

  const MessageBubble({
    super.key,
    required this.isMe,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isMe ? accent : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isMe ? Colors.white : dark,
          ),
        ),
      ),
    );
  }
}
