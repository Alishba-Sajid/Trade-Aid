import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'usermanagement.dart';
import 'managecommunity.dart';
import 'product_resource_wrapper.dart';
import 'escalated_cases.dart';
import 'notification.dart';
import 'admin_rotation.dart';
import 'community_election.dart';
import 'settings.dart';

/// 🌿 THEME COLORS
const LinearGradient appGradient = LinearGradient(
  colors: [
    Color.fromARGB(255, 15, 119, 124),
    Color.fromARGB(255, 17, 158, 144),
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

const Color surface = Color(0xFFFFFFFF);
const Color backgroundLight = Color(0xFFF8FAFA);
const Color accentTeal = Color(0xFF119E90);

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

          /// HEADER
          Container(
            height: 70,
            decoration: const BoxDecoration(gradient: appGradient),
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Trade & Aid",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Icon(Icons.search, color: Colors.white),
                    SizedBox(width: 25),
                    Icon(Icons.notifications_none, color: Colors.white),
                    SizedBox(width: 25),
                    CircleAvatar(
                      radius: 22,
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

                /// SIDEBAR
                Container(
                  width: 260,
                  decoration: const BoxDecoration(gradient: appGradient),
                  padding: const EdgeInsets.fromLTRB(24, 30, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Admin Portal",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
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
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.22)
                                        : isHovered
                                            ? Colors.white.withValues(
                                                alpha: 0.12)
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(menuIcons[index],
                                          color: Colors.white, size: 18),
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

                /// MAIN CONTENT
                Expanded(
                  child: IndexedStack(
                    index: selectedIndex,
                    children: [
                      _dashboardContent(),
                      const UserManagementScreen(),
                      const ManageCommunityScreen(),
                      const ProductResourceWrapper(),
                      const EscalatedCases(),
                      const NotificationsScreen(),
                      const AdminRotationScreen(),
                      const CommunityElectionHistoryScreen(),
                      const Center(child: Text("Reports & Analytics")),
                      const SettingsScreen(),
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

  /// DASHBOARD CONTENT
  Widget _dashboardContent() {
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

            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: const [
                _InfoCard("Total Users", "12,345"),
                _InfoCard("Communities", "234"),
                _InfoCard("Disputes", "5"),
                _InfoCard("Sales", "50"),
              ],
            ),

            const SizedBox(height: 40),

            /// LINE GRAPH
            const Text(
              "Community Growth",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Container(
              height: 320,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: LineChart(
  LineChartData(
    minY: 0,
    maxY: 300,

    gridData: FlGridData(show: true),
    borderData: FlBorderData(show: false),

    titlesData: FlTitlesData(

      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 1,
          getTitlesWidget: (value, meta) {

            const months = [
              "Jan",
              "Feb",
              "Mar",
              "Apr",
              "May",
              "Jun"
            ];

            if (value.toInt() >= 0 && value.toInt() < months.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(months[value.toInt()]),
              );
            }
            return const Text("");
          },
        ),
      ),

      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: 50,
        ),
      ),

      rightTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),

      topTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    ),

    lineBarsData: [
      LineChartBarData(
        isCurved: true,
        color: accentTeal,
        barWidth: 3,
        spots: const [
          FlSpot(0, 80),
          FlSpot(1, 120),
          FlSpot(2, 150),
          FlSpot(3, 170),
          FlSpot(4, 210),
          FlSpot(5, 250),
        ],
      ),
    ],
  ),
)
            ),

            const SizedBox(height: 40),

Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    /// PIE CHART
    Expanded(
      child: Container(
        height: 320,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8),
          ],
        ),

        child: Column(
          children: [

            const Text(
              "Community Categories",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  sections: [
                    PieChartSectionData(
                      value: 40,
                      title: "40%",
                      color: Colors.green,
                      radius: 60,
                    ),
                    PieChartSectionData(
                      value: 30,
                      title: "30%",
                      color: Colors.orange,
                      radius: 60,
                    ),
                    PieChartSectionData(
                      value: 20,
                      title: "20%",
                      color: Colors.blue,
                      radius: 60,
                    ),
                    PieChartSectionData(
                      value: 10,
                      title: "10%",
                      color: Colors.red,
                      radius: 60,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LegendItem(color: Colors.green, text: "Farming"),
                _LegendItem(color: Colors.orange, text: "Crafts"),
                _LegendItem(color: Colors.blue, text: "Food"),
                _LegendItem(color: Colors.red, text: "Services"),
              ],
            ),
          ],
        ),
      ),
    ),

    /// BAR CHART
    Expanded(
      child: Container(
        height: 320,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8),
          ],
        ),

        child: Column(
          children: [

            const Text(
              "Monthly Sales",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: BarChart(
  BarChartData(
    maxY: 300,
    borderData: FlBorderData(show: false),
    gridData: FlGridData(show: true),

    titlesData: FlTitlesData(

      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 1,
          getTitlesWidget: (value, meta) {

            const months = [
              "Jan",
              "Feb",
              "Mar",
              "Apr",
              "May",
              "Jun"
            ];

            if (value.toInt() >= 0 && value.toInt() < months.length) {
              return Text(months[value.toInt()]);
            }

            return const Text("");
          },
        ),
      ),

      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: 50,
        ),
      ),

      rightTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),

      topTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    ),

    barGroups: [
      BarChartGroupData(x: 0, barRods: [
        BarChartRodData(toY: 120, color: accentTeal)
      ]),
      BarChartGroupData(x: 1, barRods: [
        BarChartRodData(toY: 150, color: accentTeal)
      ]),
      BarChartGroupData(x: 2, barRods: [
        BarChartRodData(toY: 180, color: accentTeal)
      ]),
      BarChartGroupData(x: 3, barRods: [
        BarChartRodData(toY: 210, color: accentTeal)
      ]),
      BarChartGroupData(x: 4, barRods: [
        BarChartRodData(toY: 170, color: accentTeal)
      ]),
      BarChartGroupData(x: 5, barRods: [
        BarChartRodData(toY: 240, color: accentTeal)
      ]),
    ],
  ),
)
            ),
          ],
        ),
      ),
    ),
  ],
)
          ],
        ),
      ),
    );
  }
}

/// INFO CARD
class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 150,
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
                color: accentTeal),
          ),
        ],
      ),
    );
  }
}

/// PIE LEGEND
class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}