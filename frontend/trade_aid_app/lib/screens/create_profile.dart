// lib/screens/create_profile.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ Animated card widget (same style as login/create account)
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
                    style: const TextStyle(color: Colors.black),
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

// ✅ Main screen
class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _selectedGender;
  File? _profileImage;
  bool _loading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ✅ Show animated card
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw 'User not logged in';

      String? uploadedImageUrl;

      if (_profileImage != null) {
        final bucket = 'profile-images';
        final filePath = 'users/${user.id}-profile.jpg';
        await supabase.storage
            .from(bucket)
            .upload(
              filePath,
              _profileImage!,
              fileOptions: const FileOptions(upsert: true),
            );
        uploadedImageUrl = supabase.storage.from(bucket).getPublicUrl(filePath);
      }

      await supabase.from('profiles').insert({
        'user_id': user.id,
        'full_name': _nameController.text.trim(),
        'gender': _selectedGender,
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'profile_image_url': uploadedImageUrl ?? '',
      });

      _showAnimatedCard("Profile created successfully 🎉", icon: Icons.check);
      Navigator.pushNamed(context, '/location_permission');
    } catch (e) {
      _showAnimatedCard("Error saving profile: $e", icon: Icons.error);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: screenHeight * 0.35,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 15, 119, 124),
                  Color.fromARGB(255, 17, 158, 144),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  'assets/whitenamelogo.png',
                  height: 130,
                  width: 130,
                ),
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: _buildFormCard(context),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create Profile 📝",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Fill in your profile details",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.teal.shade100,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : null,
                  child: _profileImage == null
                      ? const Icon(Icons.person, size: 35, color: Colors.white)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _nameController,
              label: "Full Name",
              prefix: const Icon(Icons.person),
              validator: (value) =>
                  value!.isEmpty ? "Please enter your name" : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              items: const [
                DropdownMenuItem(value: "Male", child: Text("Male")),
                DropdownMenuItem(value: "Female", child: Text("Female")),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              decoration: const InputDecoration(
                labelText: "Gender",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wc),
              ),
              validator: (value) =>
                  value == null ? "Please select your gender" : null,
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _phoneController,
              label: "Phone Number",
              prefix: const Icon(Icons.phone),
              keyboard: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.length < 10) {
                  return 'Enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _addressController,
              label: "Address",
              prefix: const Icon(Icons.home),
              validator: (value) =>
                  value!.isEmpty ? "Please enter your address" : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 17, 158, 144),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Next",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildField({
  required TextEditingController controller,
  required String label,
  Icon? prefix,
  TextInputType keyboard = TextInputType.text,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboard,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: prefix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
