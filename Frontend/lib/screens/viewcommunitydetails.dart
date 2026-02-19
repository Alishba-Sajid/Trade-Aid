import 'package:flutter/material.dart';

/// 🔹 INDUSTRIAL THEME COLORS
const LinearGradient appGradient = LinearGradient(
  colors: [
    Color(0xFF0F777C),
    Color(0xFF119E90),
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

const Color dark = Color(0xFF0B2F2A);
const Color darkPrimary = Color(0xFF004D40);
const Color backgroundLight = Color(0xFFF4FAF9);
const Color surface = Colors.white;
const Color subtleGrey = Color(0xFFF1F1F1);
const Color accent = Color(0xFF119E90);

class CommunityDetails extends StatefulWidget {
  const CommunityDetails({super.key});

  @override
  State<CommunityDetails> createState() => _CommunityDetailsState();
}

class _CommunityDetailsState extends State<CommunityDetails> {
  int selectedTab = 0;
  final tabs = ["Overview", "Members", "Sales Items", "Activity Log"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: Column(
        children: [
          // 🔹 HEADER
          Container(
            height: 70,
            decoration: const BoxDecoration(gradient: appGradient),
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Trade&Aid — Admin Panel",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: const [
                    Icon(Icons.search, color: Colors.white),
                    SizedBox(width: 20),
                    Icon(Icons.notifications_none_outlined,
                        color: Colors.white),
                    SizedBox(width: 16),
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage('assets/profile.png'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🔹 BODY
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(60, 40, 60, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Community Details",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: dark,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 🔹 COMMUNITY CARD
                  _card(
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              AssetImage('assets/community.png'),
                        ),
                        const SizedBox(width: 30),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Green Valley Community",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: darkPrimary,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Created on Jan 15, 2023",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🔹 TABS
                  Row(
                    children: List.generate(tabs.length, (index) {
                      final active = selectedTab == index;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => selectedTab = index),
                        child: Container(
                          margin: const EdgeInsets.only(right: 30),
                          padding: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color:
                                    active ? accent : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Text(
                            tabs[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: active
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color:
                                  active ? accent : Colors.black54,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 40),

                  // 🔹 STATS
                  sectionTitle("Community Statistics"),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      _StatCard("Total Members", "1,250"),
                      _StatCard("Sales Items", "500"),
                      _StatCard("Beneficiaries", "150"),
                    ],
                  ),

                  const SizedBox(height: 50),

                  // 🔹 TABLE
                  sectionTitle("Beneficiary Information"),
                  const SizedBox(height: 16),
                  _beneficiaryTable(),

                  const SizedBox(height: 50),

                  // 🔹 ACTIONS
                  sectionTitle("Community Actions"),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit),
                        label: const Text("Edit Community"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 26, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon:
                            const Icon(Icons.pause_circle_outline),
                        label: const Text("Suspend Community"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: darkPrimary,
                          side:
                              const BorderSide(color: darkPrimary),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 26, vertical: 16),
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
    );
  }

  // 🔹 HELPERS
  static Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: dark,
      ),
    );
  }

  static Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _beneficiaryTable() {
    final data = [
      ["Michael GreenFi", "michaelgf@example.com", "Admin", "Active"],
      ["Sarah Lopez", "sarahlp@example.com", "Member", "Active"],
      ["Sanjay Rai", "sanjayr@example.com", "Member", "Active"],
    ];

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Table(
        border:
            TableBorder.symmetric(inside: BorderSide(color: subtleGrey)),
        children: [
          const TableRow(
            decoration: BoxDecoration(color: subtleGrey),
            children: [
              _Cell("Name", header: true),
              _Cell("Email", header: true),
              _Cell("Role", header: true),
              _Cell("Status", header: true),
            ],
          ),
          for (var row in data)
            TableRow(
              children:
                  row.map((e) => _Cell(e)).toList(),
            ),
        ],
      ),
    );
  }
}

// 🔹 SMALL COMPONENTS
class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final bool header;

  const _Cell(this.text, {this.header = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: header ? FontWeight.bold : FontWeight.normal,
          color: header ? dark : Colors.black87,
        ),
      ),
    );
  }
}
