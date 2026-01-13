import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// 🌿 Premium Industrial Color Palette
const LinearGradient appGradient = LinearGradient(
  colors: [Color(0xFF2E9499), Color(0xFF119E90)],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

const Color darkPrimary = Color(0xFF004D40);
const Color backgroundLight = Color(0xFFF8FAFA);
const Color accentTeal = Color(0xFF119E90);
const Color subtleGrey = Color(0xFFF2F2F2);

class ProductPostScreen extends StatefulWidget {
  const ProductPostScreen({super.key});

  @override
  State<ProductPostScreen> createState() => _ProductPostScreenState();
}

class _ProductPostScreenState extends State<ProductPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final List<XFile?> _images = [null, null, null];

  // Fields
  String? _productName; // ignore: unused_field
  String? _description; // ignore: unused_field
  String? _price; // ignore: unused_field

  String? _usedTimeValue;
  String? _conditionValue;
  String? _productCategoryValue;

  bool _isLoading = false;

  final List<String> _usedTimeOptions = ['< 1 month', '3 month', '6 months', '9 months', '> 1 year'];
  final List<String> _conditionOptions = ['New', 'Best', 'Good', 'Average'];
  final List<String> _productCategories = ['Lifestyle', 'Essential'];

  /// ---------------- IMAGE HANDLING ----------------
  Future<void> _pickImage(int slot) async {
    // Force keyboard down before opening gallery
    FocusScope.of(context).unfocus();
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _images[slot] = picked);
  }

  void _removeImage(int slot) => setState(() => _images[slot] = null);

  void _showImageOptions(int index) {
    FocusScope.of(context).unfocus(); // Kill keyboard
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

  /// ---------------- DROPDOWN ----------------
  Widget _premiumDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String> onChanged,
    IconData? icon,
  }) {
    final displayText = value ?? label;
    return Builder(
      builder: (context) => InkWell(
        onTap: () async {
          // IMPORTANT: This kills the keyboard immediately when the dropdown is touched
          FocusManager.instance.primaryFocus?.unfocus();

          final RenderBox box = context.findRenderObject() as RenderBox;
          final Offset position = box.localToGlobal(Offset.zero);
          final Size size = box.size;

          final selected = await showMenu<String>(
            context: context,
            color: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            position: RelativeRect.fromLTRB(position.dx, position.dy + size.height + 6, position.dx + size.width, 0),
            constraints: BoxConstraints(minWidth: size.width, maxWidth: size.width),
            items: items.map((e) => PopupMenuItem<String>(value: e, child: Text(e))).toList(),
          );

          if (selected != null) onChanged(selected);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            prefixIcon: icon != null ? Icon(icon, color: accentTeal) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(displayText, style: const TextStyle(fontSize: 14, color: Colors.black)),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    FocusScope.of(context).unfocus(); // Close keyboard on submit
    
    if (!_images.any((e) => e != null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text('Please upload at least one image')));
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: darkPrimary, content: Text('Product Published Successfully')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Wrap with GestureDetector to close keyboard when tapping outside
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: backgroundLight,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Product Post', style: TextStyle(letterSpacing: 2, fontSize: 16, fontWeight: FontWeight.w800)),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: darkPrimary,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Images ---
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: subtleGrey, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PRODUCT IMAGES', style: TextStyle(letterSpacing: 2, fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
                        const SizedBox(height: 6),
                        Row(children: List.generate(3, (index) => Expanded(child: Padding(padding: EdgeInsets.only(right: index < 2 ? 8.0 : 0), child: _buildImageSlot(index))))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // --- Basic Info ---
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: subtleGrey, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('BASIC INFORMATION', style: TextStyle(letterSpacing: 2, fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
                        const SizedBox(height: 10),
                        TextFormField(
                          textInputAction: TextInputAction.done, // Changes 'Next' to 'Done'
                          onEditingComplete: () => FocusScope.of(context).unfocus(), // Kills keyboard on Done
                          decoration: _industrialInput('Product Name', icon: Icons.shopping_bag_outlined),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          onSaved: (v) => _productName = v,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          maxLines: 3,
                          maxLength: 250,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: () => FocusScope.of(context).unfocus(),
                          decoration: _industrialInput('Enter Full Description'),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          onSaved: (v) => _description = v,
                          buildCounter: (context, {required currentLength, maxLength, required isFocused}) {
                            final isLimitApproaching = currentLength >= 240;
                            return Text('$currentLength / ${maxLength ?? 0}', style: TextStyle(fontSize: 10, color: isLimitApproaching ? Colors.red : Colors.grey[600]));
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: () => FocusScope.of(context).unfocus(),
                          decoration: _industrialInput('Price', icon: Icons.payments_outlined),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          onSaved: (v) => _price = v,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // --- Details ---
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: subtleGrey, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('DETAILS', style: TextStyle(letterSpacing: 2, fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _premiumDropdown(label: 'Duration ', value: _usedTimeValue, items: _usedTimeOptions, onChanged: (v) => setState(() => _usedTimeValue = v), icon: Icons.timelapse)),
                            const SizedBox(width: 10),
                            Expanded(child: _premiumDropdown(label: 'Status', value: _conditionValue, items: _conditionOptions, onChanged: (v) => setState(() => _conditionValue = v), icon: Icons.check_circle_outline)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _premiumDropdown(label: 'Category', value: _productCategoryValue, items: _productCategories, onChanged: (v) => setState(() => _productCategoryValue = v), icon: Icons.category),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Submit Button ---
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
                            : const Text('Post Product', style: TextStyle(letterSpacing: 2, fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
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
}