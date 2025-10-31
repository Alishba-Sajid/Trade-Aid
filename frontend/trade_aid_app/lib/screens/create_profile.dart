import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert'; // <-- needed for jsonDecode
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../screens/location_permission_screen.dart';

// 🎨 Custom Color Palette
const Color kPrimaryTeal = Color(0xFF004D40);
const Color kLightTeal = Color(0xFF70B2B2);
const Color kSkyBlue = Color(0xFF9ECFD4);
const Color kPaleYellow = Color(0xFFE5E9C5);

class CreateProfileScreen extends StatefulWidget {
  final String email;
  final String password;

  const CreateProfileScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _selectedGender;
  File? _profileImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _saveUserProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final url = Uri.parse('http://192.168.18.29:5000/api/users/profile');

    try {
      final request = http.MultipartRequest('POST', url);

      // Add text fields
      request.fields['email'] = widget.email;
      // don't need to send password again for profile update
      request.fields['full_name'] = _nameController.text.trim();
      request.fields['gender'] = _selectedGender ?? '';
      request.fields['phone'] = _phoneController.text.trim();
      request.fields['address'] = _addressController.text.trim();

      // Add profile picture if selected
      if (_profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture',
          _profileImage!.path,
        ));
      }

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      final status = streamedResponse.statusCode;

      if (status == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile created successfully!')),
        );

        Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const LocationPermissionScreen()),
);
      } else {
        if (!mounted) return;
        // try to parse server message if provided
        String msg = 'Failed to create profile (Error $status)';
        try {
          final parsed = jsonDecode(responseBody);
          if (parsed is Map && parsed.containsKey('message')) {
            msg = parsed['message'];
          }
        } catch (_) {
          // ignore parse errors
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error connecting to server: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Create Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: kPrimaryTeal,
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // 👤 Profile Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: kSkyBlue.withOpacity(0.3),
                  backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? const Icon(Icons.camera_alt, size: 40, color: kLightTeal)
                      : null,
                ),
              ),

              const SizedBox(height: 25),

              // 🧍 Full Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  labelStyle: const TextStyle(color: kLightTeal),
                  filled: true,
                  fillColor: kSkyBlue.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: kPrimaryTeal, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.person, color: kLightTeal),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter your name" : null,
              ),

              const SizedBox(height: 20),

              // ⚧ Gender Dropdown
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: const [
                  DropdownMenuItem(value: "Male", child: Text("Male")),
                  DropdownMenuItem(value: "Female", child: Text("Female")),
                ],
                onChanged: (value) => setState(() => _selectedGender = value),
                decoration: InputDecoration(
                  labelText: "Gender",
                  labelStyle: const TextStyle(color: kLightTeal),
                  filled: true,
                  fillColor: kSkyBlue.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: kPrimaryTeal, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.wc, color: kLightTeal),
                ),
                validator: (value) =>
                    value == null ? "Please select your gender" : null,
              ),

              const SizedBox(height: 20),

              // ☎️ Phone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  labelStyle: const TextStyle(color: kLightTeal),
                  filled: true,
                  fillColor: kSkyBlue.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: kPrimaryTeal, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.phone, color: kLightTeal),
                ),
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

              const SizedBox(height: 20),

              // 🏠 Address
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: "Address",
                  labelStyle: const TextStyle(color: kLightTeal),
                  filled: true,
                  fillColor: kSkyBlue.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: kPrimaryTeal, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.home, color: kLightTeal),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter your address" : null,
              ),

              const SizedBox(height: 40),

              // 🔘 Next Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                  ),
                  onPressed: _isLoading ? null : _saveUserProfile,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Next",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
