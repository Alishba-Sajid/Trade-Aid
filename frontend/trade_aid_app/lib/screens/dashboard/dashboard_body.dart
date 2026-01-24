import 'package:flutter/material.dart';
import 'community_dialog.dart';
import '../wish_request.dart';

// 🌿 Premium Color Constants
const LinearGradient appGradient = LinearGradient(
  colors: [Color(0xFF2E9499), Color(0xFF119E90)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const Color dark = Color(0xFF004D40);
const Color light = Color(0xFFF0F9F8);
const Color accent = Color(0xFF119E90);

/// DashboardBody displays the main content of the dashboard without the search bar.
class DashboardBody extends StatefulWidget {
  final String userName, communityName;

  const DashboardBody({
    super.key,
    required this.userName,
    required this.communityName,
  });

  @override
  State<DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<DashboardBody> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // =========================
            // Gradient Top Section
            // =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 25), // Adjusted bottom padding since search is gone
              decoration: const BoxDecoration(
                gradient: appGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Greeting Row ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hello, ${widget.userName} 👋',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          CommunityDialog.show(
                            context,
                            Community(
                              name: widget.communityName,
                              description:
                                  "This is your current community. All your posts, resources, and activity will appear here.",
                              isCurrent: true,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Colors.white70, Colors.white],
                              ),
                            ),
                            child: const Icon(
                              Icons.location_city_rounded,
                              color: dark,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // --- Sub-greeting and Community Name ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -2),
                        child: Text(
                          'Good to see you today',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          CommunityDialog.show(
                            context,
                            Community(
                              name: widget.communityName,
                              description:
                                  "This is your current community. All your posts, resources, and activity will appear here.",
                              isCurrent: true,
                            ),
                          );
                        },
                        child: Text(
                          widget.communityName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // =========================
            // Main White Section
            // =========================
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Nearby Communities'),
                      const SizedBox(height: 13),
                      SizedBox(
                        height: 130,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          children: const [
                            _CommunityTile(
                              'GG-12',
                              description:
                                  'GG-12 is a premium community for resource sharing, skill development, and community support.',
                            ),
                            _CommunityTile(
                              'GG-13',
                              description:
                                  'GG-13 focuses on sustainability, eco-friendly projects, and collaboration among members.',
                            ),
                            _CommunityTile(
                              'GG-14',
                              description:
                                  'GG-14 is a tech-oriented community where members share knowledge and products.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionHeader('Services'),
                      const SizedBox(height: 13),
                      Row(
                        children: const [
                          Expanded(
                            child: _ServiceCard(
                              title: 'Products',
                              subtitle: 'Browse items',
                              icon: Icons.shopping_cart_outlined,
                              route: '/products',
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _ServiceCard(
                              title: 'Resources',
                              subtitle: 'Available resources',
                              icon: Icons.group,
                              route: '/resources',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSectionHeader('Wish Requests'),
                      const SizedBox(height: 13),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WishRequestsScreen()),
                        ),
                        child: _buildPremiumWishCard(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: dark,
        letterSpacing: 0.2,
      ),
    );
  }

  static Widget _buildPremiumWishCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: dark.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: light,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: accent,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Items Required',
                  style: TextStyle(
                    color: dark,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                Text(
                  'Urgent community needs',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: appGradient,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Text(
              '1 Active',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// Community Tile Widget
// =========================
class _CommunityTile extends StatelessWidget {
  final String name;
  final String description;

  const _CommunityTile(this.name, {required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      width: 100,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              CommunityDialog.show(
                context,
                Community(name: name, description: description),
              );
            },
            child: Container(
              height: 90,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black.withOpacity(0.03)),
                boxShadow: [
                  BoxShadow(
                    color: dark.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: light,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.business_rounded,
                    size: 32,
                    color: accent,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () {
              CommunityDialog.show(
                context,
                Community(name: name, description: description),
              );
            },
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: dark,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// Service Card Widget
// =========================
class _ServiceCard extends StatelessWidget {
  final String title, subtitle, route;
  final IconData icon;

  const _ServiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black.withOpacity(0.03)),
          boxShadow: [
            BoxShadow(
              color: dark.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: appGradient,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(16),
              child: Icon(icon, size: 28, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: dark,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.4),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}