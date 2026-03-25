import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '/models/member_profile.dart';
import '/services/member_profile.dart';

/* ===================== GRADIENT ===================== */
const LinearGradient appGradient = LinearGradient(
  colors: [Color(0xFF2E9499), Color(0xFF119E90)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/* ===================== MEMBER PROFILE SCREEN ===================== */
class MemberProfileScreen extends StatefulWidget {
  final String userId;

  const MemberProfileScreen({super.key, required this.userId});

  @override
  State<MemberProfileScreen> createState() =>
      _MemberProfileScreenState();
}
class _MemberProfileScreenState extends State<MemberProfileScreen> {
  final MemberProfileService _service = MemberProfileService();
  late Future<MemberProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _service.fetchMemberProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: light,
      body: FutureBuilder<MemberProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = snapshot.data!;

          return Column(
            children: [
              _buildPremiumHeader(context, profile),
              const SizedBox(height: 20),

              // 🔹 Quick Actions Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: "Message",
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              _buildInfoSection(profile),
            ],
          );
        },
      ),
    );
  }

  /* ====================== HEADER ====================== */
  Widget _buildPremiumHeader(BuildContext context, MemberProfile profile) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 210,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: appGradient,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  const SizedBox(height: 5),

                  // 🔹 BACK BUTTON + TITLE ROW
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      const Text(
                        "Member Profile",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48), // keeps symmetry
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          top: 120,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(profile.avatarUrl),
                ),
              ),
              const SizedBox(height: 13),
              Text(
                profile.name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D1D1D),
                ),
              ),
              Text(
                profile.address,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),

              // ⭐ NEW RATING ROW (Buyer & Seller)
              _buildRatingRow(profile.buyerRating, profile.sellerRating),
            ],
          ),
        ),

        const SizedBox(height: 374),
      ],
    );
  }

  Widget _buildRatingRow(double buyerRating, double sellerRating) {
    return Column(
      children: [
        // Buyer
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Buyer: ",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Row(
              children: List.generate(5, (index) {
                if (buyerRating >= index + 1)
                  return const Icon(Icons.star, color: Colors.amber, size: 18);
                if (buyerRating > index && buyerRating < index + 1)
                  return const Icon(
                    Icons.star_half,
                    color: Colors.amber,
                    size: 18,
                  );
                return const Icon(
                  Icons.star_outline,
                  color: Colors.amber,
                  size: 18,
                );
              }),
            ),
            const SizedBox(width: 6),
            Text(
              "$buyerRating/5",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Seller
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Seller: ",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Row(
              children: List.generate(5, (index) {
                if (sellerRating >= index + 1)
                  return const Icon(Icons.star, color: Colors.amber, size: 18);
                if (sellerRating > index && sellerRating < index + 1)
                  return const Icon(
                    Icons.star_half,
                    color: Colors.amber,
                    size: 18,
                  );
                return const Icon(
                  Icons.star_outline,
                  color: Colors.amber,
                  size: 18,
                );
              }),
            ),
            const SizedBox(width: 6),
            Text(
              "$sellerRating/5",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),

        const SizedBox(height: 50),
      ],
    );
  }

  /* ====================== INFO SECTION ====================== */
  Widget _buildInfoSection(MemberProfile profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _infoTile(Icons.phone_iphone_rounded, "Phone", profile.phone),
          const Divider(indent: 60, height: 1, color: Color(0xFFF1F1F1)),
          _infoTile(Icons.calendar_today_rounded, "Joined", profile.joinedDate),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: accent, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}

/* ===================== ACTION BUTTON ===================== */
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              gradient: appGradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
