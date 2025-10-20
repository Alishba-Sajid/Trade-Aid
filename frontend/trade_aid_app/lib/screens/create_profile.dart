import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Profile"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Profile Image
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.teal.shade100,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : null,
                  child: _profileImage == null
                      ? const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Color(0xFF009688),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter your name" : null,
              ),
              const SizedBox(height: 20),

              // 👇 UPDATED: Gender Dropdown width reduced to 70%
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: DropdownButtonFormField<String>(
                    menuMaxHeight: 180,
                    initialValue: _selectedGender,
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
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
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

              // Address Field
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter your address" : null,
              ),
              const SizedBox(height: 40),

              // Next Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Note: '/location_permission' must be defined in your MaterialApp routes.
                      Navigator.pushNamed(context, '/location_permission');
                    }
                  },
                  child: const Text(
                    "Next",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
