// member_management_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/widgets/app_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 🌿 Shared Premium Industrial Palette
const Color kDark = Color(0xFF0B2F2A);
const Color kLight = Color(0xFFF4FAF9);
const Color kAccent = Color(0xFF119E90);
const Color kSurface = Color(0xFFFFFFFF);
const Color kDarkPrimary = Color(0xFF004D40);
const Color kBackgroundLight = Color(0xFFF8FAFA);
const Color kSubtleGrey = Color(0xFFF2F2F2);
const Color kTextSecondary = Color(0xFF5A716E);

// Gradient used for avatar border
const LinearGradient appGradient = LinearGradient(
  colors: [Color(0xFF119E90), Color(0xFF004D40)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class MemberManagementScreen extends StatefulWidget {
  final String communityId;

  const MemberManagementScreen({super.key, required this.communityId});

  @override
  State<MemberManagementScreen> createState() => _MemberManagementScreenState();
}

class _MemberManagementScreenState extends State<MemberManagementScreen> {
  List members = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    final supabase = Supabase.instance.client;

    try {
      final data = await supabase
          .from('community_members')
          .select('''
            role,
            profiles(full_name, phone, address, profile_image_url)
          ''')
          .eq('community_id', widget.communityId);

      setState(() {
        members = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching members: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBarWidget(
        title: "Community Members",
        onBack: () => Navigator.pop(context),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : members.isEmpty
          ? const Center(child: Text("No members found"))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: members.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) =>
                  _buildMemberCard(members[index], index),
            ),
    );
  }

  Widget _buildMemberCard(dynamic member, int index) {
    final profile = member['profiles'] ?? {};
    final String status = "Active"; // You can customize if you track status

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: kDark.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: kAccent.withOpacity(0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildAvatar(profile['profile_image_url'] ?? '', status),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile['full_name'] ?? 'Unknown',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: kDark,
                              ),
                            ),
                            Text(
                              member['role'] ?? '-',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: kTextSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showActionMenu(index),
                        icon: const Icon(Icons.more_horiz, color: kAccent),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, color: kSubtleGrey),
                  ),
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    profile['address'] ?? '-',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.phone_outlined, profile['phone'] ?? '-'),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildRatingTag("Seller", 4.0), // Placeholder rating
                      const SizedBox(width: 10),
                      _buildRatingTag("Buyer", 4.5), // Placeholder rating
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String url, String status) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: appGradient,
          ),
          child: CircleAvatar(
            radius: 32,
            backgroundColor: kSurface,
            backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
            child: url.isEmpty
                ? Text(
                    "N/A",
                    style: GoogleFonts.plusJakartaSans(
                      color: kTextSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ),
        Positioned(
          right: 2,
          bottom: 2,
          child: Container(
            height: 16,
            width: 16,
            decoration: BoxDecoration(
              color: status == "Active" ? kAccent : Colors.orangeAccent,
              shape: BoxShape.circle,
              border: Border.all(color: kSurface, width: 3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: kAccent),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: kDark.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingTag(String label, double rating) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: kLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: kTextSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  rating.toString(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kDarkPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showActionMenu(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kSubtleGrey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Member Actions",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: kDark,
              ),
            ),
            const SizedBox(height: 24),
            _buildActionTile(
              Icons.security_rounded,
              "Make Moderator",
              Colors.green,
              () async {
                await _makeModerator(index);
                Navigator.pop(context);
              },
            ),
            _buildActionTile(
              Icons.delete_outline_rounded,
              "Remove Member",
              Colors.redAccent,
              () {
                setState(() => members.removeAt(index));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makeModerator(int index) async {
    final supabase = Supabase.instance.client;
    final member = members[index];
    final userId =
        member['profiles']['user_id']; // Make sure your select includes user_id

    try {
      await supabase
          .from('community_members')
          .update({'role': 'moderator'})
          .eq('community_id', widget.communityId)
          .eq('user_id', userId);

      // Update local state
      setState(() {
        members[index]['role'] = 'moderator';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Member promoted to moderator")),
      );
    } catch (e) {
      debugPrint("Error making moderator: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to promote member")));
    }
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      onTap: onTap,
    );
  }
}
