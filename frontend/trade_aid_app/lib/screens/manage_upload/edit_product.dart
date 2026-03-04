import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

class EditUploadProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const EditUploadProductScreen({super.key, required this.product});

  @override
  State<EditUploadProductScreen> createState() =>
      _EditUploadProductScreenState();
}

class _EditUploadProductScreenState extends State<EditUploadProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final List<XFile?> _images = [null, null, null];

  late String? _productName;
  late String? _description;
  late String? _price;
  late String? _usedTimeValue;
  late String? _conditionValue;
  late String? _productCategoryValue;

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

  @override
  void initState() {
    super.initState();
    _productName = widget.product['title'];
    _description = widget.product['description'];
    _price = widget.product['price']?.toString();
    _usedTimeValue = widget.product['usedTime'];
    _conditionValue = widget.product['condition'];
    _productCategoryValue = widget.product['category'];

     if (widget.product['images'] != null) {
  final List imagesFromDb = widget.product['images'];

  for (int i = 0; i < imagesFromDb.length && i < 3; i++) {
    _images[i] = XFile(imagesFromDb[i]); // Works for URL too
  }
}

  }

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
                child: Stack(
                  children: [
                    img.path.startsWith('http')
    ? Image.network(
        img.path,
        fit: BoxFit.cover,
        height: 150,
        width: double.infinity,
      )
    : Image.file(
        File(img.path),
        fit: BoxFit.cover,
        height: 150,
        width: double.infinity,
      ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.white24,
                          onTap: () => _showImageOptions(index),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  InputDecoration _modernInput(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: TextStyle(
        color: Colors.blueGrey[400],
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: icon != null ? Icon(icon, color: accentTeal) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.blueGrey.withOpacity(0.2),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.blueGrey.withOpacity(0.2),
          width: 1,
        ),
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
              borderSide: BorderSide(
                color: Colors.blueGrey.withOpacity(0.2),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.blueGrey.withOpacity(0.2),
                width: 1,
              ),
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
void _submit() async {
  FocusScope.of(context).unfocus();

  if (!_formKey.currentState!.validate()) return;
  _formKey.currentState!.save();

  setState(() => _isLoading = true);

  try {
    final supabase = Supabase.instance.client;

    await supabase.from('products').update({
      'title': _productName,
      'description': _description,
      'price': double.tryParse(_price ?? "0"),
      'used_time': _usedTimeValue,
      'condition': _conditionValue,
      'category': _productCategoryValue,
      'images': _images
          .whereType<XFile>()
          .map((e) => e.path)
          .toList(),
    }).eq('id', widget.product['id']);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: darkPrimary,
        content: Text('Product updated successfully'),
      ),
    );

    Navigator.pop(context, true); // just return success
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text('Update failed: $e'),
      ),
    );
  }

  setState(() => _isLoading = false);
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
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 15, 119, 124),
                  Color.fromARGB(255, 17, 158, 144),
                ],
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
                      "Edit Product",
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
                  // --- Images ---
                  _sectionHeading('PRODUCT IMAGES'),
                  const SizedBox(height: 8),
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

                  // --- Basic Info ---
                  _sectionHeading('BASIC INFORMATION'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: _productName,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: () =>
                              FocusScope.of(context).unfocus(),
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
                          initialValue: _description,
                          maxLines: 3,
                          maxLength: 200,
                          buildCounter:
                              (
                                BuildContext context, {
                                required int currentLength,
                                required bool isFocused,
                                required int? maxLength,
                              }) {
                                return Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '$currentLength/$maxLength',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blueGrey[400],
                                    ),
                                  ),
                                );
                              },
                          textInputAction: TextInputAction.done,
                          onEditingComplete: () =>
                              FocusScope.of(context).unfocus(),
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
                          initialValue: _price,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: () =>
                              FocusScope.of(context).unfocus(),
                          decoration: _modernInput(
                            'Price',
                            icon: Icons.payments_outlined,
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                          onSaved: (v) => _price = v,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Details ---
                  _sectionHeading('DETAILS'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _premiumDropdown(
                                label: 'Duration',
                                value: _usedTimeValue,
                                items: _usedTimeOptions,
                                onChanged: (v) =>
                                    setState(() => _usedTimeValue = v),
                                icon: Icons.timelapse,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _premiumDropdown(
                                label: 'Status',
                                value: _conditionValue,
                                items: _conditionOptions,
                                onChanged: (v) =>
                                    setState(() => _conditionValue = v),
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
                          onChanged: (v) =>
                              setState(() => _productCategoryValue = v),
                          icon: Icons.category,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Submit Button ---
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
                                'Update Product',
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
}
