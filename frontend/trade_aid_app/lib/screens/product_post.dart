import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// 🌿 Shared App Colors
const Color kPrimaryTeal = Color(0xFF004D40); // main teal used across the UI
const Color kLightTeal = Color(0xFF70B2B2);   // lighter teal accent
const Color kSkyBlue = Color(0xFF9ECFD4);     // soft blue used for placeholders
const Color kPaleYellow = Color(0xFFE5E9C5);  // subtle yellow/green tint used for dropdown

class ProductPostScreen extends StatefulWidget {
  const ProductPostScreen({super.key});

  @override
  State<ProductPostScreen> createState() => _ProductPostScreenState();
}

class _ProductPostScreenState extends State<ProductPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final List<XFile?> _images = [null, null, null];

  String? _description;
  String? _price;
  String _usedTime = '< 1 month';
  String _condition = 'Good';
  String _productCategory = 'Lifestyle';

  final List<String> _usedTimeOptions = [
    '< 1 month',
    '1 month',
    '2 months',
    '3 months',
    '> 1 year'
  ];
  final List<String> _conditionOptions = ['Best', 'Good', 'Average', 'New'];
  final List<String> _productCategories = ['Lifestyle', 'Essential'];

  Future<void> _pickImage(int slot) async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _images[slot] = picked);
    }
  }

  void _removeImage(int slot) {
    setState(() => _images[slot] = null);
  }

  Widget _buildImageSlot(int index) {
    final XFile? img = _images[index];
    return GestureDetector(
      onTap: () {
        if (img == null) {
          _pickImage(index);
        } else {
          showModalBottomSheet(
            context: context,
            builder: (_) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Replace'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(index);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Remove'),
                    onTap: () {
                      Navigator.pop(context);
                      _removeImage(index);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.close),
                    title: const Text('Close'),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          );
        }
      },
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kLightTeal, width: 1.5),
        ),
        child: img == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_a_photo, size: 28, color: Colors.black54),
                  SizedBox(height: 6),
                  Text('Add', style: TextStyle(color: Colors.black54)),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(img.path), fit: BoxFit.cover),
              ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Fix form errors')));
      return;
    }
    _formKey.currentState!.save();

    final imagesPaths =
        _images.where((e) => e != null).map((e) => e!.path).toList();

    final Map<String, dynamic> payload = {
      'type': 'product',
      'images': imagesPaths,
      'description': _description,
      'price': _price,
      'usedTime': _usedTime,
      'condition': _condition,
      'category': _productCategory,
    };

    debugPrint('Product posted: $payload');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Product submitted — ${imagesPaths.length} images')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // 💠 Common border styling
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color, width: 1.4),
        );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Post Product',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pictures (up to 3)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (_, i) => _buildImageSlot(i),
                  ),
                ),
                const SizedBox(height: 18),

                // 📝 Description
                TextFormField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: border(Colors.grey.shade300),
                    focusedBorder: border(kPrimaryTeal),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter description' : null,
                  onSaved: (v) => _description = v!.trim(),
                ),
                const SizedBox(height: 12),

                // 💰 Price
                TextFormField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Price',
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: border(Colors.grey.shade300),
                    focusedBorder: border(kPrimaryTeal),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter price';
                    if (double.tryParse(v.trim()) == null) return 'Invalid number';
                    return null;
                  },
                  onSaved: (v) => _price = v!.trim(),
                ),
                const SizedBox(height: 12),

                // 🕓 Used time + condition
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _usedTime,
                        decoration: InputDecoration(
                          labelText: 'Used for',
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: border(Colors.grey.shade300),
                          focusedBorder: border(kPrimaryTeal),
                        ),
                        dropdownColor: kPaleYellow,
                        items: _usedTimeOptions
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _usedTime = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _condition,
                        decoration: InputDecoration(
                          labelText: 'Condition',
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: border(Colors.grey.shade300),
                          focusedBorder: border(kPrimaryTeal),
                        ),
                        dropdownColor: kPaleYellow,
                        items: _conditionOptions
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _condition = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 🏷️ Category
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _productCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: border(Colors.grey.shade300),
                    focusedBorder: border(kPrimaryTeal),
                  ),
                  dropdownColor: kPaleYellow,
                  items: _productCategories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _productCategory = v!),
                ),
                const SizedBox(height: 20),

                // ✅ Submit button
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryTeal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Submit Product',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
