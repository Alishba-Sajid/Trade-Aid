import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int selectedIndex = 0; // 0=Bought, 1=Sold, 2=Taken, 3=Given

  // ---------------- MOCK DATA ----------------
  final List<_HistoryItem> boughtItems = [
    _HistoryItem(
      title: "Leather Jacket",
      subtitle: "Bought for Rs 5000",
      icon: Icons.shopping_bag,
    ),
    _HistoryItem(
      title: "Shoes",
      subtitle: "Bought for Rs 2000",
      icon: Icons.shopping_bag,
    ),
  ];

  final List<_HistoryItem> soldItems = [
    _HistoryItem(
      title: "Ceramic Vase",
      subtitle: "Sold for Rs 1200",
      icon: Icons.sell,
    ),
  ];

  final List<_HistoryItem> resourcesTaken = [
    _HistoryItem(
      title: "Spacious Lawn",
      subtitle: "Booked for Rs 2000 / hour",
      icon: Icons.event_available,
    ),
  ];

  final List<_HistoryItem> resourcesGiven = [
    _HistoryItem(
      title: "Washing Machine",
      subtitle: "Provided at Rs 300 / hour",
      icon: Icons.handshake,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // ---------------- HEADER ----------------
          Container(
            width: double.infinity,
            height: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 15, 119, 124),
              Color.fromARGB(255, 17, 158, 144),],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 60,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                Positioned.fill(
                  top: 60,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: const Text(
                      "History",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Icon(Icons.history, color: Colors.white, size: 100),
                ),
              ],
            ),
          ),

          // ---------------- CONTENT ----------------
          Expanded(
            child: Column(
              children: [
                // ----------- TABS -----------
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      _tabButton("Products Bought", 0),
                      _tabButton("Products Sold", 1),
                      _tabButton("Resources Availed", 2),
                      _tabButton("Resources Provided", 3),
                    ],
                  ),
                ),

                // ----------- LIST AREA -----------
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSelectedSection(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- TAB BUTTON ----------------
  Widget _tabButton(String text, int index) {
    final bool isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF009688) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF009688)),
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF009688),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- SELECTED SECTION ----------------
  Widget _buildSelectedSection() {
    switch (selectedIndex) {
      case 0:
        return _buildSection("Products Bought", boughtItems);
      case 1:
        return _buildSection("Products Sold", soldItems);
      case 2:
        return _buildSection("Resources Availed", resourcesTaken);
      case 3:
        return _buildSection("Resources Provided", resourcesGiven);
      default:
        return _buildSection("Products Bought", boughtItems);
    }
  }

  // ---------------- SECTION BUILDER ----------------
  Widget _buildSection(String title, List<_HistoryItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6),
              ],
            ),
            child: const Center(
              child: Text("No items yet", style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          Column(
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _HistoryCard(item: item),
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ---------------- CARD WIDGET ----------------
class _HistoryCard extends StatelessWidget {
  final _HistoryItem item;
  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.teal.withOpacity(0.1),
            child: Icon(item.icon, color: Colors.teal),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- MODEL ----------------
class _HistoryItem {
  final String title;
  final String subtitle;
  final IconData icon;
  _HistoryItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
