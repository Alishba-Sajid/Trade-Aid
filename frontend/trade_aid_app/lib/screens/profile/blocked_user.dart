import 'dart:convert'; // ignore: unused_import
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // ignore: unused_import

/// =======================
/// PREMIUM COLOR PALETTE
/// =======================
class AppColors {
  static const Color darkPrimary = Color(0xFF004D40);
  static const Color backgroundLight = Color(0xFFF0F9F8);
  static const Color accentTeal = Color(0xFF119E90);
  static const Color subtleGrey = Color(0xFFE0E0E0);

  static const LinearGradient appGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 15, 119, 124),
      Color.fromARGB(255, 17, 158, 144),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// =======================
/// MODEL FOR BLOCKED USER
/// =======================
class BlockedUser {
  final String name;
  final String location;
  final double rating;

  BlockedUser({
    required this.name,
    required this.location,
    required this.rating,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }
}

/// =======================
/// BLOCKED USERS SCREEN
/// =======================
class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  List<BlockedUser> blockedUsers = [];

  @override
  void initState() {
    super.initState();
    blockedUsers = [
      BlockedUser(
        name: 'Ahmed Khan',
        location: 'House245, Gulberg, Lahore',
        rating: 4.5,
      ),
      BlockedUser(
        name: 'Sara Ali',
        location: 'House246, Gulberg, Lahore',
        rating: 5.0,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: blockedUsers.length,
              itemBuilder: (context, index) {
                final user = blockedUsers[index];
                return _BlockedUserCard(
                  data: user,
                  onUnblock: () => _showConfirmDialog(
                    context,
                    title: 'Unblock User',
                    message: 'Do you really want to unblock ${user.name}?',
                    confirmText: 'Unblock',
                    isUnblock: true,
                  ),
                  onKeepBlocked: () => _showConfirmDialog(
                    context,
                    title: 'Keep Blocked',
                    message: 'Do you want to keep ${user.name} blocked?',
                    confirmText: 'Keep Blocked',
                    isUnblock: false,
                  ),
                  onProfileTap: () => _showProfileDialog(context, user),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// =======================
/// HEADER
/// =======================
Widget _buildHeader(BuildContext context) {
  return Container(
    height: 130,
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromARGB(255, 15, 119, 124),
          Color.fromARGB(255, 17, 158, 144),
        ],
      ),
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 🔙 Back Button
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),

            // 🏷 Heading
            const Text(
              'Blocked Users',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            // Placeholder for spacing (matches attached layout)
            const SizedBox(width: 48),
          ],
        ),
      ),
    ),
  );
}

  /// =======================
  /// CONFIRM DIALOG (DITTO)
  /// =======================
  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required bool isUnblock,
  }) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.darkPrimary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.darkPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient:
                            isUnblock ? AppColors.appGradient : null,
                        color: isUnblock
                            ? null
                            : const Color.fromARGB(255, 164, 10, 10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isUnblock
                                    ?  'Unblocked successfully'
                                    : 'Remains blocked',
                              ),
                              backgroundColor: isUnblock
                                  ? AppColors.accentTeal
                                  : const Color.fromARGB(255, 164, 10, 10),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          confirmText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
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
  }

  /// =======================
  /// PROFILE DIALOG (DITTO)
  /// =======================
  void _showProfileDialog(BuildContext context, BlockedUser data) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.transparent),
            ),
            Center(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 100,
                      decoration: const BoxDecoration(
                        gradient: AppColors.appGradient,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: const Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person,
                              size: 45,
                              color: AppColors.accentTeal),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            data.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              5,
                              (index) => Icon(
                                index < data.rating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on,
                                  size: 16,
                                  color: AppColors.darkPrimary),
                              const SizedBox(width: 4),
                              Text(
                                data.location,
                                style: TextStyle(
                                  color: AppColors.darkPrimary
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.appGradient.colors.first,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 50),
                            ),
                            child: const Text(
                              'Close',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =======================
/// BLOCKED USER CARD (DITTO)
/// =======================
class _BlockedUserCard extends StatelessWidget {
  final BlockedUser data;
  final VoidCallback onUnblock;
  final VoidCallback onKeepBlocked;
  final VoidCallback onProfileTap;

  const _BlockedUserCard({
    required this.data,
    required this.onUnblock,
    required this.onKeepBlocked,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InkWell(
              onTap: onProfileTap,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.subtleGrey,
                    child: Icon(Icons.person,
                        color: AppColors.accentTeal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkPrimary),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              data.location,
                              style:
                                  TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onKeepBlocked,
                    style: OutlinedButton.styleFrom(
                      side:
                          const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Keep Blocked',
                      style:
                          TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.appGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      onPressed: onUnblock,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Unblock',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
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
