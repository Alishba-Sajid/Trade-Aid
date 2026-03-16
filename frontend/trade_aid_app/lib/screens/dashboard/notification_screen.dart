import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/app_bar.dart';

// ───────── COLORS & GRADIENTS ─────────
const Color darkPrimary = Color(0xFF004D40);
const Color accentTeal = Color(0xFF119E90);
const Color backgroundLight = Color(0xFFF0F9F8);
const Color subtleGrey = Color(0xFFE8ECEC);

const LinearGradient appGradient = LinearGradient(
  colors: [Color(0xFF2E9499), Color(0xFF119E90)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final supabase = Supabase.instance.client;

  List notifications = [];

  @override
  void initState() {
    super.initState();

    fetchNotifications();

    // REALTIME LISTENER
    supabase
        .channel('notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          callback: (payload) {
            fetchNotifications();
          },
        )
        .subscribe();
  }

Future<void> fetchNotifications() async {
  final user = supabase.auth.currentUser;

  if (user == null) return;

  try {
    // Get user's community
    final member = await supabase
        .from('community_members')
        .select('community_id')
        .eq('user_id', user.id)
        .single();

    final communityId = member['community_id'];

    // Fetch notifications for that community
final data = await supabase
    .from('notifications')
    .select()
    .eq('community_id', communityId)
    .gte('created_at', DateTime.now().subtract(const Duration(days: 7)).toIso8601String())
    .order('created_at', ascending: false);

    setState(() {
      notifications = data;
    });
  } catch (e) {
    print("Error fetching notifications: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBarWidget(
        title: 'Notifications',
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),

        children: [

  _buildSectionHeader("Recent Updates"),

  ...notifications.map((n) {
    return _PremiumNotificationCard(
      icon: Icons.notifications,
      title: n['title'] ?? '',
      message: n['message'] ?? '',
      time: n['created_at'].toString(),
      isUnread: true,
    );
  }).toList(),

],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          color: darkPrimary.withOpacity(0.5),
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _PremiumNotificationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final bool isUnread;

  const _PremiumNotificationCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
        border: isUnread
            ? Border.all(color: accentTeal.withOpacity(0.3), width: 1.5)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                gradient: isUnread ? appGradient : null,
                color: !isUnread ? subtleGrey : null,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isUnread ? Colors.white : darkPrimary.withOpacity(0.5),
                size: 26,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight:
                          isUnread ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 15,
                      color: darkPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    time,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: accentTeal.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}