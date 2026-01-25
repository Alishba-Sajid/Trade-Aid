import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/app_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBarWidget(
        title: 'Notifications',
        onBack: () => Navigator.pop(context),
      ),
      body: Stack(
        children: [
          ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            children: [
              _buildSectionHeader("RECENT UPDATES"),
              const _PremiumNotificationCard(
                icon: Icons.shopping_bag_rounded,
                title: 'New Product Posted',
                message: 'A new product has been posted in Gulberg Greens.',
                time: '2 mins ago',
                isUnread: true,
              ),
              const _PremiumNotificationCard(
                icon: Icons.auto_awesome_rounded,
                title: 'New Resource Available',
                message: 'Someone shared a new community resource.',
                time: '1 hour ago',
                isUnread: true,
              ),
              const SizedBox(height: 16),
              _buildSectionHeader("PREVIOUS"),
              const _PremiumNotificationCard(
                icon: Icons.local_shipping_rounded,
                title: 'Order Update',
                message: 'Your order #12345 has been successfully placed.',
                time: 'Yesterday',
                isUnread: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Text(
        title,
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
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: darkPrimary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        border: isUnread
            ? Border.all(color: accentTeal.withOpacity(0.25), width: 1.5)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: () {},
          splashColor: accentTeal.withOpacity(0.1),
          highlightColor: Colors.transparent,
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
                    size: 24,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                                fontSize: 15,
                                color: darkPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: accentTeal,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
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
        ),
      ),
    );
  }
}
