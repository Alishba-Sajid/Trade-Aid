import 'package:flutter/material.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004D40))),
                const SizedBox(height: 6),
                Text(subtitle,
                    style:
                        const TextStyle(color: Color(0xFF004D40))),
              ],
            ),
          ),
          Icon(icon, size: 60, color: const Color(0xFF00332E)),
        ],
      ),
    );
  }
}

class CommunityCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const CommunityCard({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 84,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 42, color: const Color(0xFF004D40)),
        ),
        const SizedBox(height: 8),
        Text(label,
            style:
                const TextStyle(color: Color(0xFF004D40))),
      ],
    );
  }
}