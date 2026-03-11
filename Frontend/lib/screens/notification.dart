import 'dart:math';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String selectedTab = 'All';

  final List<Map<String, dynamic>> notifications = [
    {
      'icon': Icons.person_add_alt_1_outlined,
      'title': 'New member request from Sarah Miller',
      'time': '2 hours ago',
      'type': 'Member Requests'
    },
    {
      'icon': Icons.warning_amber_rounded,
      'title': 'Fraudulent transaction detected for user David Lee',
      'time': '1 day ago',
      'type': 'Fraud'
    },
    {
      'icon': Icons.report_gmailerrorred_outlined,
      'title': 'Dispute filed by user Emily Chen',
      'time': '2 days ago',
      'type': 'Disputes'
    },
    {
      'icon': Icons.system_update_alt_rounded,
      'title': 'System update: New features available',
      'time': '3 days ago',
      'type': 'System Updates'
    },
    {
      'icon': Icons.person_add_alt_1_outlined,
      'title': 'New member request from Michael Brown',
      'time': '4 days ago',
      'type': 'Member Requests'
    },
    {
      'icon': Icons.warning_amber_rounded,
      'title': 'Fraudulent transaction detected for user Jessica Wilson',
      'time': '5 days ago',
      'type': 'Fraud'
    },
    {
      'icon': Icons.report_gmailerrorred_outlined,
      'title': 'Dispute filed by user Christopher Garcia',
      'time': '6 days ago',
      'type': 'Disputes'
    },
    {
      'icon': Icons.security_update_good_outlined,
      'title': 'System update: Security enhancements',
      'time': '7 days ago',
      'type': 'System Updates'
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = selectedTab == 'All'
        ? notifications
        : notifications.where((n) => n['type'] == selectedTab).toList();

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              // 🌊 INDUSTRIAL GRADIENT BACKGROUND
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.teal.shade700,
                      Colors.teal.shade400,
                      Colors.cyan.shade300,
                    ],
                    stops: [
                      0.2,
                      0.6 + 0.2 * sin(_controller.value * pi * 2),
                      1.0,
                    ],
                  ),
                ),
              ),

              // ✨ FLOATING CIRCLES
              ...List.generate(6, (i) {
                final size = 80.0 + i * 20;
                return Positioned(
                  left: (i * 150) % MediaQuery.of(context).size.width,
                  top: 120 +
                      60 *
                          sin((_controller.value * 2 * pi) + i.toDouble()),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                );
              }),

              // 🧊 MAIN GLASS CARD
              Padding(
                padding: const EdgeInsets.all(30),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 14,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 TITLE
                      const Text(
                        "Notifications Inbox",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🔹 INDUSTRIAL TABS
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final tab in [
                              'All',
                              'Fraud',
                              'Disputes',
                              'Member Requests',
                              'System Updates'
                            ])
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => selectedTab = tab),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: selectedTab == tab
                                          ? Colors.teal.shade600
                                          : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      tab,
                                      style: TextStyle(
                                        color: selectedTab == tab
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Divider(),

                      // 🔔 NOTIFICATION LIST
                      Expanded(
                        child: ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    Colors.teal.shade100,
                                child: Icon(
                                  item['icon'],
                                  color: Colors.teal.shade700,
                                ),
                              ),
                              title: Text(
                                item['title'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                item['time'],
                                style: TextStyle(
                                    color: Colors.grey.shade600),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}