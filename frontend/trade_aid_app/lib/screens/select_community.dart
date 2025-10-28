import 'package:flutter/material.dart';
import 'create_community.dart'; // Import your CreateCommunityScreen file

const Color kPrimaryTeal = Color(0xFF004D40);
const Color kLightTeal = Color(0xFF70B2B2);
const Color kSkyBlue = Color(0xFF9ECFD4);
const Color kPaleYellow = Color(0xFFE5E9C5);

class SelectCommunityScreen extends StatefulWidget {
  const SelectCommunityScreen({super.key});

  @override
  State<SelectCommunityScreen> createState() => _SelectCommunityScreenState();
}

class _SelectCommunityScreenState extends State<SelectCommunityScreen> {
  bool noCommunitiesNearby = true; // true if no nearby communities found

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ White background as you requested
      appBar: AppBar(
        title: const Text(
          "Select Community",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryTeal,
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: noCommunitiesNearby
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon with soft accent background
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: kSkyBlue.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_off,
                        size: 80,
                        color: kPrimaryTeal,
                      ),
                    ),
                    const SizedBox(height: 30),

                    const Text(
                      "No communities found near your location.",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),

                    const Text(
                      "You can create your own community and invite others to join!",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Create Community Button
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateCommunityScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_location_alt_rounded,
                          color: Colors.white),
                      label: const Text(
                        "Create Your Own Community",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryTeal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ],
                )
              : ListView(
                  children: const [
                    // Future: Show list of nearby communities
                  ],
                ),
        ),
      ),
    );
  }
}
