import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/app_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// COLORS
const Color darkPrimary = Color(0xFF004D40);
const Color accentTeal = Color(0xFF119E90);
const Color backgroundLight = Color(0xFFF0F9F8);

const LinearGradient appGradient = LinearGradient(
  colors: [Color(0xFF2E9499), Color(0xFF119E90)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class PostWishRequestScreen extends StatefulWidget {
  final String communityId;
  const PostWishRequestScreen({
    super.key,
    required this.communityId,
  });


@override
  State<PostWishRequestScreen> createState() => _PostWishRequestScreenState();
}

class _PostWishRequestScreenState extends State<PostWishRequestScreen> {
  bool isHighUrgency = false;

  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  /// CONFIRMATION DIALOG
  void _showConfirmDialog() {
    if (_itemController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the item name")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Center(
          child: Text(
            "Confirm Post",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: darkPrimary,
            ),
          ),
        ),
        content: Text(
          "Do you really want to post this wish to the community?",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: Colors.grey[700]),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        actions: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: appGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: ShaderMask(
                          shaderCallback: (bounds) =>
                              appGradient.createShader(bounds),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _handlePost();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentTeal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      "Yes, Post",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// MAIN POST FUNCTION
  Future<void> _handlePost() async {
    final itemName = _itemController.text.trim();
    final description = _descController.text.trim();
    final urgent = isHighUrgency;

    String? communityId;

    if (itemName.isEmpty) return;

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in")),
        );
        return;
      }

      final userId = user.id;

      /// FETCH COMMUNITY
      final member = await supabase
          .from('community_members')
          .select('community_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (member == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You are not in any community")),
        );
        return;
      }

      communityId = member['community_id'];
/// INSERT WISH REQUEST
await supabase.from('wish_requests').insert({
  'community_id': communityId,
  'user_id': userId,
  'item_name': itemName,
  'description': description,
  'urgent': urgent,
});


/// FETCH USER NAME FROM PROFILE
/// FETCH USER NAME FROM PROFILE
final profile = await supabase
    .from('profiles')
    .select('full_name')
    .eq('user_id', userId)
    .single();

final userName = profile['full_name'];

debugPrint("USER ID: ${user.id}");
     
/// INSERT COMMUNITY NOTIFICATION
await supabase.from('notifications').insert({
  'community_id': communityId,
  'title': 'New Wish Request',
  'message': '$userName requested $itemName',
  'type': 'wish_request',
});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wish posted successfully")),
      );

      _itemController.clear();
      _descController.clear();

      setState(() {
        isHighUrgency = false;
      });
    } catch (e) {
      debugPrint("POST ERROR: $e");
      debugPrint("Community ID: $communityId");

      ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text("Error : $e")),
      );
    }
  }

  /// UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppBarWidget(
            title: "Create Wish",
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                      "What do you need?", Icons.lightbulb_outline),
                  const SizedBox(height: 16),
                  _buildCustomTextField(
                    controller: _itemController,
                    hint: "e.g. Iron, Ladder, Drill Machine",
                    label: "Item Name",
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                      "Add some details", Icons.description_outlined),
                  const SizedBox(height: 16),
                  _buildCustomTextField(
                    controller: _descController,
                    hint: "Describe your need",
                    label: "Description",
                    maxLines: 4,
                    maxLength: 150,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: backgroundLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isHighUrgency
                            ? Colors.orangeAccent
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          color: isHighUrgency
                              ? Colors.orangeAccent
                              : accentTeal,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Mark as Urgent",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: darkPrimary,
                                ),
                              ),
                              Text(
                                "Use this if you need the item immediately",
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isHighUrgency,
                          activeColor: Colors.orangeAccent,
                          onChanged: (val) =>
                              setState(() => isHighUrgency = val),
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
      bottomNavigationBar: _buildPostButton(),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: accentTeal),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: darkPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hint,
    required String label,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
            filled: true,
            fillColor: backgroundLight.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildPostButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          gradient: appGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ElevatedButton(
          onPressed: _showConfirmDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            "Post Wish",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}