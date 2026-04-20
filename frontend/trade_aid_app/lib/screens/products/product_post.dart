import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/notification_service.dart';

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

// ✅ Animated card widget
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

class ProductPostScreen extends StatefulWidget {
  final String communityId;
  final String? wishId;
  final bool? makePublicAfter48Hours;
  final String? requesterId;

  const ProductPostScreen({
    super.key,
    required this.communityId,
    this.wishId,
    this.makePublicAfter48Hours,
    this.requesterId,
  });

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
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _images[slot] = picked);
  }

  void _removeImage(int slot) => setState(() => _images[slot] = null);

  void _showImageOptions(int index) {
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
                color: Colors.red,
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
    final img = _images[index];
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
                      fontWeight: FontWeight.bold,
                      color: darkPrimary,
                    ),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    Image.file(
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
          decoration: _modernInput(label, icon: icon),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(displayText, style: const TextStyle(fontSize: 14)),
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

  // ---------------- SUBMIT ----------------

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (_isLoading) return;

    // 1. Check Images
    if (!_images.any((e) => e != null)) {
      _showAnimatedCard("Please upload at least one image",
          icon: Icons.image_not_supported);
      return;
    }

    // 2. Check Text Fields via Form Validator
    if (!_formKey.currentState!.validate()) {
      _showAnimatedCard("Please fill all text fields",
          icon: Icons.edit_note_rounded);
      return;
    }

    // 3. ✅ CHECK DROPDOWNS SPECIFICALLY
    if (_usedTimeValue == null ||
        _conditionValue == null ||
        _productCategoryValue == null) {
      _showAnimatedCard("Please select all dropdown options",
          icon: Icons.arrow_drop_down_circle_outlined);
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception("User not authenticated");
      }

      List<String> imageUrls = [];

      for (var image in _images.whereType<XFile>()) {
        final file = File(image.path);

        final filePath =
            "${widget.communityId}/${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg";

        await supabase.storage.from('product-images').upload(filePath, file);

        final imageUrl =
            supabase.storage.from('product-images').getPublicUrl(filePath);

        imageUrls.add(imageUrl);
      }

      /// BASE PRODUCT DATA
      final Map<String, dynamic> data = {
        'community_id': widget.communityId,
        'user_id': user.id,
        'title': _productName!.trim(),
        'description': _description!.trim(),
        'price': double.parse(_price!.trim()),
        'category': _productCategoryValue,
        'condition': _conditionValue,
        'used_time': _usedTimeValue,
        'images': imageUrls,
      };

      /// IF PRODUCT IS FULFILLING A WISH
      if (widget.wishId != null) {
        final expiresAt = DateTime.now().add(const Duration(hours: 48));

        data.addAll({
          'wish_request_id': widget.wishId,
          'reserved_for': widget.requesterId,
          'make_public_after_48h': widget.makePublicAfter48Hours ?? false,
          'expires_at': expiresAt.toIso8601String(),
        });
      }

      await supabase.from('products').insert(data);

      if (widget.wishId != null && widget.requesterId != null) {
        final requesterNotification = await supabase
            .from('profiles')
            .select('full_name')
            .eq('user_id', user.id)
            .single();

        final uploaderName =
            requesterNotification['full_name'] as String? ?? 'Someone';

        await NotificationService.createNotification(
          userId: widget.requesterId!,
          title: 'Product posted for your wish',
          message: '$uploaderName has posted the product you requested.',
          type: 'wish_fulfilled',
        );
      }

      if (!mounted) return;

      _showAnimatedCard("Product Published Successfully", icon: Icons.check);

      Navigator.pop(context, true);
    } catch (e) {
      _showAnimatedCard("Error: ${e.toString()}", icon: Icons.error);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // ---------------- UI ----------------

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
                          buildCounter: (
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
                                'POST PRODUCT',
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