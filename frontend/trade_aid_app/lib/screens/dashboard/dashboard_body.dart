import 'package:flutter/material.dart';

class DashboardBody extends StatelessWidget {
  final String userName;
  final String communityName;

  const DashboardBody({
    super.key,
    required this.userName,
    required this.communityName,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello $userName!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004D40),
                      ),
                    ),
                    const Text(
                      'Good to see you',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFFE0F2F1),
                    child: Icon(Icons.groups, color: Color(0xFF004D40)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    communityName,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 20),

          // Search
          TextField(
            decoration: InputDecoration(
              hintText: 'Search Products/Resources',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Nearby Communities
          const Text(
            'Nearby Communities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004D40),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _CommunityTile('GG-12'),
                _CommunityTile('GG-13'),
                _CommunityTile('GG-14'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Services
          const Text(
            'Services',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004D40),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ServiceCard(
                  title: 'Products',
                  subtitle: 'Browse & Purchase',
                  icon: Icons.shopping_bag_outlined,
                  onTap: () =>
                      Navigator.pushNamed(context, '/products'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ServiceCard(
                  title: 'Resource Sharing',
                  subtitle: 'Time-limited',
                  icon: Icons.groups_outlined,
                  onTap: () =>
                      Navigator.pushNamed(context, '/resources'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Wish Requests
          const Text(
            'Wish Requests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004D40),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE0F2F1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Items Required'),
                CircleAvatar(
                  backgroundColor: Color(0xFFE0F2F1),
                  child: Text(
                    '1',
                    style: TextStyle(
                      color: Color(0xFF004D40),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _CommunityTile extends StatelessWidget {
  final String name;
  const _CommunityTile(this.name);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 84,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_city,
                size: 40, color: Color(0xFF004D40)),
          ),
          const SizedBox(height: 6),
          Text(name),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFD9F2F0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: const Color(0xFF004D40)),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}