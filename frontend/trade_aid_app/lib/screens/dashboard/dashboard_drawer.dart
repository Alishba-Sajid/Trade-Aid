import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../manage_uploads.dart';
import '../welcome_screen.dart'; // For logout navigation
import '../pending_request.dart';
// 🌿 Color Palette
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

class DashboardDrawer extends StatelessWidget {
  final String communityName;

  const DashboardDrawer({super.key, required this.communityName});

  final String inviteLink = 'https://tradeaid.app/invite/eco123';

  void onCopy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: inviteLink));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite link copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 🔐 Logout Confirmation Dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (_) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔹 Circular Logout Icon
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: light,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: dark,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Log out?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: dark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Are you sure you want to log out from this community?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            side: BorderSide(color: dark.withOpacity(0.3)),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: dark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Gradient Log Out Button
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: appGradient,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WelcomeScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Log Out',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF6F9FB),
      child: Column(
        children: [
          // 🔥 HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
            decoration: const BoxDecoration(
              gradient: appGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_city_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  communityName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  inviteLink,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => onCopy(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.copy, size: 18, color: dark),
                        SizedBox(width: 8),
                        Text(
                          'Copy Invite Link',
                          style: TextStyle(
                            color: dark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 📂 MENU ITEMS
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _DrawerTile(
  icon: Icons.person_add_alt_1_rounded,
  title: 'Pending Requests',
  onTap: () {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PendingRequestsScreen(),
      ),
    );
  },
),

                _DrawerTile(
                  icon: Icons.upload_rounded,
                  title: 'Manage Uploads',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManageUploadsScreen(),
                      ),
                    );
                  },
                ),
                _DrawerTile(
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  onTap: () {},
                ),
              ],
            ),
          ),

          // 🚪 LOGOUT BUTTON
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: GestureDetector(
              onTap: () => _showLogoutDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.logout_rounded, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🎨 CUSTOM DRAWER TILE
class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: light, shape: BoxShape.circle),
          child: Icon(icon, color: dark),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, color: dark),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Colors.black38,
        ),
      ),
    );
  }
}
