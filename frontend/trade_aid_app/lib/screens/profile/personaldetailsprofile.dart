import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/profile_service.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  File? _profileImage;
  String? profileImageUrl;
  bool _isEditing = false;
  bool _isLoading = false;

  final _nameController = TextEditingController(text: "Username");
  final _phoneController = TextEditingController(text: "0300000000");
  final _addressController = TextEditingController(text: "123, abc");

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    final data = await ProfileService().getProfile();

    if (data != null) {
      setState(() {
        _nameController.text = data['full_name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _addressController.text = data['address'] ?? '';
        profileImageUrl = data['profile_image_url'];
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    if (!_isEditing) return;
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    String? imageUrl = profileImageUrl;

    if (_profileImage != null) {
      imageUrl = await ProfileService().uploadProfileImage(_profileImage!);
    }

    await ProfileService().updateProfile(
      name: _nameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      imageUrl: imageUrl,
    );

    setState(() {
      _isEditing = false;
      _isLoading = false;
      profileImageUrl = imageUrl;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (_isEditing) {
      setState(() {
        _isEditing = false;
      });
      return false;
    }
    return true;
  }

  void _confirmDeleteAccount() async {
    await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Delete Account",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF004D40),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Do you really want to delete your account?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF004D40)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF004D40),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 164, 10, 10),
                            Color.fromARGB(255, 220, 50, 50),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          await ProfileService().deleteAccount();
                          if (mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/welcome',
                              (route) => false,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
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

  Widget _field(String label, TextEditingController controller, IconData icon) {
    // Dynamic colors based on edit state
    final Color contentColor = _isEditing ? Colors.black87 : Colors.grey.shade500;
    final Color iconColor = _isEditing ? const Color(0xFF009688) : Colors.grey.shade400;
    final Color labelColor = _isEditing ? const Color(0xFF00695C) : Colors.grey.shade400;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        enabled: _isEditing,
        style: TextStyle(
          color: contentColor,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          icon: Icon(icon, color: iconColor),
          labelText: label,
          labelStyle: TextStyle(
            color: labelColor,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: !_isEditing,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              height: 260,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 15, 119, 124),
                    Color.fromARGB(255, 17, 158, 144),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 60,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    ),
                  ),
                  Positioned(
                    top: 60,
                    right: 16,
                    child: IconButton(
                      icon: Icon(
                        _isEditing ? Icons.close : Icons.edit,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => setState(() => _isEditing = !_isEditing),
                    ),
                  ),
                  const Positioned(
                    top: 70,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        "Personal Details",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 52,
                          backgroundColor: Colors.teal.shade200,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : (profileImageUrl != null && profileImageUrl!.isNotEmpty
                                  ? NetworkImage(profileImageUrl!)
                                  : null),
                          child: (_profileImage == null &&
                                  (profileImageUrl == null || profileImageUrl!.isEmpty))
                              ? Icon(
                                  _isEditing ? Icons.camera_alt : Icons.person,
                                  size: 42,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 20,
                      bottom: keyboardHeight + 100,
                    ),
                    child: Column(
                      children: [
                        _field("Full Name", _nameController, Icons.person),
                        _field("Phone", _phoneController, Icons.phone),
                        _field("Address", _addressController, Icons.home),
                      ],
                    ),
                  ),

                  // Bottom Buttons
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isEditing
                          ? SizedBox(
                              key: const ValueKey('save'),
                              height: 52,
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF009688),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: _isLoading ? null : _saveChanges,
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                        "Save Changes",
                                        style: TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                              ),
                            )
                          : SizedBox(
                              key: const ValueKey('delete'),
                              height: 52,
                              width: double.infinity,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: Color.fromARGB(255, 164, 10, 10)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: _confirmDeleteAccount,
                                child: const Text(
                                  "Delete Account",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 164, 10, 10),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}