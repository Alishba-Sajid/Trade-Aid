import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// 🌿 Shared Premium Industrial Palette
const LinearGradient appGradient = LinearGradient(
colors: [Color.fromARGB(255, 15, 119, 124),
      Color.fromARGB(255, 17, 158, 144),],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

const Color darkPrimary = Color(0xFF004D40);
const Color backgroundLight = Color(0xFFF8FAFA);
const Color accentTeal = Color(0xFF119E90);
const Color subtleGrey = Color(0xFFF2F2F2);

class ResourcePostScreen extends StatefulWidget {
  const ResourcePostScreen({super.key});

  @override
  State<ResourcePostScreen> createState() => _ResourcePostScreenState();
}

class _ResourcePostScreenState extends State<ResourcePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final List<XFile?> _images = [null, null, null];
  bool _isLoading = false;

  // Form Fields
  final Map<String, bool> _availableDays = {
    'MON': false, 'TUE': false, 'WED': false, 'THU': false, 'FRI': false, 'SAT': false, 'SUN': false,
  };
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _description; // ignore: unused_field
  String? _rate; // ignore: unused_field

  /// --- INPUT DECORATION ---
  InputDecoration _industrialInput(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: const TextStyle(color: Colors.blueGrey, fontSize: 14, fontWeight: FontWeight.w500),
      prefixIcon: icon != null ? Icon(icon, color: accentTeal) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  /// --- IMAGE HANDLING ---
  Future<void> _pickImage(int slot) async {
    FocusScope.of(context).unfocus();
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _images[slot] = picked);
  }

  void _removeImage(int slot) => setState(() => _images[slot] = null);

  void _showImageOptions(int index) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh_rounded, color: accentTeal),
              title: const Text('Replace Photo', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () { Navigator.pop(context); _pickImage(index); },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              title: const Text('Remove Photo', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () { Navigator.pop(context); _removeImage(index); },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlot(int index) {
    final XFile? img = _images[index];
    return GestureDetector(
      onTap: () => img == null ? _pickImage(index) : _showImageOptions(index),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: img == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_camera_outlined, size: 28, color: accentTeal.withOpacity(0.6)),
                  const SizedBox(height: 6),
                  const Text('UPLOAD', style: TextStyle(letterSpacing: 1.2, fontSize: 10, color: darkPrimary, fontWeight: FontWeight.bold)),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.file(File(img.path), fit: BoxFit.cover),
              ),
      ),
    );
  }

  void _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: darkPrimary, content: Text('Resource Posted Successfully')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Check if keyboard is visible
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return GestureDetector(
   onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
child: Scaffold(
  backgroundColor: backgroundLight,
  appBar: PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight),
    child: Container(
      decoration: BoxDecoration(
        gradient: appGradient, // Using the gradient defined at the top
      ),
      child: AppBar(
        centerTitle: true,
        title: const Text(
          'Resource Post',
          style: TextStyle(
            letterSpacing: 2,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent, // Must be transparent for gradient
        foregroundColor: Colors.white,
      ),
    ),
  ),

        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              // REMOVE SCROLLING WHEN KEYBOARD IS INITIATED
              physics: isKeyboardVisible ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  _sectionWrapper(
                    title: 'Technical Visuals',
                    child: Row(
                      children: List.generate(3, (index) => Expanded(
                        child: Padding(padding: EdgeInsets.only(right: index < 2 ? 8.0 : 0), child: _buildImageSlot(index))
                      )),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _sectionWrapper(
                    title: 'Specifications',
                    child: TextFormField(
                      maxLines: 4,
                      maxLength: 250,
                      decoration: _industrialInput('Enter Resource Details'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      onSaved: (v) => _description = v,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _sectionWrapper(
                    title: 'Operational Window',
                    child: Column(
                      children: [
                        _buildDayPicker(),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _timeTile('Start Time', _startTime, true)),
                            const SizedBox(width: 10),
                            Expanded(child: _timeTile('End Time', _endTime, false)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _sectionWrapper(
                    title: 'Costing',
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: _industrialInput('Hourly Rate (PKR)', icon: Icons.payments_outlined),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      onSaved: (v) => _rate = v,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: appGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: accentTeal.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                        child: _isLoading
                            ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                            : const Text('Post Resource', style: TextStyle(letterSpacing: 2, fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionWrapper({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: subtleGrey, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: const TextStyle(letterSpacing: 2, fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildDayPicker() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _availableDays.keys.map((day) {
        bool isSelected = _availableDays[day]!;
        return GestureDetector(
          onTap: () => setState(() => _availableDays[day] = !isSelected),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? accentTeal : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isSelected ? accentTeal : Colors.grey.shade300),
            ),
            child: Text(day, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : darkPrimary)),
          ),
        );
      }).toList(),
    );
  }

  Widget _timeTile(String label, TimeOfDay? time, bool isStart) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: accentTeal, 
                  onPrimary: Colors.white, 
                  onSurface: darkPrimary, 
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(foregroundColor: accentTeal),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) setState(() => isStart ? _startTime = picked : _endTime = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const SizedBox(height: 4),
            Text(time?.format(context) ?? '--:--', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkPrimary)),
          ],
        ),
      ),
    );
  }
}