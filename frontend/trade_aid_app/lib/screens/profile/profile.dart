import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _notificationsEnabled = true;

  late AnimationController _starController;
  late Animation<double> _starAnimation;

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
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
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
            trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _animatedStars() {
    return ScaleTransition(
      scale: _starAnimation,
      child: Row(
        children: const [
          Icon(Icons.star, color: Colors.amber, size: 18),
          Icon(Icons.star, color: Colors.amber, size: 18),
          Icon(Icons.star, color: Colors.amber, size: 18),
          Icon(Icons.star, color: Colors.amber, size: 18),
          Icon(Icons.star_half, color: Colors.amber, size: 18),
          SizedBox(width: 6),
          Text(
            "4.5",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeLocationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // user must choose an option
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon at top
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.teal,
                  size: 50,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                "Change Location",
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // Description
              const Text(
                "If your new location is more than 2 km away from your previous location, "
                "access to your previous communities may be denied.",
                style: TextStyle(color: Colors.black87, fontSize: 15),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 25),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  // Yes button
                  Expanded(
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
                        backgroundColor: const Color.fromARGB(255, 30, 149, 125),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Yes",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          // Header
          Container(
            height: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
               Color.fromARGB(255, 15, 119, 124),
              Color.fromARGB(255, 17, 158, 144),
                ],
              ),
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

                  // Profile Card
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
                        const CircleAvatar(
                          radius: 42,
                          backgroundColor: Color(0xFF009688),
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Alishba Sajid",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _animatedStars(),
                            const SizedBox(height: 4),
                            const Text(
                              "alishba@email.com",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 53),

                  // Menu Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _menuTile(
                          context,
                          icon: Icons.person,
                          title: "Personal Details",
                          onTap: () => Navigator.pushNamed(context, "/personal_details"),
                        ),
                        _menuTile(
                          context,
                          icon: Icons.lock,
                          title: "Change Password",
                          onTap: () => Navigator.pushNamed(context, "/change_password"),
                        ),
                        _menuTile(
                          context,
                          icon: Icons.notifications,
                          title: "Notifications",
                          trailing: Switch(
                            value: _notificationsEnabled,
                            activeColor: const Color(0xFF009688),
                            onChanged: (val) {
                              setState(() {
                                _notificationsEnabled = val;
                              });
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
                          icon: Icons.block,
                          title: "Blocked Users",
                          onTap: () => Navigator.pushNamed(context, "/blocked_users"),
                        ),                       
                        _menuTile(
                          context,
                          icon: Icons.description_outlined,
                          title: "Terms & Conditions",
                          onTap: () => Navigator.pushNamed(context, "/terms_conditions"),
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
