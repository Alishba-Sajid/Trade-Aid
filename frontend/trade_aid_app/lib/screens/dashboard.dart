import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'cart_screen.dart';
import 'product_post.dart';
import 'resource_post.dart';
import 'manage_uploads.dart'; // <- ADD THIS IMPORT (file containing ManageUploadsScreen)

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Mock invite link (will come from backend later)
  final String _communityInviteLink = "https://tradeaid.app/invite/eco123";

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        break;
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat feature coming soon!')),
        );
        break;
      case 2:
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          backgroundColor: const Color.fromARGB(255, 249, 249, 249),
          builder: (context) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 6),
                    Container(
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Create a Post',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF004D40),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(
                        Icons.shopping_bag_outlined,
                        color: Color(0xFF004D40),
                      ),
                      title: const Text(
                        'Post a Product',
                        style: TextStyle(color: Color(0xFF004D40)),
                      ),
                      subtitle: const Text('Sell items in your community'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProductPostScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.groups_outlined,
                        color: Color(0xFF004D40),
                      ),
                      title: const Text(
                        'Share a Resource',
                        style: TextStyle(color: Color(0xFF004D40)),
                      ),
                      subtitle: const Text('Share items — time-limited'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ResourcePostScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF004D40),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartScreen()),
        );
        break;
      case 4:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile feature coming soon!')),
        );
        break;
    }
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: _communityInviteLink));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite link copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 👇 Get community name from route arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String communityName = args != null && args['communityName'] != null
        ? args['communityName']
        : 'My Community';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F9FB),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Trade&Aid',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),

      // 👇 Drawer with Community Name and Invite Link only
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF004D40)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    communityName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _communityInviteLink,
                    style: const TextStyle(color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _copyLink,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF004D40),
                    ),
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text("Copy Invite Link"),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),

            // <-- NEW: My Uploads entry added here -->
            ListTile(
              leading: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF004D40)),
              title: const Text('My Uploads'),
              subtitle: const Text('Manage your products & resources'),
              onTap: () {
                // close drawer then navigate to ManageUploadsScreen
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageUploadsScreen()),
                );
              },
            ),
            // <-- end new entry -->

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {},
            ),
          ],
        ),
      ),

      // 👇 Main Dashboard Body (without community section)
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Happy Shopping',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF004D40),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Image.asset(
                  'assets/cart_illustration.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),

              // 🧩 Feature Cards
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/products');
                },
                child: const FeatureCard(
                  title: 'Products',
                  subtitle: 'Browse / Purchase Products',
                  icon: Icons.shopping_bag_outlined,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/resources');
                },
                child: const FeatureCard(
                  title: 'Resource Sharing',
                  subtitle: 'Share / Access Resources\n(time-limited)',
                  icon: Icons.groups_outlined,
                ),
              ),
              const SizedBox(height: 20),

              // Nearby Communities
              const Text(
                'Nearby Communities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004D40),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: const [
                    CommunityCard(
                      icon: Icons.home_work_outlined,
                      label: 'GG-12',
                    ),
                    SizedBox(width: 12),
                    CommunityCard(
                      icon: Icons.apartment_outlined,
                      label: 'GG-13',
                    ),
                    SizedBox(width: 12),
                    CommunityCard(
                      icon: Icons.location_city_outlined,
                      label: 'GG-14',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Wish Requests Section
              const Text(
                'Wish Requests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004D40),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0F2F1)),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Items Required',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFB2DFDB)),
                      ),
                      child: const Center(
                        child: Text(
                          '1',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF004D40),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF004D40),
        unselectedItemColor: Colors.black45,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF004D40),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF004D40),
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: const Color(0xFF00332E), size: 60),
        ],
      ),
    );
  }
}

class CommunityCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const CommunityCard({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 84,
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2F1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(icon, size: 42, color: const Color(0xFF004D40)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Color(0xFF004D40))),
      ],
    );
  }
}
