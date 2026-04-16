import 'package:flutter/material.dart';
import '../../services/chat_service.dart';
import '../../models/profile_model.dart';
import 'chat_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 🌿 Premium Color Constants
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
  @override
void initState() {
  super.initState();
  _listenToConversationChanges();
}
void _listenToConversationChanges() {
  Supabase.instance.client
      .from('conversations')
      .stream(primaryKey: ['id'])
      .listen((event) {
    setState(() {
      // 🔥 triggers UI refresh
    });
  });
}
  final ChatService _chatService = ChatService();

  String selectedCategory = "Recent Chats";
  String searchQuery = "";

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
            child: selectedCategory == "Recent Chats"
                ? _buildRecentChats()
                : _buildCommunityMembers(),
          ),
        ],
      ),
    );
  }

  /// ====================== Premium AppBar ======================
  Widget _buildPremiumAppBar(BuildContext context) {
    return Container(
      height: 100,
      decoration: const BoxDecoration(gradient: appGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
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

  /// ====================== Search Bar ======================
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: (v) {
          setState(() {
            searchQuery = v;
          });
        },
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

  /// ====================== Category Selector ======================
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
          ),
        ],
      ),
      child: Row(
        children: [
          _buildCategoryButton("Recent Chats"),
          const SizedBox(width: 4),
          _buildCategoryButton("Community Members"),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String category) {
    final bool isSelected = selectedCategory == category;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = category;
          });
        },
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
                color: isSelected ? Colors.white : dark.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ====================== Recent Chats ======================
  Widget _buildRecentChats() {
   return StreamBuilder<List<Map<String, dynamic>>>(
  stream: _chatService.getRecentChatsStream(),
      builder: (context, snapshot) {

      if (snapshot.connectionState == ConnectionState.waiting) {
  return const Center(child: CircularProgressIndicator());
}

if (!snapshot.hasData || snapshot.data!.isEmpty) {
  return _buildEmptyState();
}

        final chats = snapshot.data!;

       final myId = Supabase.instance.client.auth.currentUser!.id;

final filteredChats = chats.where((chat) {

  // ❌ skip chats with no messages
  if (chat['last_message_at'] == null) return false;

  final isUser1 = chat['user1_id'] == myId;
  final profile = isUser1 ? chat['user2'] : chat['user1'];

  final name = profile['full_name'] ?? "";

  return name.toLowerCase().contains(searchQuery.toLowerCase());

}).toList();
        if (filteredChats.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          itemCount: filteredChats.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            indent: 80,
            endIndent: 20,
            color: Color(0xFFE0E0E0),
          ),
          itemBuilder: (context, index) {

            final chat = filteredChats[index];
            final myId = Supabase.instance.client.auth.currentUser!.id;
            final isUser1 = chat['user1_id'] == myId;
            final profile = isUser1 ? chat['user2'] : chat['user1'];

       return Stack(
  children: [

    ListTile(leading: CircleAvatar(
  radius: 26,
  backgroundColor: accent.withOpacity(0.15),

  backgroundImage: (profile['profile_image_url'] != null &&
          profile['profile_image_url'].toString().isNotEmpty)
      ? NetworkImage(profile['profile_image_url'])
      : null,

  child: (profile['profile_image_url'] == null ||
          profile['profile_image_url'].toString().isEmpty)
      ? const Icon(Icons.person, color: Colors.grey)
      : null,
),

      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(profile['full_name'] ?? "User"),

          if (profile['address'] != null)
            Text(
              profile['address'],
              style: const TextStyle(
                fontSize: 12,
                color: mutedText,
              ),
            ),
        ],
      ),

      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              sellerName: profile['full_name'] ?? "User",
              receiverId: isUser1
                  ? chat['user2_id']
                  : chat['user1_id'],
              profileImage: profile['profile_image_url'],
              address: profile['address'],
            ),
          ),
        );
      },
    ),

    /// 🔴 Unread indicator
    if (chat['unread_count'] != null &&
        chat['unread_count'] > 0 &&
        chat['last_sender_id'] != myId)

      Positioned(
        right: 16,
        top: 22,
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
      ),

  ],
);
          },
        );
      },
    );
  }

  /// ====================== Community Members ======================
  Widget _buildCommunityMembers() {
    return FutureBuilder<List<ProfileModel>>(
      future: _chatService.getCommunityMembers(),
      builder: (context, snapshot) {

       if (snapshot.connectionState == ConnectionState.waiting) {
  return const Center(child: CircularProgressIndicator());
}

if (!snapshot.hasData || snapshot.data!.isEmpty) {
  return _buildEmptyState();
}

        final members = snapshot.data!;

        final filteredMembers = members.where((member) {
        return member.fullName
    .toLowerCase()
    .contains(searchQuery.trim().toLowerCase());
        }).toList();

        if (filteredMembers.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          itemCount: filteredMembers.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            indent: 80,
            endIndent: 20,
            color: Color(0xFFE0E0E0),
          ),
          itemBuilder: (context, index) {

            final member = filteredMembers[index];

            return ListTile(
            leading: CircleAvatar(
  radius: 26,
  backgroundColor: accent.withOpacity(0.15),

  backgroundImage: (member.imageUrl != null &&
          member.imageUrl!.isNotEmpty)
      ? NetworkImage(member.imageUrl!)
      : null,

  child: (member.imageUrl == null ||
          member.imageUrl!.isEmpty)
      ? const Icon(Icons.person, color: Colors.grey)
      : null,
),
             title: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      member.fullName,
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),
    if (member.address != null)
      Text(
        member.address!,
        style: const TextStyle(
          fontSize: 12,
          color: mutedText,
        ),
      ),
  ],
),
              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
  sellerName: member.fullName,
  receiverId: member.userId,
  profileImage: member.imageUrl,
  address: member.address,
),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// ====================== Empty State ======================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: mutedText.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text(
            "No results found for '$searchQuery'",
            style: TextStyle(color: mutedText.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}