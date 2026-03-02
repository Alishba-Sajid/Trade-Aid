import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dashboard_body.dart';
import 'dashboard_drawer.dart';
import 'notification_screen.dart';
import '../chat/chat_list_screen.dart';
import '../cart_screen.dart';
import '../profile/profile.dart';

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
  final bool isAdmin;
  const DashboardScreen({super.key, this.isAdmin = false});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  String? _communityId;
  String _communityName = 'Community';
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _checkLoggedInUser();
    _fetchUserCommunity(); // fetch community automatically
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      _communityId = args['communityId'];
      _communityName = args['communityName'] ?? 'Community';
      _userName = args['userName'] ?? 'User';
    }
  }

  void _checkLoggedInUser() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      print("✅ Logged in as: ${user.id}");
    } else {
      print("❌ No user logged in");
    }
  }

  Future<void> _fetchUserCommunity() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // Fetch user's community membership
     final memberResponse = await supabase
    .from('community_members')
    .select('community_id')
    .eq('user_id', user.id)
    .maybeSingle();

      if (memberResponse == null || memberResponse['community_id'] == null) {
        print('⚠️ User is not part of any community');
        return;
      }

      final communityId = memberResponse['community_id'] as String;

      // Fetch community name
      final communityResponse = await supabase
          .from('communities')
          .select('name')
          .eq('id', communityId)
          .maybeSingle();

      final communityName =
          communityResponse?['name'] as String? ?? 'Community';

      setState(() {
        _communityId = communityId;
        _communityName = communityName;
      });

      print('✅ User belongs to community $_communityName ($_communityId)');
    } catch (e) {
      print('⚠️ Error fetching community: $e');
    }
  }

  void _onBottomTap(int index) {
    if (index == 1 || index == 2 || index == 3 || index == 4) {
      switch (index) {
        case 1:
          Navigator.push(
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
                      const Text(
                        'Create a Post',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: dark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Choose what you want to share with your community',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // POST PRODUCT
                      _PremiumPostCard(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Post Product',
                        subtitle: 'Sell Items',
                        onTap: () {
                          Navigator.pop(context);

                          if (_communityId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'You are not part of any community.'),
                              ),
                            );
                            return;
                          }

                          Navigator.pushNamed(
                            context,
                            '/product_post',
                            arguments: _communityId,
                          ).then((_) => setState(() => _currentIndex = 0));
                        },
                      ),

                      const SizedBox(height: 16),
                      Divider(color: Colors.grey[300]),
                      const SizedBox(height: 16),

                      // POST RESOURCE
                      _PremiumPostCard(
                        icon: Icons.groups_outlined,
                        title: 'Post Resource',
                        subtitle: 'Resource Availability',
                        onTap: () {
                          Navigator.pop(context);

                          if (_communityId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'You are not part of any community.'),
                              ),
                            );
                            return;
                          }

                          Navigator.pushNamed(
                            context,
                            '/resource_post',
                            arguments: _communityId,
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: DashboardDrawer(
        communityName: _communityName,
        isAdmin: widget.isAdmin,
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Trade&Aid',
          style: TextStyle(color: dark, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: dark),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: DashboardBody(
        userName: _userName,
        communityName: _communityName,
        isAdmin: widget.isAdmin,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: _onBottomTap,
        selectedItemColor: appGradient.colors[1],
        unselectedItemColor: Colors.black45,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Post'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

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
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}