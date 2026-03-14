import 'package:flutter/material.dart';

const Color backgroundLight = Color(0xFFF8FAFA);
const Color accentTeal = Color(0xFF119E90);
const Color borderColor = Color(0xFFE4E8E8);

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
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            _sectionTitle("General"),

            SettingsTile(
              icon: Icons.settings,
              title: "Platform Name",
            ),
            SettingsTile(
              icon: Icons.email_outlined,
              title: "Admin Email",
            ),
            SettingsTile(
              icon: Icons.phone,
              title: "Contact Number",
            ),

            const SizedBox(height: 25),

            _sectionTitle("Security"),

            SettingsTile(
              icon: Icons.lock_outline,
              title: "Change Password",
            ),
            SettingsTile(
              icon: Icons.security,
              title: "Two-Factor Authentication",
            ),

            const SizedBox(height: 25),

            _sectionTitle("Notifications"),

            SettingsTile(
              icon: Icons.notifications_outlined,
              title: "Email Notifications",
            ),
            SettingsTile(
              icon: Icons.person_add_alt,
              title: "New User Alerts",
            ),
            SettingsTile(
              icon: Icons.warning_amber_outlined,
              title: "Dispute Alerts",
            ),

            const SizedBox(height: 25),

            _sectionTitle("Payments"),

            SettingsTile(
              icon: Icons.attach_money,
              title: "Default Currency",
            ),
            SettingsTile(
              icon: Icons.percent,
              title: "Transaction Fee",
            ),
            SettingsTile(
              icon: Icons.payment,
              title: "Payment Gateway",
            ),

            const SizedBox(height: 25),

            _sectionTitle("System"),

            SettingsTile(
              icon: Icons.build_outlined,
              title: "Maintenance Mode",
            ),
            SettingsTile(
              icon: Icons.backup,
              title: "Backup Database",
            ),
            SettingsTile(
              icon: Icons.cleaning_services,
              title: "Clear Cache",
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: accentTeal,
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: accentTeal),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}