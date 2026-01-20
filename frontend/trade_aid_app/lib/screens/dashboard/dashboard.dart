import 'dart:ui';
import 'package:flutter/material.dart';
import 'dashboard_body.dart';
import 'dashboard_drawer.dart';
import '../cart_screen.dart';
import '../profile/profile.dart';
import '../chat/chat_list_screen.dart';

const LinearGradient appGradient = LinearGradient(
  colors: [
    Color.fromARGB(255, 15, 119, 124),
    Color.fromARGB(255, 17, 158, 144),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const Color dark = Color(0xFF004D40);
const Color light = Color(0xFFE0F2F1);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  void _onBottomTap(int index) {
    // For Post, Cart, Chat, Profile, we don't want to select the tab permanently
    if (index == 1 || index == 2 || index == 3 || index == 4) {
      switch (index) {
        case 1:
          ScaffoldMessenger.of(
            context,
          ); Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatListScreen()),
          ).then((_) => setState(() => _currentIndex = 0));
          break;
        case 2:
          _showPostDialog();
          break;
        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          ).then((_) => setState(() => _currentIndex = 0));
          break;
        case 4:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ).then((_) => setState(() => _currentIndex = 0));
          break;
      }
      return;
    }

    setState(() => _currentIndex = index);
  }

  void _showPostDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Post',
      barrierColor: Colors.black45,
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
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: dark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Choose what you want to share with your community',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 🟢 Post Product
                      _PremiumPostCard(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Post Product',
                        subtitle: 'Sell Items',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            '/product_post',
                          ).then((_) => setState(() => _currentIndex = 0));
                        },
                      ),

                      const SizedBox(height: 16),
                      Divider(color: Colors.grey[300], thickness: 1),
                      const SizedBox(height: 16),

                      // 🟢 Post Resource
                      _PremiumPostCard(
                        icon: Icons.groups_outlined,
                        title: 'Post Resource',
                        subtitle: 'Resource Availability',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            '/resource_post',
                          ).then((_) => setState(() => _currentIndex = 0));
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

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String userName = args?['userName'] ?? 'Ayesha';
    final String communityName = args?['communityName'] ?? 'Gulberg Greens';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: DashboardDrawer(communityName: communityName),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Trade&Aid',
          style: TextStyle(color: dark, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: dark),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: DashboardBody(userName: userName, communityName: communityName),
      bottomNavigationBar: Theme(
        data: Theme.of(
          context,
        ).copyWith(highlightColor: appGradient.colors[0].withOpacity(0.2)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onBottomTap,
          backgroundColor: Colors.white,
          selectedItemColor: appGradient.colors[1],
          unselectedItemColor: Colors.black45,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Post'),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

// 🌟 PREMIUM POST CARD FOR DIALOG
class _PremiumPostCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PremiumPostCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: dark.withOpacity(0.1),
      highlightColor: dark.withOpacity(0.05),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: appGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: dark.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: Icon(icon, color: dark),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
