import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// 🌿 Premium Industrial Color Palette
const LinearGradient appGradient = LinearGradient(
  colors: [
    Color.fromARGB(255, 15, 119, 124),
    Color.fromARGB(255, 17, 158, 144),
  ],
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

  String? _productName;
  String? _description;
  String? _price;
  String? _usedTimeValue;
  String? _conditionValue;
  String? _productCategoryValue;

  bool _isLoading = false;

  final List<String> _usedTimeOptions = [
    '< 1 month',
    '3 month',
    '6 months',
    '9 months',
    '> 1 year',
  ];
  final List<String> _conditionOptions = ['New', 'Best', 'Good', 'Average'];
  final List<String> _productCategories = ['Lifestyle', 'Essential'];

  // ---------------- IMAGE HANDLING ----------------
  Future<void> _pickImage(int slot) async {
    FocusScope.of(context).unfocus();
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _images[slot] = picked);
  }

  void _removeImage(int slot) => setState(() => _images[slot] = null);

  void _showImageOptions(int index) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh_rounded, color: accentTeal),
              title: const Text(
                'Replace Photo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(index);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
              ),
              title: const Text(
                'Remove Photo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                _removeImage(index);
              },
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
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.blueGrey.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: img == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_camera_outlined,
                    size: 28,
                    color: accentTeal.withOpacity(0.6),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'UPLOAD',
                    style: TextStyle(
                      letterSpacing: 1.2,
                      fontSize: 12,
                      color: darkPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(img.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
      ),
    );
  }

  InputDecoration _modernInput(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      prefixIcon: icon != null ? Icon(icon, color: accentTeal) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blueGrey.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blueGrey.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accentTeal.withOpacity(0.6), width: 1.5),
      ),
    );
  }

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
          FocusManager.instance.primaryFocus?.unfocus();
          final RenderBox box = context.findRenderObject() as RenderBox;
          final Offset position = box.localToGlobal(Offset.zero);
          final Size size = box.size;

          final selected = await showMenu<String>(
            context: context,
            color: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            position: RelativeRect.fromLTRB(
              position.dx,
              position.dy + size.height + 6,
              position.dx + size.width,
              0,
            ),
            constraints: BoxConstraints(
              minWidth: size.width,
              maxWidth: size.width,
            ),
            items: items
                .map((e) => PopupMenuItem<String>(value: e, child: Text(e)))
                .toList(),
          );
          if (selected != null) onChanged(selected);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            prefixIcon: icon != null ? Icon(icon, color: accentTeal) : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blueGrey.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blueGrey.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: accentTeal.withOpacity(0.6),
                width: 1.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayText,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    FocusScope.of(context).unfocus(); // Close keyboard

    // Check if at least one image is uploaded
    if (!_images.any((e) => e != null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Please upload at least one image'),
        ),
      );
      return;
    }

    // Validate form
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Collect product data into a map
    final Map<String, dynamic> productData = {
      'title': _productName,
      'description': _description,
      'price': _price,
      'category': _productCategoryValue,
      'condition': _conditionValue,
      'usedTime': _usedTimeValue,
      'images': _images.whereType<XFile>().map((e) => e.path).toList(),
    };

    // For now, we can print to check
    print('Product Data: $productData');

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: darkPrimary,
        content: Text('Product Published Successfully'),
      ),
    );

    // Return the product data to previous screen
    Navigator.pop(context, productData);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: backgroundLight,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Container(
            height: 100,
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      "Product Post",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Images
                  _sectionHeading('PRODUCT IMAGES'),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(
                      3,
                      (index) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: index < 2 ? 8.0 : 0),
                          child: _buildImageSlot(index),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Basic Info
                  _sectionHeading('BASIC INFORMATION'),
                  const SizedBox(height: 6),
                  TextFormField(
                    textInputAction: TextInputAction.done,
                    decoration: _modernInput(
                      'Product Name',
                      icon: Icons.shopping_bag_outlined,
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                    onSaved: (v) => _productName = v,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    maxLines: 3,
                    maxLength: 200,
                    textInputAction: TextInputAction.done,
                    decoration: _modernInput(
                      'Description',
                      icon: Icons.description_outlined,
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                    onSaved: (v) => _description = v,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: _modernInput(
                      'Price',
                      icon: Icons.payments_outlined,
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                    onSaved: (v) => _price = v,
                  ),
                  const SizedBox(height: 16),
                  // Details
                  _sectionHeading('DETAILS'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _premiumDropdown(
                          label: 'Duration',
                          value: _usedTimeValue,
                          items: _usedTimeOptions,
                          onChanged: (v) => setState(() => _usedTimeValue = v),
                          icon: Icons.timelapse,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _premiumDropdown(
                          label: 'Status',
                          value: _conditionValue,
                          items: _conditionOptions,
                          onChanged: (v) => setState(() => _conditionValue = v),
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _premiumDropdown(
                    label: 'Category',
                    value: _productCategoryValue,
                    items: _productCategories,
                    onChanged: (v) => setState(() => _productCategoryValue = v),
                    icon: Icons.category,
                  ),
                  const SizedBox(height: 24),
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: appGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: accentTeal.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              )
                            : const Text(
                                'Post Product',
                                style: TextStyle(
                                  letterSpacing: 2,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeading(String title) {
    return Row(
      children: [
        Container(width: 4, height: 20, color: accentTeal),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: Colors.blueGrey,
          ),
        ),
      ],
    );
  }
}
