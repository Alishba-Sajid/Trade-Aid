import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/message_bubble.dart';

import '../../services/chat_service.dart';
import '../../models/chat_message.dart';

const LinearGradient appGradient = LinearGradient(
  colors: [Color(0xFF2E9499), Color(0xFF119E90)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class ChatScreen extends StatefulWidget {
  final String sellerName;
  final String receiverId;
  final String? profileImage;
  final String? address;
  

  const ChatScreen({
    super.key,
    required this.sellerName,
    required this.receiverId,
    this.profileImage,
    this.address,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}




 

class _ChatScreenState extends State<ChatScreen> {

  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? chatId;
  List<ChatMessage> _messages = [];
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;

  /// RECORDING VARIABLES
  bool _isRecording = false;
  Duration _recordDuration = Duration.zero;
  Timer? _timer;
  AudioRecorder? _recorder;
  String? _recordedFile;

  @override
  void initState() {
    super.initState();
    _initConversation();
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _timer?.cancel();
    _recorder?.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

Future<void> _initConversation() async {
final id = await _chatService.getOrCreateConversation(widget.receiverId);

  setState(() {
    chatId = id;
  });

  /// ✅ MARK AS SEEN
  await _chatService.markMessagesAsSeen(id);

  /// ✅ LISTEN TO MESSAGES (FIXED POSITION)
  _messagesSubscription?.cancel();
  _messagesSubscription = _chatService.getMessages(id).listen((messages) {
    setState(() {
      _messages = messages;
    });
  });
}

 

  /// SEND TEXT
Future<void> _sendMessage(String text) async {

  if (chatId == null) return;

  await _chatService.sendMessage(chatId!, text);

  /// auto scroll after sending
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
  _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  });
}
Future<void> _deleteMessage(String messageId, {String? mediaUrl}) async {
  // Find the message index
  final index = _messages.indexWhere((m) => m.id == messageId);
  if (index == -1) return;

  final msg = _messages[index];

  // Remove from list immediately for instant UI update
  setState(() {
    _messages.removeAt(index);
  });

  // Delete from database
  try {
    await _chatService.deleteMessage(messageId, mediaUrl);
  } catch (e) {
    // If delete fails, add the message back
    setState(() {
      _messages.insert(index, msg);
    });
    // Show error to user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete message')),
      );
    }
    debugPrint("Error deleting message: $e");
  }
}
  /// START RECORDING
  Future<void> _startRecording() async {

    _recorder = AudioRecorder();

    if (await _recorder!.hasPermission()) {

      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder!.start(const RecordConfig(), path: path);

      setState(() {
        _isRecording = true;
        _recordDuration = Duration.zero;
        _recordedFile = path;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _recordDuration += const Duration(seconds: 1);
        });
      });
    }
  }

  /// STOP RECORDING
  Future<void> _stopRecording() async {
    _timer?.cancel();
    await _recorder?.stop();
  }

  /// DELETE RECORDING
  void _deleteRecording() {
    _timer?.cancel();

    if (_recordedFile != null) {
      File(_recordedFile!).delete();
    }

    setState(() {
      _isRecording = false;
      _recordDuration = Duration.zero;
      _recordedFile = null;
    });
  }

  /// SEND VOICE NOTE
Future<void> _sendVoice() async {

  if (_recordedFile == null) return;

  // STOP recorder first
  await _stopRecording();

  final file = File(_recordedFile!);
  final bytes = await file.readAsBytes();

  final fileName = "${DateTime.now().millisecondsSinceEpoch}.m4a";
  final storagePath = "voice_notes/$fileName";

  await Supabase.instance.client.storage
      .from('chat-media')
      .uploadBinary(
        storagePath,
        bytes,
        fileOptions: const FileOptions(
          contentType: 'audio/m4a',
          upsert: true,
        ),
      );

  final url = Supabase.instance.client.storage
      .from('chat-media')
      .getPublicUrl(storagePath);
await _chatService.sendMedia(chatId!, url);

_deleteRecording();

  /// auto scroll after sending
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0, // Scroll to bottom (newest message) in reverse ListView
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  });
}

  /// CAMERA + GALLERY PICKER
  Future<void> _pickMedia() async {

    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (context) {

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () async {

                  Navigator.pop(context);

                  final file =
                      await picker.pickImage(source: ImageSource.camera);

                  if (file != null) _previewImage(file);
                },
              ),

              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () async {

                  Navigator.pop(context);

                  final file =
                      await picker.pickImage(source: ImageSource.gallery);

                  if (file != null) _previewImage(file);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// IMAGE PREVIEW
  void _previewImage(XFile file) {

    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Image.file(File(file.path)),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF119E90)),
                  onPressed: () async {

                    Navigator.pop(context);

                    final bytes = await file.readAsBytes();

                    final fileName =
                        DateTime.now().millisecondsSinceEpoch.toString();

                    final path = 'chat_media/$fileName.jpg';

                    await Supabase.instance.client.storage
                        .from('chat-media')
                        .uploadBinary(path, bytes);

                    final url = Supabase.instance.client.storage
                        .from('chat-media')
                        .getPublicUrl(path);

                    await _chatService.sendMedia(chatId!, url);

                    /// auto scroll after sending
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          0.0, // Scroll to bottom (newest message) in reverse ListView
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      }
                    });
                  },
                  child: const Text("Send"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// CHAT INPUT
  Widget _buildChatInput() {

    return Column(
      children: [

        if (_isRecording)
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.red.withOpacity(0.1),
            child: Row(
              children: [

                const Icon(Icons.mic, color: Colors.red),

                const SizedBox(width: 10),

                Text(
                  "${_recordDuration.inMinutes}:${(_recordDuration.inSeconds % 60).toString().padLeft(2, '0')}",
                ),

                const Spacer(),

                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteRecording,
                )
              ],
            ),
          ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Row(
            children: [

              IconButton(
                icon: const Icon(Icons.add, color: Color(0xFF119E90)),
                onPressed: _pickMedia,
              ),

              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Type a message...",
                    border: InputBorder.none,
                  ),
                ),
              ),

              IconButton(
                icon: const Icon(Icons.mic, color: Color(0xFF119E90)),
                onPressed: _startRecording,
              ),

IconButton(
  icon: const Icon(Icons.send, color: Color(0xFF119E90)),
  onPressed: () async {

    if (_recordedFile != null) {
      await _sendVoice();
      return;
    }

    final text = _controller.text.trim();

    if (text.isEmpty) return;

    _controller.clear();
    _sendMessage(text);
  },
),
            ],
          ),
        ),
      ],
    );
  }

  /// HEADER (UNCHANGED)
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

              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                backgroundImage: (widget.profileImage != null &&
                        widget.profileImage!.isNotEmpty)
                    ? NetworkImage(widget.profileImage!)
                    : null,
                child: (widget.profileImage == null ||
                        widget.profileImage!.isEmpty)
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
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
                          fontWeight: FontWeight.bold),
                    ),

                    Text(
                      widget.address ?? "Community Member",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {},
                itemBuilder: (context) => const [

                  PopupMenuItem(
                    value: 'view_profile',
                    child: Text('View Profile'),
                  ),

                    PopupMenuItem(
                    value: 'block',
                    child: Text('Block User'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// CHAT BODY
 @override
Widget build(BuildContext context) {

  return Scaffold(
    backgroundColor: const Color(0xFFF0F9F8),
    body: Column(
      children: [

        _buildPremiumHeader(context),

        Expanded(
          child: chatId == null
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  reverse: false,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];

                    return KeyedSubtree(
                      key: ValueKey(msg.id), // important for Flutter to track items
                      child: MessageBubble(
                        isMe: msg.isMe,
                        message: msg.text,
                        mediaUrl: msg.mediaUrl,
                        createdAt: msg.createdAt,
                        status: msg.status,
                        onDelete: () => _deleteMessage(msg.id, mediaUrl: msg.mediaUrl),
                      ),
                    );
                  },
                ),
        ),

        _buildChatInput(),
      ],
    ),
  );
}}