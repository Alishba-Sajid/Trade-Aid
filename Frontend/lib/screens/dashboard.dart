
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'usermanagement.dart';
import 'managecommunity.dart';
import 'product_resource_wrapper.dart';
import 'escalated_cases.dart';
import 'notification.dart';
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

  Uint8List? _profileImage;
  

  int totalUsers = 0;
  int totalCommunities = 0;
  int totalDisputes = 0;
  int totalSales = 0;

  bool isLoading = true;

  List<FlSpot> communityGrowthSpots = [];
bool isGraphLoading = true;


int totalProducts = 0;
int totalResources = 0;
int resolvedDisputes = 0;
int pendingDisputes = 0;
bool isPieLoading = true;

//bar chart varibales

List<double> monthlyPercentages = List.filled(12, 0.0);
bool isBarLoading = true;


String? imageUrl;
final supabase = Supabase.instance.client;

User? user;



Future<void> fetchMonthlyCompletionPercentage() async {
  final supabase = Supabase.instance.client;

  try {
    final data = await supabase
        .from('transactions')
        .select('created_at, status');

    List<int> totalPerMonth = List.filled(12, 0);
    List<int> completedPerMonth = List.filled(12, 0);

    for (var item in data) {
      final date = DateTime.parse(item['created_at']);
      int monthIndex = date.month - 1;

      if (monthIndex >= 0 && monthIndex < 12) {
        totalPerMonth[monthIndex]++;

        if (item['status'] == 'completed') {
          completedPerMonth[monthIndex]++;
        }
      }
    }

    setState(() {
      for (int i = 0; i < 12; i++) {
        if (totalPerMonth[i] == 0) {
          monthlyPercentages[i] = 0;
        } else {
          monthlyPercentages[i] =
              (completedPerMonth[i] / totalPerMonth[i]) * 100;
        }
      }
      isBarLoading = false;
    });

    debugPrint("Total: $totalPerMonth");
    debugPrint("Completed: $completedPerMonth");

  } catch (e) {
    debugPrint("Error: $e");
    setState(() => isBarLoading = false);
  }
}



Future<void> fetchPieChartData() async {
  final supabase = Supabase.instance.client;

  try {
    final products = await supabase
        .from('products')
        .select();

    final resources = await supabase
        .from('resources')
        .select();

    final disputes = await supabase
        .from('complaints')
        .select();

    /// ✅ FORCE LIST (important fix)
    final productList = List<Map<String, dynamic>>.from(products);
    final resourceList = List<Map<String, dynamic>>.from(resources);
    final disputeList = List<Map<String, dynamic>>.from(disputes);

    setState(() {
      totalProducts = productList.length;
      totalResources = resourceList.length;
      totalDisputes = disputeList.length;
      isPieLoading = false;
    });

    /// 🔍 DEBUG (MUST CHECK)
    debugPrint("Products: $totalProducts");
    debugPrint("Resources: $totalResources");
    debugPrint("Disputes: $totalDisputes");

  } catch (e) {
    debugPrint("Pie Error: $e");
    setState(() => isPieLoading = false);
  }
}


Future<void> fetchCommunityGrowth() async {
  final supabase = Supabase.instance.client;

  try {
    final data = await supabase
        .from('communities')
        .select('created_at');

    List<int> monthlyCounts = List.filled(12, 0);

    for (var item in data) {
      final date = DateTime.parse(item['created_at']);
      int monthIndex = date.month - 1;
      monthlyCounts[monthIndex]++;
    }

    /// ✅ STEP 1: get max value
    int maxValue = monthlyCounts.reduce((a, b) => a > b ? a : b);

    /// ⚠️ prevent divide by 0
    if (maxValue == 0) maxValue = 1;

    /// ✅ STEP 2: convert to %
    communityGrowthSpots = monthlyCounts
    .asMap()
    .entries
    .map((e) {
      double percent = (e.value * 5.0).clamp(0, 100); // 👈 HERE
      return FlSpot(e.key.toDouble(), percent);
    })
    .toList();

    setState(() {
      isGraphLoading = false;
    });
  } catch (e) {
    debugPrint("Graph Error: $e");
    setState(() => isGraphLoading = false);
  }
}

  /// ✅ FIXED FETCH FUNCTION (NO ERRORS)
  Future<void> fetchDashboardData() async {
  final supabase = Supabase.instance.client;

  try {
    final usersRes = await supabase
        .from('profiles')
        .select('user_id');

    final communitiesRes = await supabase
        .from('communities')
        .select('id');

    final disputesRes = await supabase
        .from('complaints')
        .select('id');

 
final sales = await supabase
    .from('transactions')
    .select('id');
    totalSales = sales.length;

    setState(() {
      totalUsers = usersRes.length;
      totalCommunities = communitiesRes.length;
      totalDisputes = disputesRes.length;
      totalSales = sales.length;
      isLoading = false;

    });
  } catch (e) {
    debugPrint("Dashboard Error: $e");
    setState(() => isLoading = false);
  }
}





  @override
void initState() {
  super.initState();

   user = supabase.auth.currentUser;

  supabase.auth.onAuthStateChange.listen((data) {
    setState(() {
      user = data.session?.user;
    });
  });
  fetchDashboardData();
  fetchCommunityGrowth();
  fetchPieChartData();
  //fetchMonthlyTransactions();
  fetchMonthlyCompletionPercentage();
  //loadProfileImage();// 👈 ADD THIS
}




  final List<String> menuItems = [
    "Dashboard",
    "User Management",
    "Community Management",
    "Product & Resources",
    "Dispute Resolution",
    "Notifications",
    "Community Elections",
    "System Settings",
  ];

  final List<IconData> menuIcons = [
    Icons.dashboard_outlined,
    Icons.people_outline,
    Icons.group_outlined,
    Icons.inventory_2_outlined,
    Icons.report_gmailerrorred_outlined,
    Icons.notifications_outlined,
    Icons.how_to_vote_outlined,
    Icons.settings_outlined,
  ];

  

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _profileImage = bytes;
      });
    }
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Admin Profile",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? MemoryImage(_profileImage!)
                      : const AssetImage('assets/profile.png')
                          as ImageProvider,
                ),
                const SizedBox(height: 15),
                const Text(
                  "Click below to update your profile image",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _pickImage();
                      },
                      child: const Text("Change Image"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      body: Column(
        children: [
          Container(
            height: 70,
            decoration: const BoxDecoration(gradient: appGradient),
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Trade & Aid",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate: CustomSearchDelegate(
                            onItemSelected: (index) {
                              setState(() => selectedIndex = index);
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 25),
                    IconButton(
                      icon: const Icon(Icons.notifications_none,
                          color: Colors.white),
                      onPressed: () {
                        setState(() => selectedIndex = 5);
                      },
                    ),
                    const SizedBox(width: 25),
                    GestureDetector(
                      onTap: _showProfileDialog,
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage: imageUrl != null
    ? NetworkImage(imageUrl!)
    : const AssetImage('assets/profile.png') as ImageProvider,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Row(
              children: [
                /// SIDEBAR (UNCHANGED)
                Container(
                  width: 260,
                  decoration: const BoxDecoration(gradient: appGradient),
                  padding: const EdgeInsets.fromLTRB(24, 30, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Admin Portal",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
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
                                            ? Colors.white
                                                .withValues(alpha: 0.12)
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(menuIcons[index],
                                          color: Colors.white, size: 18),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(menuItems[index],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            )),
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
                      const CommunityElectionHistoryScreen(),
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
    
   padding: const EdgeInsets.fromLTRB(40, 30, 0, 20),
    child: SingleChildScrollView(
     padding: const EdgeInsets.only(right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text("Dashboard",
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),

          const SizedBox(height: 6),

          const Text("Welcome back, Admin 👋",
              style: TextStyle(fontSize: 18, color: Colors.black54)),

          const SizedBox(height: 30),

          Wrap(
            spacing: 10,
            runSpacing: 20,
            children: [
              _InfoCard("Total Users", isLoading ? "..." : totalUsers.toString()),
              _InfoCard("Communities", isLoading ? "..." : totalCommunities.toString()),
              _InfoCard("Disputes", isLoading ? "..." : totalDisputes.toString()),
              _InfoCard("Sales", isLoading ? "..." : totalSales.toString()),


              
            ],
          ),

          const SizedBox(height: 40),

          /// =====================
          /// LINE CHART (UNCHANGED)
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
maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
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
  sideTitles: SideTitles(
    showTitles: true,
    reservedSize: 40,
    interval: 20,
    getTitlesWidget: (value, meta) {
      return Text('${value.toInt()}%');
    },
  ),
),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: false,
                    color: const Color(0xFF119E90),
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    spots: isGraphLoading
                        ? [FlSpot(0, 0)]
                        : communityGrowthSpots,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          /// =====================
          /// PIE + BAR (ONLY PIE MODIFIED)
          /// =====================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// PIE CHART
              Expanded(
                child: Container(
                  height: 360,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(right: 10),
                  decoration: _cardDecoration(),

                  /// 🔥 UPDATED PIE SECTION
                  child: Column(
                    children: [
                      /// 🔥 TITLE
    const Text(
      "System Distribution Summary",
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),

    const SizedBox(height: 15),
    
                      Expanded(
                        
                        child: PieChart(
                          PieChartData(
                            centerSpaceRadius: 50,
                            sectionsSpace: 4,

                            sections: isPieLoading
                                ? [
                                    PieChartSectionData(
                                        value: 1, title: "Loading"),
                                  ]
                                : [
                                    PieChartSectionData(
                                      value: totalProducts == 0
                                          ? 0.1
                                          : totalProducts.toDouble(),
                                      title: "Products",
                                      color: const Color.fromARGB(
                                          255, 23, 207, 231),
                                      radius: 80,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      value: totalResources == 0
                                          ? 0.1
                                          : totalResources.toDouble(),
                                      title: "Resources",
                                      color: Colors.orange,
                                      radius: 80, // 👈 FIXED
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      value: totalDisputes == 0
                                          ? 0.1
                                          : totalDisputes.toDouble(),
                                      title: "Disputes",
                                      color: Colors.red,
                                      radius: 80,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// ✅ LEGEND
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _legendItem(Colors.red, "Disputes"),
                          const SizedBox(width: 20),
                          _legendItem(Colors.orange, "Resources"),
                          const SizedBox(width: 20),
                          _legendItem(
                              const Color.fromARGB(255, 23, 207, 231),
                              "Products"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              /// BAR CHART (UNCHANGED)
              Expanded(
  child: Container(
    height: 360,
    padding: const EdgeInsets.all(20),
    margin: const EdgeInsets.only(left: 10),
    decoration: _cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // 👇 TITLE HERE
       Center(
  child: const Text(
    "Monthly Transaction Percentage",
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
),

        const SizedBox(height: 10),

        // 👇 CHART
        Expanded(
          child: BarChart(
            BarChartData(
              maxY: 100,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: true),

              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const months = [
                        "Jan","Feb","Mar","Apr","May","Jun",
                        "Jul","Aug","Sep","Oct","Nov","Dec"
                      ];
                      int i = value.toInt();
                      if (i >= 0 && i < 12) {
                        return Text(months[i]);
                      }
                      return const Text("");
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    interval: 20,
                    getTitlesWidget: (value, meta) {
                      return Text("${value.toInt()}%");
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),

              barGroups: List.generate(12, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: isBarLoading ? 0 : monthlyPercentages[index],
                      color: const Color(0xFF119E90),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    ),
  ),
)
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

class CustomSearchDelegate extends SearchDelegate {

  final Function(int) onItemSelected;

  CustomSearchDelegate({required this.onItemSelected});

  final List<Map<String, dynamic>> data = [
    {"title": "Users", "index": 1},
    {"title": "Communities", "index": 2},
    {"title": "Products", "index": 3},
    {"title": "Disputes", "index": 4},
    {"title": "Notifications", "index": 5},
    {"title": "Elections", "index": 6},
    {"title": "Settings", "index": 7},
  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = "",
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = data.where((item) =>
        item["title"].toLowerCase().contains(query.toLowerCase())).toList();

    return ListView(
      children: results.map((item) {
        return ListTile(
          title: Text(item["title"]),
          onTap: () {
            close(context, null);

            // ✅ CALL BACK TO DASHBOARD
            onItemSelected(item["index"]);
          },
        );
      }).toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
Widget _legendItem(Color color, String text) {
  return Row(
    children: [
      Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(fontSize: 12)),
    ],
  );
}