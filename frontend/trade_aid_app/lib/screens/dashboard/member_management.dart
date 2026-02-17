// member_management_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/widgets/app_bar.dart';
import '/models/member_managemnt.dart';   

// 🌿 Shared Premium Industrial Palette

const Color kDark = Color(0xFF0B2F2A);
const Color kLight = Color(0xFFF4FAF9);
const Color kAccent = Color(0xFF119E90);
const Color kSurface = Color(0xFFFFFFFF);
const Color kDarkPrimary = Color(0xFF004D40);
const Color kBackgroundLight = Color(0xFFF8FAFA);
const Color kSubtleGrey = Color(0xFFF2F2F2);
const Color kTextSecondary = Color(0xFF5A716E);

class MemberManagementScreen extends StatefulWidget {
  const MemberManagementScreen({super.key});

  @override
  State<MemberManagementScreen> createState() => _MemberManagementScreenState();
}

class _MemberManagementScreenState extends State<MemberManagementScreen> {
  // Backend-ready: List<Member>
  List<Member> members = [
    Member(
      name: "Alice Johnson",
      location: "Cityville, USA",
      email: "alice@example.com",
      phone: "+1 234 567 890",
      ratingSeller: 4.5,
      ratingBuyer: 4.0,
      image: "https://i.pravatar.cc/150?u=alice",
      status: "Active",
    ),
    Member(
      name: "Bob Smith",
      location: "Townsville, USA",
      email: "bob@example.com",
      phone: "+1 987 654 321",
      ratingSeller: 3.8,
      ratingBuyer: 4.2,
      image: "https://i.pravatar.cc/150?u=bob",
      status: "Away",
    ),
    Member(
      name: "Carol White",
      location: "Villagecity, USA",
      email: "carol@example.com",
      phone: "+1 555 666 777",
      ratingSeller: 5.0,
      ratingBuyer: 4.8,
      image: "https://i.pravatar.cc/150?u=carol",
      status: "Active",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBarWidget(
        title: "Community Members",
        onBack: () => Navigator.pop(context),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kLight, kSurface],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          itemCount: members.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) => _buildMemberCard(members[index], index),
        ),
      ),
    );
  }

  Widget _buildMemberCard(Member member, int index) {
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
                      _buildAvatar(member.image, member.status),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: kDark,
                              ),
                            ),
                            Text(
                              member.email,
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
                      )
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, color: kSubtleGrey),
                  ),
                  _buildInfoRow(Icons.location_on_outlined, member.location),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.phone_outlined, member.phone),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildRatingTag("Seller", member.ratingSeller),
                      const SizedBox(width: 10),
                      _buildRatingTag("Buyer", member.ratingBuyer),
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
            backgroundImage: NetworkImage(url),
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
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10, color: kTextSecondary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  rating.toString(),
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, fontWeight: FontWeight.w700, color: kDarkPrimary),
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
              decoration: BoxDecoration(color: kSubtleGrey, borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 24),
            Text("Member Actions",
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 18, fontWeight: FontWeight.w800, color: kDark)),
            const SizedBox(height: 24),
            _buildActionTile(Icons.delete_outline_rounded, "Remove Member", Colors.redAccent, () {
              setState(() => members.removeAt(index));
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: color)),
      onTap: onTap,
    );
  }
}
