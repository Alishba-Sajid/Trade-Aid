import 'package:flutter/material.dart';
const LinearGradient appGradient = LinearGradient(
  colors: [Color(0xFF2E9499), Color(0xFF119E90)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class VoiceCallScreen extends StatelessWidget {
  const VoiceCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: appGradient)),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildEncryptionTag(),
                const Spacer(),
                _buildAvatarWithGlow(),
                const SizedBox(height: 32),
                const Text("Ahmed Khan", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const Text("00:45", style: TextStyle(color: Colors.white70, fontSize: 18)),
                const Spacer(),
                _buildCallControls(context),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEncryptionTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock, size: 14, color: Colors.white70),
          SizedBox(width: 8),
          Text("End-to-end encrypted", style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAvatarWithGlow() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(radius: 110, backgroundColor: Colors.white.withOpacity(0.05)),
        CircleAvatar(radius: 90, backgroundColor: Colors.white.withOpacity(0.1)),
        const CircleAvatar(radius: 70, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11')),
      ],
    );
  }

  Widget _buildCallControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(40)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildControlIcon(Icons.mic_off_rounded, "Mute"),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 65,
              width: 65,
              decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
              child: const Icon(Icons.call_end, color: Colors.white, size: 30),
            ),
          ),
          _buildControlIcon(Icons.volume_up_rounded, "Speaker"),
        ],
      ),
    );
  }

  Widget _buildControlIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}