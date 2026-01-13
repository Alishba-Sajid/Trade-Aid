import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
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
  Widget build(BuildContext context) {
    final filtered = selectedTab == 'All'
        ? notifications
        : notifications.where((n) => n['type'] == selectedTab).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 40, 50, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Title
            const Text(
              "Notifications Inbox",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 🔹 Tabs
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
                      padding: const EdgeInsets.only(right: 20),
                      child: GestureDetector(
                        onTap: () => setState(() => selectedTab = tab),
                        child: Text(
                          tab,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: selectedTab == tab
                                ? Colors.blue
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const Divider(height: 30, thickness: 1),

            // 🔹 Notification List (Fixed with Expanded)
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: Icon(item['icon'], color: Colors.grey[800]),
                    ),
                    title: Text(
                      item['title'],
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(item['time'],
                        style: TextStyle(color: Colors.grey[600])),
                    trailing: const Icon(Icons.chevron_right),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
