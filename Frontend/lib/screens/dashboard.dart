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

/// =====================
/// YOUR THEME (KEEP IT)
/// =====================
const Color primaryTeal = Color(0xFF2E9499);
const Color secondaryTeal = Color(0xFF119E90);
const Color surfaceWhite = Color(0xFFFFFFFF);
const Color textPrimary = Color(0xFF121212);
const Color textSecondary = Color(0xFF5F6368);
const Color dark = Color(0xFF004D40);

const LinearGradient appGradient = LinearGradient(
  colors: [primaryTeal, secondaryTeal],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

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
      backgroundColor: const Color(0xFFF4F7F7),

      body: Column(
        children: [

          /// =====================
          /// HEADER
          /// =====================
          Container(
            height: 70,
            decoration: const BoxDecoration(
              gradient: appGradient,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Trade & Aid",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
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

                /// =====================
                /// SIDEBAR
                /// =====================
                Container(
                  width: 260,
                  decoration: const BoxDecoration(
                    gradient: appGradient,
                  ),
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
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha:0.22)
                                        : isHovered
                                            ? Colors.white.withValues(alpha:0.12)
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

                /// =====================
                /// MAIN CONTENT
                /// =====================
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

  /// =====================
  /// DASHBOARD CONTENT
  /// =====================
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

          /// =====================
          /// INFO CARDS (UNCHANGED)
          /// =====================
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

          /// =====================
          /// LINE CHART (YOUR ORIGINAL STYLE)
          /// =====================
          const Text(
            "Community Growth",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          Container(
            height: 320,
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration(),
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 400,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha:0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          "Jan","Feb","Mar","Apr","May","Jun",
                          "Jul","Aug","Sep","Oct","Nov","Dec"
                        ];
                        if (value.toInt() >= 0 &&
                            value.toInt() < months.length) {
                          return Text(months[value.toInt()]);
                        }
                        return const Text("");
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles:
                        SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: const Color(0xFF119E90),
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    spots: const [
                      FlSpot(0, 80),
                      FlSpot(1, 120),
                      FlSpot(2, 150),
                      FlSpot(3, 170),
                      FlSpot(4, 210),
                      FlSpot(5, 250),
                      FlSpot(6, 230),
                      FlSpot(7, 260),
                      FlSpot(8, 280),
                      FlSpot(9, 300),
                      FlSpot(10, 320),
                      FlSpot(11, 350),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          /// =====================
          /// PIE + BAR (RESTORED SIDE BY SIDE LIKE YOUR ORIGINAL DESIGN)
          /// =====================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// PIE CHART
              Expanded(
                child: Container(
                  height: 320,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(right: 10),
                  decoration: _cardDecoration(),
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                      sections: [
                        PieChartSectionData(
                            value: 40,
                            title: "40%",
                            color: Colors.green,
                            radius: 60),
                        PieChartSectionData(
                            value: 30,
                            title: "30%",
                            color: Colors.orange,
                            radius: 60),
                        PieChartSectionData(
                            value: 20,
                            title: "20%",
                            color: Colors.blue,
                            radius: 60),
                        PieChartSectionData(
                            value: 10,
                            title: "10%",
                            color: Colors.red,
                            radius: 60),
                      ],
                    ),
                  ),
                ),
              ),

              /// BAR CHART
              Expanded(
                child: Container(
                  height: 320,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(left: 10),
                  decoration: _cardDecoration(),
                  child: BarChart(
                    BarChartData(
                      maxY: 300,
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              const months = [
                                "Jan","Feb","Mar","Apr","May","Jun"
                              ];
                              if (value.toInt() >= 0 &&
                                  value.toInt() < months.length) {
                                return Text(months[value.toInt()]);
                              }
                              return const Text("");
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: true, reservedSize: 40),
                        ),
                        rightTitles:
                            AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles:
                            AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [
                          BarChartRodData(toY: 120, color: const Color(0xFF119E90))
                        ]),
                        BarChartGroupData(x: 1, barRods: [
                          BarChartRodData(toY: 150, color: const Color(0xFF119E90))
                        ]),
                        BarChartGroupData(x: 2, barRods: [
                          BarChartRodData(toY: 180, color: const Color(0xFF119E90))
                        ]),
                        BarChartGroupData(x: 3, barRods: [
                          BarChartRodData(toY: 210, color: const Color(0xFF119E90))
                        ]),
                        BarChartGroupData(x: 4, barRods: [
                          BarChartRodData(toY: 170, color: const Color(0xFF119E90))
                        ]),
                        BarChartGroupData(x: 5, barRods: [
                          BarChartRodData(toY: 240, color: const Color(0xFF119E90))
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}

/// =====================
/// CARD DECORATION
/// =====================
BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: surfaceWhite,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: const Color(0xFFE4E8E8)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha:0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

/// =====================
/// INFO CARD
/// =====================
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
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: textSecondary)),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryTeal,
            ),
          ),
        ],
      ),
    );
  }
}