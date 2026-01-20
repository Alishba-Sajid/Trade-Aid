import 'package:flutter/material.dart';
import '../../constants/app_colors.dart'; 
import 'voice_call_screen.dart';
import 'video_call_screen.dart';

const LinearGradient appGradient = LinearGradient(
  colors: [Color(0xFF2E9499), Color(0xFF119E90)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class MemberProfileScreen extends StatelessWidget {
  const MemberProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: light, // Color(0xFFF8FBFB)
      body: Column(
        children: [
          // 🔹 Header Section (Matches Image exactly)
          _buildPremiumHeader(context),

          const SizedBox(height: 20),

          // 🔹 Quick Actions Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.call_rounded,
                  label: "Voice",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceCallScreen())),
                ),
                _ActionButton(
                  icon: Icons.videocam_rounded,
                  label: "Video",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoCallScreen())),
                ),
                _ActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: "Message",
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 🔹 Information Section
          _buildInfoSection(),
        ],
      ),
    );
  }

  // ====================== Header Section ======================
  Widget _buildPremiumHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        // 1. Gradient Background with Curve
        Container(
          height: 220,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: appGradient,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Top Bar with Back Button and Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          "Member Profile",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balancing back icon
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. Centered Profile Card (Avatar + Name)
        Positioned(
          top: 130, // Positioned to overlap the bottom curve
          child: Column(
            children: [
              // Avatar with White Border
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Ahmed Khan",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D1D1D),
                ),
              ),
              const Text(
                "House #23, Block A • Active Member",
                style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),

        // 3. Invisible Spacer to push the Column content below
        const SizedBox(height: 320), 
      ],
    );
  }

  // ====================== Info Section ======================
  Widget _buildInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _infoTile(Icons.phone_iphone_rounded, "Phone", "+92 300 1234567"),
          const Divider(indent: 60, height: 1, color: Color(0xFFF1F1F1)),
          _infoTile(Icons.email_outlined, "Email", "ahmed.khan@community.com"),
          const Divider(indent: 60, height: 1, color: Color(0xFFF1F1F1)),
          _infoTile(Icons.calendar_today_rounded, "Joined", "12 Jan 2024"),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: accent, size: 22),
      ),
      title: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              gradient: appGradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}