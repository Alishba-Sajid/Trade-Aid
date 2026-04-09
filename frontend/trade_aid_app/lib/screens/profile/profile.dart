import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/profile_service.dart';

// Consistent Gradient used across the app
const LinearGradient appGradient = LinearGradient(
  colors: [
    Color.fromARGB(255, 15, 119, 124),
    Color.fromARGB(255, 17, 158, 144),
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

// ✅ Reusable Animated Card Widget (Same UI as Personal Details)
class AnimatedCard extends StatefulWidget {
  final String message;
  final IconData? icon;
  const AnimatedCard({super.key, required this.message, this.icon});

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _offsetAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color.fromARGB(255, 17, 158, 144),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null)
                  Icon(
                    widget.icon,
                    color: const Color.fromARGB(255, 17, 158, 144),
                  ),
                if (widget.icon != null) const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  bool _notificationsEnabled = true;

  late AnimationController _starController;
  late Animation<double> _starAnimation;

  // Dynamic ratings
  double buyerRating = 4.5;
  double sellerRating = 3.5;
  String? userName;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _starAnimation = CurvedAnimation(
      parent: _starController,
      curve: Curves.easeOutBack,
    );

    _starController.forward();
    _fetchUserName();
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  // ✅ Function to show the animated card
  void _showAnimatedCard(String message, {IconData? icon}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        left: 20,
        right: 20,
        child: AnimatedCard(message: message, icon: icon),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }

  Future<void> _fetchUserName() async {
    final data = await ProfileService().getProfile();

    setState(() {
      userName = data?['full_name'];
      profileImageUrl = data?['profile_image_url'];
      _notificationsEnabled = data?['notifications_enabled'] ?? true;
    });
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF009688)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing:
            trailing ??
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _dualRatings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Buyer: ",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            ScaleTransition(
              scale: _starAnimation,
              child: Row(
                children: List.generate(5, (index) {
                  if (buyerRating >= index + 1) {
                    return const Icon(Icons.star, color: Colors.amber, size: 16);
                  } else if (buyerRating > index && buyerRating < index + 1) {
                    return const Icon(Icons.star_half, color: Colors.amber, size: 16);
                  } else {
                    return const Icon(Icons.star_outline, color: Colors.amber, size: 16);
                  }
                }),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "$buyerRating",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Text(
              "Seller: ",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            ScaleTransition(
              scale: _starAnimation,
              child: Row(
                children: List.generate(5, (index) {
                  if (sellerRating >= index + 1) {
                    return const Icon(Icons.star, color: Colors.amber, size: 16);
                  } else if (sellerRating > index && sellerRating < index + 1) {
                    return const Icon(Icons.star_half, color: Colors.amber, size: 16);
                  } else {
                    return const Icon(Icons.star_outline, color: Colors.amber, size: 16);
                  }
                }),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "$sellerRating",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showChangeLocationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color.fromARGB(255, 15, 119, 124),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on_rounded, color: Colors.teal, size: 32),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Change Location",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                const Text(
                  "If your new location is more than 2 km away from your previous location, access to your previous communities may be denied.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: Colors.teal, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: ShaderMask(
                          shaderCallback: (bounds) => appGradient.createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: appGradient,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context,
                              '/location_permission',
                              arguments: {'fromChangeLocation': true},
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text(
                            "Yes",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
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
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          Container(
            height: 260,
            decoration: const BoxDecoration(
              gradient: appGradient,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    "Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: const Color(0xFF009688),
                          backgroundImage:
                              profileImageUrl != null &&
                                      profileImageUrl!.isNotEmpty
                                  ? NetworkImage(profileImageUrl!)
                                  : null,
                          child:
                              (profileImageUrl == null ||
                                      profileImageUrl!.isEmpty)
                                  ? const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.white,
                                    )
                                  : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName ?? "User",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _dualRatings(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 53),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _menuTile(
                          context,
                          icon: Icons.person,
                          title: "Personal Details",
                          onTap: () =>
                              Navigator.pushNamed(context, "/personal_details"),
                        ),
                        _menuTile(
                          context,
                          icon: Icons.lock,
                          title: "Change Password",
                          onTap: () =>
                              Navigator.pushNamed(context, "/change_password"),
                        ),
                        _menuTile(
                          context,
                          icon: Icons.notifications,
                          title: "Notifications",
                          trailing: Switch(
                            value: _notificationsEnabled,
                            activeColor: const Color(0xFF009688),
                            onChanged: (val) async {
                              setState(() {
                                _notificationsEnabled = val;
                              });

                              final user =
                                  Supabase.instance.client.auth.currentUser;
                              if (user != null) {
                                await Supabase.instance.client
                                    .from('profiles')
                                    .update({'notifications_enabled': val})
                                    .eq('user_id', user.id);
                              }

                              // ✅ Replaced SnackBar with Animated Card
                              _showAnimatedCard(
                                val ? 'Notifications Enabled' : 'Notifications Disabled',
                                icon: val ? Icons.notifications_active : Icons.notifications_off,
                              );
                            },
                          ),
                        ),
                        _menuTile(
                          context,
                          icon: Icons.history,
                          title: "History",
                          onTap: () => Navigator.pushNamed(context, "/history"),
                        ),
                        _menuTile(
                          context,
                          icon: Icons.location_on,
                          title: "Change Location",
                          onTap: _showChangeLocationDialog,
                        ),
                        _menuTile(
                          context,
                          icon: Icons.description_outlined,
                          title: "Terms & Conditions",
                          onTap: () =>
                              Navigator.pushNamed(context, "/terms_conditions"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}