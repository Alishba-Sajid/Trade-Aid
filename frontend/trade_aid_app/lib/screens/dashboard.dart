import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'cart_screen.dart';
import 'product_post.dart';
import 'resource_post.dart';
import 'manage_uploads.dart';

// 🌿 Shared App Colors
const Color kPrimaryTeal = Color(0xFF004D40); // main teal used across the UI
const Color kLightTeal = Color(0xFF70B2B2); // lighter teal accent
const Color kSkyBlue = Color(0xFF9ECFD4); // soft blue used for placeholders

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final String _communityInviteLink = "https://tradeaid.app/invite/eco123";

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat feature coming soon!')),
        );
        break;
      case 2:
        _showCreatePostSheet();
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

  void _showCreatePostSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    color: kPrimaryTeal,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.shopping_bag_outlined, color: kPrimaryTeal),
                  title: const Text('Post a Product', style: TextStyle(color: kPrimaryTeal)),
                  subtitle: const Text('Sell items in your community'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProductPostScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.groups_outlined, color: kPrimaryTeal),
                  title: const Text('Share a Resource', style: TextStyle(color: kPrimaryTeal)),
                  subtitle: const Text('Share items — time-limited'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ResourcePostScreen()),
                    );
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: kPrimaryTeal, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
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
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String communityName = args?['communityName'] ?? 'My Community';

    return Scaffold(
      backgroundColor: Colors.white,
    

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          
          statusBarIconBrightness: Brightness.dark,
        ),
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

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: kPrimaryTeal),
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
                      foregroundColor: kPrimaryTeal,
                    ),
                    icon: const Icon(Icons.copy, color: kPrimaryTeal, size: 18),
                    label: const Text("Copy Invite Link", style: TextStyle(color: kPrimaryTeal)),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: kPrimaryTeal),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_upload_outlined, color: kPrimaryTeal),
              title: const Text('My Uploads'),
              subtitle: const Text('Manage your products & resources'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageUploadsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: kPrimaryTeal),
              title: const Text('Settings'),
              onTap: () {},
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
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
                    color: kPrimaryTeal,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Image.asset(
                  'assets/cart_illustration.png',
                  width: 180,
                  height: 180,
                ),
              ),
              const SizedBox(height: 24),

              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/products'),
                child: const FeatureCard(
                  title: 'Products',
                  subtitle: 'Browse / Purchase Products',
                  icon: Icons.shopping_bag_outlined,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/resources'),
                child: const FeatureCard(
                  title: 'Resource Sharing',
                  subtitle: 'Share / Access Resources\n(time-limited)',
                  icon: Icons.groups_outlined,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Nearby Communities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryTeal,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: const [
                    CommunityCard(icon: Icons.home_work_outlined, label: 'GG-12'),
                    SizedBox(width: 12),
                    CommunityCard(icon: Icons.apartment_outlined, label: 'GG-13'),
                    SizedBox(width: 12),
                    CommunityCard(icon: Icons.location_city_outlined, label: 'GG-14'),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              const Text(
                'Wish Requests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryTeal,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kSkyBlue),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Items Required', style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: kSkyBlue.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: kLightTeal),
                      ),
                      child: const Center(
                        child: Text(
                          '1',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryTeal,
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
        backgroundColor: Colors.white,
        selectedItemColor: kPrimaryTeal,
        unselectedItemColor: kLightTeal.withOpacity(0.7),
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
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
        color: kSkyBlue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800, color: kPrimaryTeal)),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(fontSize: 16, color: kLightTeal)),
              ],
            ),
          ),
          Icon(icon, color: kPrimaryTeal, size: 60),
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
            color: kSkyBlue.withOpacity(0.25),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
            ],
          ),
          child: Center(child: Icon(icon, size: 42, color: kPrimaryTeal)),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: kPrimaryTeal)),
      ],
    );
  }
}
