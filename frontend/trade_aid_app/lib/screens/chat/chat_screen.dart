import 'package:flutter/material.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/chat_input_bar.dart';
import 'member_profile_screen.dart';
import 'voice_call_screen.dart';
import 'video_call_screen.dart';

// backend
import '../../services/chat_service.dart';
import '../../models/chat_message.dart';

const LinearGradient appGradient = LinearGradient(
  colors: [Color(0xFF2E9499), Color(0xFF119E90)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class ChatScreen extends StatefulWidget {
  final String sellerName; // ✅ REQUIRED BY ProductDetailsScreen

  const ChatScreen({super.key, required this.sellerName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();

  // later can come from auth / product / room
  final String chatId = 'chat_room_id';

  // ───────── MENU HANDLER ─────────
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Notifications Muted")));
        break;
    }
  }

  // ───────── BLOCK DIALOG ─────────
  void _showBlockConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Block ${widget.sellerName}?"),
        content: const Text(
          "You will no longer receive messages or calls from this contact.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _showBlockedSnackbar(context);
            },
            child: const Text("BLOCK", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ───────── BLOCK SNACKBAR ─────────
  void _showBlockedSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            const Icon(Icons.block, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text("You have blocked ${widget.sellerName}"),
          ],
        ),
      ),
    );
  }

  // ───────── SEND MESSAGE ─────────
  void _sendMessage(String text) {
    _chatService.sendMessage(chatId, text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9F8),
      body: Column(
        children: [
          _buildPremiumHeader(context),

          // ✅ BACKEND DRIVEN MESSAGE LIST (UI UNCHANGED)
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.getMessages(chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return MessageBubble(isMe: msg.isMe, message: msg.text);
                  },
                );
              },
            ),
          ),

          // ✅ SAME UI, BACKEND CONNECTED
          ChatInputBar(onSend: _sendMessage),
        ],
      ),
    );
  }

  // ───────── HEADER (UI UNCHANGED) ─────────
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
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=11',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.sellerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Online",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.call_outlined, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VoiceCallScreen()),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.videocam_outlined, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VideoCallScreen()),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) => _handleMenuSelection(value, context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'view_profile',
                    child: ListTile(
                      leading: Icon(
                        Icons.person_outline,
                        color: Color(0xFF119E90),
                      ),
                      title: Text('View Profile'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'mute',
                    child: ListTile(
                      leading: Icon(
                        Icons.notifications_off_outlined,
                        color: Color(0xFF119E90),
                      ),
                      title: Text('Mute'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'block',
                    child: ListTile(
                      leading: Icon(Icons.block, color: Colors.redAccent),
                      title: Text(
                        'Block User',
                        style: TextStyle(color: Colors.redAccent),
                      ),
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
