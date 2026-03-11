import 'package:flutter/material.dart';

const Color surface = Color(0xFFFFFFFF);
const Color accentTeal = Color(0xFF119E90);
const Color backgroundLight = Color(0xFFF8FAFA);

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundLight,
      padding: const EdgeInsets.fromLTRB(40, 30, 40, 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "System Settings",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: const [

                SettingsCard(
                  title: "General Settings",
                  icon: Icons.settings,
                  items: [
                    "Platform Name",
                    "Admin Email",
                    "Contact Number",
                    "Upload Logo",
                  ],
                ),

                SettingsCard(
                  title: "Security Settings",
                  icon: Icons.security,
                  items: [
                    "Change Password",
                    "Two Factor Authentication",
                    "Session Timeout",
                  ],
                ),

                SettingsCard(
                  title: "Notification Settings",
                  icon: Icons.notifications,
                  items: [
                    "Email Notifications",
                    "New User Alerts",
                    "Dispute Alerts",
                  ],
                ),

                SettingsCard(
                  title: "Payment Settings",
                  icon: Icons.payment,
                  items: [
                    "Default Currency",
                    "Transaction Fee",
                    "Payment Gateway",
                  ],
                ),

                SettingsCard(
                  title: "System Maintenance",
                  icon: Icons.build,
                  items: [
                    "Maintenance Mode",
                    "Backup Database",
                    "Clear Cache",
                  ],
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;

  const SettingsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Icon(icon, color: accentTeal),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(item),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                "Configure",
                style: TextStyle(color: accentTeal),
              ),
            ),
          )
        ],
      ),
    );
  }
}