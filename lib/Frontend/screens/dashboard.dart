
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'usermanagement.dart';
import 'managecommunity.dart';
import 'product_resource_wrapper.dart';
import 'escalated_cases.dart';
import 'notification.dart';
import 'admin_rotation.dart';
import 'community_election.dart';




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
    "Product and Resource sharing",
    "Dispute Resolution (Escalated Cases)",
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
    Icons.swap_horiz_outlined,
    Icons.report_gmailerrorred_outlined,
    Icons.notification_add,
    Icons.admin_panel_settings,
    Icons.how_to_vote,
    Icons.analytics_outlined,
    
    Icons.settings_outlined,
  ];

  // ✅ Pages shown in main content area
  final List<Widget> pages = const [
    SizedBox(), // placeholder for dashboard (we'll build it manually)
    UserManagementScreen(),
    ManageCommunityScreen(),
   
    Center(child: Text("Dispute Resolution (Escalated Cases)")),
    Center(child: Text("Reports & Analytics")),
    Center(child: Text("System Settings")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 🔹 Header
          Container(
            height: 65,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.black12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 24),
                  child: Text(
                    "Trade&Aid",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search,
                          color: Colors.black87, size: 28),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none_outlined,
                          color: Colors.black87, size: 28),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 10),
                    const CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/profile.png'),
                      backgroundColor: Colors.black26,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🔹 Body Section
          Expanded(
            child: Row(
              children: [
                // ✅ Sidebar
                Container(
                  width: 270,
                  color: Colors.white10,
                  padding: const EdgeInsets.fromLTRB(50, 40, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Admin Portal",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sidebar options
                      Expanded(
                        child: ListView.builder(
                          itemCount: menuItems.length,
                          itemBuilder: (context, index) {
                            final isSelected = index == selectedIndex;
                            final isHovered = index == hoveredIndex;
                            return MouseRegion(
                              onEnter: (_) =>
                                  setState(() => hoveredIndex = index),
                              onExit: (_) => setState(() => hoveredIndex = null),
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                               onTap: () {
  setState(() => selectedIndex = index);

  // 🧭 Navigation logic
  
},

                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color.fromARGB(255, 204, 198, 198)
                                        : isHovered
                                            ? Colors.grey[200]
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: isSelected
                                        ? const Border(
                                            left: BorderSide(
                                              color: Colors.blueAccent,
                                              width: 4,
                                            ),
                                          )
                                        : null,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: Row(
                                    children: [
                                      Icon(
                                        menuIcons[index],
                                        color: Colors.black87,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          menuItems[index],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: Colors.black87,
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

                // ✅ Main Content Area
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

  // ✅ Dashboard Main Content
  Widget _buildDashboardContent() {
    return Container(
      padding: const EdgeInsets.fromLTRB(100, 30, 40, 20),
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dashboard",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),

            // Info Cards
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                _infoCard("Total Users & Communities", "12,345"),
                _infoCard("New Communities Created (last 7 days)", "234"),
                _infoCard("Disputes", "5"),
                _infoCard("Total Sales & Resource Booking", "50"),
              ],
            ),
            const SizedBox(height: 30),

            const Text(
              "Community Growth Graph",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),

            // Graph
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                     color: Colors.black.withValues(alpha: 0.09),

                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Community Growth",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "+12%",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Last 30 Days +12%",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 150,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const months = [
                                  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                                ];
                                if (value.toInt() >= 0 &&
                                    value.toInt() < months.length) {
                                  return Text(
                                    months[value.toInt()],
                                    style: const TextStyle(fontSize: 10),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles:
                              AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles:
                              AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles:
                              AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            color: Colors.blueAccent,
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                            spots: const [
                              FlSpot(0, 3),
                              FlSpot(1, 2.5),
                              FlSpot(2, 3.8),
                              FlSpot(3, 2.9),
                              FlSpot(4, 4.2),
                              FlSpot(5, 3.6),
                              FlSpot(6, 4.5),
                              FlSpot(7, 3.8),
                              FlSpot(8, 4.0),
                              FlSpot(9, 4.4),
                              FlSpot(10, 4.1),
                              FlSpot(11, 4.8),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Info Card Widget
  static Widget _infoCard(String title, String value) {
    return Container(
      width: 400,
      height: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            
            blurRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
