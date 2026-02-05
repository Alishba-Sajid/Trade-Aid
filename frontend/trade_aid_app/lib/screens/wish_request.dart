import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/post_wish_request.dart';
import '../widgets/app_bar.dart';
import '../screens/chat/chat_screen.dart'; // Import ChatScreen

// 🎨 COLORS
const LinearGradient appGradient = LinearGradient(
  colors: [
    Color.fromARGB(255, 15, 119, 124),
    Color.fromARGB(255, 17, 158, 144),
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

class WishRequestsScreen extends StatefulWidget {
  const WishRequestsScreen({super.key});

  @override
  State<WishRequestsScreen> createState() => _WishRequestsScreenState();
}

class _WishRequestsScreenState extends State<WishRequestsScreen> {
  // ───────── SAMPLE DATA ─────────
  final List<Map<String, dynamic>> requests = [
    {
      'requester': 'Ali Khan',
      'item': 'Iron',
      'description': 'Need a steam iron for 2 hours for formal clothes.',
      'timeAgo': '10 mins ago',
      'urgency': 'High',
    },
    {
      'requester': 'Saba Ahmed',
      'item': 'Tubelight',
      'description':
          'My kitchen light fused. Does anyone have a spare LED tubelight?',
      'timeAgo': '1 hour ago',
      'urgency': 'Normal',
    },
  ];

  // ───────── MAIN BUILD ─────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBarWidget(
        title: 'Wish Requests',
        onBack: () => Navigator.pop(context),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
        itemCount: requests.length,
        itemBuilder: (context, index) => _buildRequestCard(requests[index]),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: appGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PostWishRequestScreen()),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Post Request',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───────── "I Can Help" DIALOG ─────────
  void _showPostDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Post',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create a Post',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Choose what you want to share with your community',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Option: Post Product
                      _PremiumPostCard(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Post Product',
                        subtitle: 'Sell Items',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/product_post');
                        },
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey[300], thickness: 1),
                      const SizedBox(height: 16),
                      // Option: Post Resource
                      _PremiumPostCard(
                        icon: Icons.groups_outlined,
                        title: 'Post Resource',
                        subtitle: 'Resource Availability',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/resource_post');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ───────── PREMIUM POST CARD ─────────
  Widget _PremiumPostCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: appGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2), // subtle contrast
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }

  // ───────── REQUEST CARD ─────────
  Widget _buildRequestCard(Map<String, dynamic> request) {
    bool isHighUrgency = request['urgency'] == 'High';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: darkPrimary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ← Vertical urgency line
              Container(
                width: 6,
                color: isHighUrgency ? Colors.orangeAccent : accentTeal,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Requester info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: backgroundLight,
                                child: Text(
                                  request['requester'][0],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: darkPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                request['requester'],
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            request['timeAgo'],
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Wish: ${request['item']}",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        request['description'],
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _showPostDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentTeal.withOpacity(0.1),
                                foregroundColor: accentTeal,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                "I Can Help",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // ← Chat Icon
                          _buildSmallIconButton(Icons.chat_bubble_outline, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  sellerName: request['requester'],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────── SMALL ICON BUTTON ─────────
  Widget _buildSmallIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: darkPrimary, size: 20),
      ),
    );
  }
}