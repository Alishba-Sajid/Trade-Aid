import 'package:flutter/material.dart';
import 'avatar.dart';

class ChatTile extends StatelessWidget {
  final VoidCallback onTap;

  const ChatTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Avatar(),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Ahmed Khan",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 2),
          Text(
            "House #23, Block A",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      onLongPress: () {
        _showDeleteChatSheet(context);
      },
    );
  }

  void _showDeleteChatSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text("Delete Chat"),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(context);
            },
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete chat?"),
        content: const Text(
          "This chat will be removed from your device.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
          
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
