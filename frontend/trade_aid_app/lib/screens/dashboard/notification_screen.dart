// lib/screens/notifications/notifications_screen.dart

import 'package:flutter/material.dart';
import './dashboard.dart'; // for appGradient & dark color

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F5F5),
        title: const Text(
          'Notifications',
          style: TextStyle(color: dark, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: dark),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _NotificationCard(
            icon: Icons.shopping_bag_outlined,
            title: 'New Product Posted',
            message: 'A new product has been posted in Gulberg Greens.',
            time: '2 mins ago',
          ),
          _NotificationCard(
            icon: Icons.groups_outlined,
            title: 'New Resource Available',
            message: 'Someone shared a new community resource.',
            time: '1 hour ago',
          ),
          _NotificationCard(
            icon: Icons.shopping_cart_outlined,
            title: 'Order Update',
            message: 'Your order has been successfully placed.',
            time: 'Yesterday',
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String time;

  const _NotificationCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: light,
            child: Icon(icon, color: dark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: dark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
