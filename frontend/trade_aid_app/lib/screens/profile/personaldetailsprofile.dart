import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  File? _profileImage;
  bool _isEditing = false;

  final _nameController = TextEditingController(text: "Alishba Sajid");
  final _emailController = TextEditingController(text: "alishba@email.com");
  final _phoneController = TextEditingController(text: "03001234567");
  final _addressController = TextEditingController(
    text: "Gulberg Greens, Islamabad",
  );

  Future<void> _pickImage() async {
    if (!_isEditing) return;
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  void _saveChanges() {
    setState(() {
      _isEditing = false; // exit edit mode
    });
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

  Widget _field(String label, TextEditingController controller, IconData icon) {
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
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          icon: Icon(icon, color: const Color(0xFF009688)),
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF00695C),
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

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            // Header
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
                  // Back arrow
                  Positioned(
                    top: 60,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),

                  // Edit/Close button
                  Positioned(
                    top: 60,
                    right: 16,
                    child: IconButton(
                      icon: Icon(
                        _isEditing ? Icons.close : Icons.edit,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() {
                          _isEditing = !_isEditing;
                        });
                      },
                    ),
                  ),

                  // Centered title
                  Positioned.fill(
                    top: 60,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: const Text(
                        "Personal Details",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Profile image
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
                              : null,
                          child: _profileImage == null
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

            // Form + button
            Expanded(
              child: Stack(
                children: [
                  // Scrollable form
                  SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 20,
                      bottom: _isEditing
                          ? keyboardHeight +
                                0 // button height + margin
                          : keyboardHeight + 0,
                    ),
                    child: Column(
                      children: [
                        _field("Full Name", _nameController, Icons.person),
                        _field("Email", _emailController, Icons.email),
                        _field("Phone", _phoneController, Icons.phone),
                        _field("Address", _addressController, Icons.home),
                      ],
                    ),
                  ),

                  // Save Changes button pinned at bottom
                  if (_isEditing)
                    Positioned(
                      bottom: 15,
                      left: 20,
                      right: 20,
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF009688),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _saveChanges,
                          child: const Text(
                            "Save Changes",
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
