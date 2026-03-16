import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MessageBubble extends StatefulWidget {

  final bool isMe;
  final String message;
  final String? mediaUrl;
  final DateTime createdAt;
final String status;

  const MessageBubble({
    super.key,
    required this.isMe,
    required this.message,
    this.mediaUrl,
     required this.createdAt,
    required this.status,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.mediaUrl != null && widget.mediaUrl!.endsWith('.m4a')) {
      _loadAudio();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadAudio() async {
    try {
      await _player.setUrl(widget.mediaUrl!);
      _duration = _player.duration ?? Duration.zero;
      _player.positionStream.listen((pos) {
        setState(() {
          _position = pos;
        });
      });
      _player.playerStateStream.listen((state) {
        setState(() {
          _isPlaying = state.playing;
        });
      });
    } catch (e) {
      debugPrint("Audio load error: $e");
    }
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }
String _formatTime(DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.hour >= 12 ? "PM" : "AM";

  return "$hour:$minute $period";
}
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
Widget _buildStatusIcon() {

  if (!widget.isMe) return const SizedBox();

  switch (widget.status) {

    case 'sent':
      return const Icon(Icons.check, size: 16, color: Colors.grey);

    case 'delivered':
      return const Icon(Icons.done_all, size: 16, color: Colors.grey);

    case 'seen':
      return const Icon(Icons.done_all, size: 16, color: Colors.blue);

    default:
      return const SizedBox();
  }
}
  @override
  Widget build(BuildContext context) {

    final isImage = widget.mediaUrl != null && (widget.mediaUrl!.endsWith('.jpg') || widget.mediaUrl!.endsWith('.png'));
    final isAudio = widget.mediaUrl != null && widget.mediaUrl!.endsWith('.m4a');

    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(8),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: widget.isMe ? Colors.green[200] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(1, 1),
            ),
          ],
        ),
       child: Column(
  crossAxisAlignment:
      widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
  children: [

    if (isImage)
      GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (_) => Dialog(
                    child: Image.network(widget.mediaUrl!),
                  ));
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            widget.mediaUrl!,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
      ),

    if (isAudio)
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
            onPressed: _togglePlay,
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: _duration.inSeconds > 0
                  ? _position.inSeconds / _duration.inSeconds
                  : 0.0,
              backgroundColor: Colors.grey[300],
              color: Colors.teal,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatDuration(_duration),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),

    if (widget.message.isNotEmpty)
      Text(
        widget.message,
        style: const TextStyle(fontSize: 16),
      ),

    const SizedBox(height: 4),

    /// ✅ TIME + STATUS TICKS
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
        _formatTime(widget.createdAt.toLocal()),
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black54,
          ),
        ),
        const SizedBox(width: 4),
        _buildStatusIcon(),
      ],
    ),
  ],
),
        
      ),
    );
  }

  
}
