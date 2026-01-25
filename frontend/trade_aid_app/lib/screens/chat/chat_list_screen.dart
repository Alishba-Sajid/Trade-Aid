import 'package:flutter/material.dart';
import '../../widgets/chat_tile.dart';
import 'chat_screen.dart';

// 🌿 Premium Color Constants
const LinearGradient appGradient = LinearGradient(
  colors: [Color(0xFF2E9499), Color(0xFF119E90)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const Color dark = Color(0xFF004D40);
const Color light = Color(0xFFF8FBFB);
const Color accent = Color(0xFF119E90);
const Color mutedText = Color(0xFF757575);

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String selectedCategory = 'Recent Chats';
  String searchQuery = '';

  // 🔹 BACKEND-READY MOCK DATA
  // Replace later with API / Firebase / Supabase
  final List<String> recentChats = [
    "Alex Johnson",
    "Ahmed Khan",
    "Sarah Williams",
    "Tech Support Group",
    "Design Team",
  ];

  final List<String> communityMembers = [
    "Dr. Emily Stone",
    "Ahmad Raza",
    "Mark Rifalo",
    "Sophie Turner",
    "Jessica Alba",
  ];

  @override
  Widget build(BuildContext context) {
    final currentList =
        selectedCategory == 'Recent Chats' ? recentChats : communityMembers;

    final filteredList = currentList.where((name) {
      return name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: light,
      body: Column(
        children: [
          _buildPremiumAppBar(context),

          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 20),
                _buildCategorySelector(),
              ],
            ),
          ),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: filteredList.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      key: ValueKey(
                          '${selectedCategory}_${filteredList.length}'),
                      padding:
                          const EdgeInsets.only(top: 10, bottom: 20),
                      itemCount: filteredList.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        indent: 80,
                        endIndent: 20,
                        color: Color(0xFFE0E0E0),
                      ),
                      itemBuilder: (context, index) {
                        final sellerName = filteredList[index];

                        return ChatTile(
                          // UI unchanged
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ChatScreen(sellerName: sellerName),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ====================== AppBar ======================
  Widget _buildPremiumAppBar(BuildContext context) {
    return Container(
      height: 130,
      decoration: const BoxDecoration(gradient: appGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon:
                    const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Text(
                "Community Chat",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  // ====================== Search Bar ======================
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        onChanged: (v) => setState(() => searchQuery = v),
        style: const TextStyle(color: dark),
        decoration: InputDecoration(
          hintText: 'Search members...',
          prefixIcon: const Icon(Icons.search, color: accent),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ====================== Category Selector ======================
  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          _buildCategoryButton('Recent Chats'),
          const SizedBox(width: 4),
          _buildCategoryButton('Community Members'),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String category) {
    final bool isSelected = selectedCategory == category;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedCategory = category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? appGradient : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              category,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : dark.withOpacity(0.6),
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ====================== Empty State ======================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off,
              size: 48, color: mutedText.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text(
            "No results found for '$searchQuery'",
            style:
                TextStyle(color: mutedText.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}
