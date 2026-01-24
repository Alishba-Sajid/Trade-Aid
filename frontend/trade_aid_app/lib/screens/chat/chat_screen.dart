import 'package:flutter/material.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/chat_input_bar.dart';
import 'member_profile_screen.dart'; // Ensure this file exists
import 'voice_call_screen.dart';
import 'video_call_screen.dart';

const LinearGradient appGradient = LinearGradient(
  colors: [Color(0xFF2E9499), Color(0xFF119E90)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  // 🔹 Navigation and Logic Handler
  void _handleMenuSelection(String value, BuildContext context) {
    switch (value) {
      case 'view_profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MemberProfileScreen()),
        );
        break;
      case 'block':
        _showBlockConfirmation(context);
        break;
      case 'mute':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notifications Muted")),
        );
        break;
    }
  }

  // 🔹 Block Confirmation Dialog
  void _showBlockConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Block Ahmed Khan?"),
          content: const Text("You will no longer receive messages or calls from this contact."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context); // Close Dialog
                _showBlockedSnackbar(context);
              },
              child: const Text("BLOCK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // 🔹 Success Snackbar
  void _showBlockedSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: const Row(
          children: [
            Icon(Icons.block, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text("You have blocked Ahmed Khan"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9F8),
      body: Column(
        children: [
          _buildPremiumHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: const [
                MessageBubble(isMe: true, message: "Hello 👋"),
                MessageBubble(isMe: false, message: "Hi! How can I help?"),
              ],
            ),
          ),
          const ChatInputBar(),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context) {
    return Container(
      height: 130,
      decoration: const BoxDecoration(
        gradient: appGradient,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ahmed Khan",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text("Online", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.call_outlined, color: Colors.white),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceCallScreen())),
              ),
              IconButton(
                icon: const Icon(Icons.videocam_outlined, color: Colors.white),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoCallScreen())),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) => _handleMenuSelection(value, context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view_profile',
                    child: ListTile(
                      leading: Icon(Icons.person_outline, color: Color(0xFF119E90)),
                      title: Text('View Profile'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'mute',
                    child: ListTile(
                      leading: Icon(Icons.notifications_off_outlined, color: Color(0xFF119E90)),
                      title: Text('Mute'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'block',
                    child: ListTile(
                      leading: Icon(Icons.block, color: Colors.redAccent),
                      title: Text('Block User', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}