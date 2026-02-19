import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'usermanagement.dart';
import 'managecommunity.dart';
import 'product_resource_wrapper.dart';
import 'escalated_cases.dart';
import 'notification.dart';
import 'admin_rotation.dart';
import 'community_election.dart';

/// 🌿 APP GRADIENT (USED EVERYWHERE)
final LinearGradient appGradient = LinearGradient(
  colors: const [
    Color(0xFF0F777C),
    Color(0xFF119E90),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const Color accent = Color(0xFF119E90);
const Color surface = Color(0xFFFFFFFF);
const Color backgroundLight = Color(0xFFF8FAFA);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;
  int? hoveredIndex;

  final List<String> menuItems = [
    "Dashboard",
    "User Management",
    "Community Management",
    "Product & Resources",
    "Dispute Resolution",
    "Notifications",
    "Admin Rotation",
    "Community Elections",
    "Reports & Analytics",
    "System Settings",
  ];

  final List<IconData> menuIcons = [
    Icons.dashboard_outlined,
    Icons.people_outline,
    Icons.group_outlined,
    Icons.inventory_2_outlined,
    Icons.report_gmailerrorred_outlined,
    Icons.notifications_outlined,
    Icons.admin_panel_settings_outlined,
    Icons.how_to_vote_outlined,
    Icons.analytics_outlined,
    Icons.settings_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: Column(
        children: [
          /// 🔹 HEADER
          Container(
            height: 70,
            decoration: BoxDecoration(gradient: appGradient),
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Trade & Aid",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: const [
                    Icon(Icons.search, color: Colors.white),
                    SizedBox(width: 25),
                    Icon(Icons.notifications_none, color: Colors.white),
                    SizedBox(width: 25),
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/profile.png'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Row(
              children: [
                /// 🔹 SIDEBAR (GRADIENT — NOT DARK)
                Container(
                  width: 260,
                  decoration: BoxDecoration(gradient: appGradient),
                  padding: const EdgeInsets.fromLTRB(24, 30, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Admin Portal",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),

                      Expanded(
                        child: ListView.builder(
                          itemCount: menuItems.length,
                          itemBuilder: (context, index) {
                            final isSelected = index == selectedIndex;
                            final isHovered = index == hoveredIndex;

                            return MouseRegion(
                              onEnter: (_) =>
                                  setState(() => hoveredIndex = index),
                              onExit: (_) =>
                                  setState(() => hoveredIndex = null),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => selectedIndex = index),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  margin:
                                      const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.25)
                                        : isHovered
                                            ? Colors.white.withValues(
                                                alpha: 0.12)
                                            : Colors.transparent,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    border: isSelected
                                        ? const Border(
                                            left: BorderSide(
                                                color: Colors.white,
                                                width: 4),
                                          )
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        menuIcons[index],
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          menuItems[index],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                /// 🔹 MAIN CONTENT
                Expanded(
                  child: IndexedStack(
                    index: selectedIndex,
                    children: [
                      _buildDashboardContent(),
                      const UserManagementScreen(),
                      const ManageCommunityScreen(),
                      const ProductResourceWrapper(),
                      const EscalatedCasesScreen(),
                      const NotificationsScreen(),
                      const AdminRotationScreen(),
                      const CommunityElectionHistoryScreen(),
                      const Center(child: Text("Reports & Analytics")),
                      const Center(child: Text("System Settings")),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 DASHBOARD CONTENT (CARDS + GRAPH)
  Widget _buildDashboardContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 30, 40, 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dashboard",
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Welcome back, Admin 👋",
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),

            const SizedBox(height: 30),

            /// 🔹 INFO CARDS
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: const [
                _HoverCard(child: _InfoCard("Total Users", "12,345")),
                _HoverCard(child: _InfoCard("New Communities", "234")),
                _HoverCard(child: _InfoCard("Disputes", "5")),
                _HoverCard(child: _InfoCard("Sales", "50")),
              ],
            ),

            const SizedBox(height: 40),

            const Text(
              "Community Growth",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            /// 🔹 GRAPH
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: accent,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                        spots: const [
                          FlSpot(0, 3),
                          FlSpot(1, 2.5),
                          FlSpot(2, 3.8),
                          FlSpot(3, 2.9),
                          FlSpot(4, 4.2),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 INFO CARD
class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  const _InfoCard(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 170,
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
          Text(title, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔹 HOVER EFFECT
class _HoverCard extends StatefulWidget {
  final Widget child;
  const _HoverCard({required this.child});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform:
            hover ? Matrix4.translationValues(0, -6, 0) : Matrix4.identity(),
        child: widget.child,
      ),
    );
  }
}
