import 'package:flutter/material.dart';

class CommunityDetails extends StatefulWidget {
  const CommunityDetails({super.key}); // ✅ removed the undefined "User user"

  @override
  State<CommunityDetails> createState() => _CommunityDetailsState();
}

class _CommunityDetailsState extends State<CommunityDetails> {
  int selectedIndex = 0;
  int? hoveredIndex;

  final List<String> menuItems = [
    "Dashboard",
    "User Management",
    "Community Management",
    "Product & Resource sharing",
    "Dispute Resolution (Escalated Cases)",
    "Reports & Analytics",
    "System Settings",
  ];

  final List<IconData> menuIcons = [
  Icons.dashboard_outlined,               // Dashboard
  Icons.people_outline,                   // User Management
  Icons.group_outlined,                   // Community Management
  Icons.swap_horiz_outlined,              // ✅ Product & Resource Sharing
  Icons.report_problem_outlined,          // Dispute Resolution
  Icons.analytics_outlined,               // Reports & Analytics
  Icons.settings_outlined,                // System Settings
];

  int selectedTab = 0;
  final tabs = ["Overview", "Members", "Sales Items", "Activity Log"];

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
                      fontSize: 20,
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
                          color: Colors.black87, size: 30),
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

          // 🔹 Sidebar + Main Content
          Expanded(
            child: Row(
              children: [
                // Sidebar
                Container(
                  width: 270,
                  color: Colors.white10,
                  padding: const EdgeInsets.fromLTRB(50, 50, 16, 20),
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
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color.fromARGB(
                                            255, 204, 198, 198)
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

                // 🔹 Main Content Area (Community Details)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Community Details",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 50),

                        // Community Header
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey,
                              backgroundImage:
                                  AssetImage('assets/community.png'),
                            ),
                            const SizedBox(width: 22),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Green Valley Community",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Created on Jan 15, 2023",
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Tabs
                        Row(
                          children: List.generate(tabs.length, (index) {
                            final selected = index == selectedTab;
                            return GestureDetector(
                              onTap: () => setState(() => selectedTab = index),
                              child: Container(
                                margin: const EdgeInsets.only(right: 20),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: selected
                                          ? Colors.blueAccent
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  tabs[index],
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.blueAccent
                                        : Colors.black87,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          "Community Details",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text("View and manage community details."),
                        const SizedBox(height: 25),
                        const Text(
                          "Community Statistics",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        _buildStatsCards(),

                        const SizedBox(height: 60),
                        const Text(
                          "Beneficiary Information",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        _buildBeneficiaryTable(),
                        const SizedBox(height: 40),

                        // 🔹 Community Actions
                        const Text(
                          "Community Actions",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            // 🟢 Edit Community Button
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.edit, size: 20),
                              label: const Text(
                                "Edit Community",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 170, 171, 173),
                                foregroundColor:
                                    const Color.fromARGB(255, 7, 7, 7),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22, vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),

                            const SizedBox(width: 20),

                            // 🔴 Suspend Community Button
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.pause_circle_outline,
                                  size: 18),
                              label: const Text(
                                "Suspend Community",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 25, 115, 233),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22, vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
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
    );
  }

  // 📈 Stats Cards
  Widget _buildStatsCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: const [
        _StatCard(title: "Total Members", value: "1,250"),
        _StatCard(title: "Total Sales Items", value: "500"),
        _StatCard(title: "Total Beneficiaries", value: "150"),
      ],
    );
  }

  // 🧍 Beneficiary Table
  Widget _buildBeneficiaryTable() {
    final data = [
      {"name": "Michael GreenFi", "email": "michaelgf@example.com", "role": "Admin"},
      {"name": "Sarah Lopez", "email": "sarahlp@example.com", "role": "Member"},
      {"name": "Sanjay Rai", "email": "sanjayr@example.com", "role": "Member"},
    ];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(1),
        },
        border: TableBorder.symmetric(
          inside: BorderSide(color: Color.fromARGB(255, 250, 244, 244)),
        ),
        children: [
          _buildTableHeader(),
          for (var user in data) _buildTableRow(user),
        ],
      ),
    );
  }

  TableRow _buildTableHeader() {
    return const TableRow(
      decoration: BoxDecoration(color: Color.fromARGB(255, 204, 197, 197)),
      children: [
        _TableCell("Name", isHeader: true),
        _TableCell("Email", isHeader: true),
        _TableCell("Role", isHeader: true),
        _TableCell("Status", isHeader: true),
      ],
    );
  }

  TableRow _buildTableRow(Map<String, String> user) {
    return TableRow(
      decoration: const BoxDecoration(color: Colors.white),
      children: [
        _TableCell(user["name"]!),
        _TableCell(user["email"]!),
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 216, 214, 214),
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Center(
            child: Text(
              user["role"]!,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 216, 214, 214),
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: const Center(
            child: Text(
              "Active",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 480,
      height: 250,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;

  const _TableCell(this.text, {this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 18 : 16,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
          color: isHeader ? Colors.black : Colors.black87,
        ),
      ),
    );
  }
}
