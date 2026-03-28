import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_body.dart';
import 'dashboard_drawer.dart';
import 'notification_screen.dart';
import '../chat/chat_list_screen.dart';
import '../cart_screen.dart';
import '../profile/profile.dart';
import '/services/chat_service.dart';
import '/services/product_cash_confirmation.dart';

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
   final String inviteLink;
   
  const DashboardScreen({super.key, this.isAdmin = false, this.inviteLink = ''});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _hasNotifications = false;

  String? _communityId;
  String _communityName = 'Community';
  String _userName = 'User';
  String _inviteLink = '';
   

  @override
  void initState() {
    super.initState();
    _checkLoggedInUser();
    _fetchUserCommunity(); 
    _checkNotifications();

   WidgetsBinding.instance.addPostFrameCallback((_) {
    _startTransactionWatcher();
  });
}

void _startTransactionWatcher() {
  Future.doWhile(() async {
    await ProductTransactionService.checkPendingTransactions(context);
    await Future.delayed(const Duration(seconds: 3));
    return true;
  });
}
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

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

  Future<void> _checkNotifications() async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) return;

  try {
    // ✅ Get user's communities (FIXED)
    final members = await supabase
        .from('community_members')
        .select('community_id')
        .eq('user_id', user.id);

    if (members.isEmpty) return;

    final communityId = members[0]['community_id'];

    // Get last seen time
    final profile = await supabase
        .from('profiles')
        .select('last_notification_seen')
        .eq('user_id', user.id)
        .maybeSingle();

    final lastSeen = profile?['last_notification_seen'];

    // Fetch notifications
    final data = await supabase
        .from('notifications')
        .select('id')
        .eq('community_id', communityId)
        .gt('created_at', lastSeen ?? '1970-01-01');

    setState(() {
      _hasNotifications = data.isNotEmpty;
    });
  } catch (e) {
    print("Notification check error: $e");
  }
}

Future<void> _fetchUserCommunity() async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) return;

  try {
    // ✅ STEP 1: Get membership
    final members = await supabase
        .from('community_members')
        .select('community_id, role')
        .eq('user_id', user.id);

    // ✅ If NOT member → block access
    if (members.isEmpty) {
      print('❌ User is not part of any community');

      await supabase.auth.signOut(); // optional
      return;
    }

    // ✅ STEP 2: Extract values
    final memberResponse = members[0];
    final communityId = memberResponse['community_id'];

    // ✅ STEP 3: Get community info
    final communityResponse = await supabase
        .from('communities')
        .select('name, invite_link')
        .eq('id', communityId)
        .maybeSingle();

    final communityName = communityResponse?['name'] ?? 'Community';
    final inviteLink = communityResponse?['invite_link'] ?? '';

    // ✅ STEP 4: Get user profile
    final profileResponse = await supabase
        .from('profiles')
        .select('full_name')
        .eq('user_id', user.id)
        .maybeSingle();

    final userName = profileResponse?['full_name'] ?? 'User';

    // ✅ STEP 5: Update UI
    setState(() {
      _communityId = communityId;
      _communityName = communityName;
      _userName = userName;
      _inviteLink = inviteLink;
    });

  } catch (e) {
    print('⚠️ Error fetching dashboard data: $e');
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
        inviteLink: _inviteLink,
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
    Stack(
      children: [
      IconButton(
  icon: const Icon(Icons.notifications_none),
  onPressed: () async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      await Supabase.instance.client
          .from('profiles')
          .update({
            'last_notification_seen': DateTime.now().toIso8601String()
          })
          .eq('user_id', user.id);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationsScreen(),
      ),
    ).then((_) => _checkNotifications());
  },
),
        if (_hasNotifications)
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              height: 10,
              width: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    ),
  ],
      ),
      body: DashboardBody(
        userName: _userName,
        communityName: _communityName,
        isAdmin: widget.isAdmin,
        communityId: _communityId ?? '',
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: _onBottomTap,
        selectedItemColor: appGradient.colors[1],
        unselectedItemColor: Colors.black45,
        type: BottomNavigationBarType.fixed,
        items:  [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
  label: 'Chat',
  icon: StreamBuilder<bool>(
    stream: ChatService().hasUnreadMessages(),
    builder: (context, snapshot) {

      final hasUnread = snapshot.data ?? false;

      return Stack(
        clipBehavior: Clip.none,
        children: [

          const Icon(Icons.chat),

          /// 🔴 GLOBAL UNREAD DOT
          if (hasUnread)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      );
    },
  ),
),
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