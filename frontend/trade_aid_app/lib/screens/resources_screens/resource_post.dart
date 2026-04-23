import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/widgets/time_picker.dart';

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

// ✅ Animated card widget (same style as login/create account)
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

class ResourcePostScreen extends StatefulWidget {
  final String communityId;

  const ResourcePostScreen({super.key, required this.communityId});

  @override
  State<ResourcePostScreen> createState() => _ResourcePostScreenState();
}

class _ResourcePostScreenState extends State<ResourcePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final List<XFile?> _images = [null, null, null];

  bool _isLoading = false;

  final Map<String, bool> _availableDays = {
    'MON': false,
    'TUE': false,
    'WED': false,
    'THU': false,
    'FRI': false,
    'SAT': false,
    'SUN': false,
  };

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _description;
  String? _rate;
  String? _name;
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh_rounded, color: accentTeal),
              title: const Text("Replace Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(index);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              title: const Text("Remove Photo"),
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
          border: Border.all(color: Colors.blueGrey.withOpacity(0.2)),
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
                    "UPLOAD",
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

  // ---------------- MODERN INPUT ----------------
  InputDecoration _modernInput(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
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

  // ---------------- SECTION HEADING ----------------
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

  // ---------------- DAY PICKER ----------------
  Widget _buildDayPicker() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = 20 * 2;
    final double spacing = 6 * 6;
    final double dayWidth = (screenWidth - horizontalPadding - spacing) / 7;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _availableDays.keys.map((day) {
        final selected = _availableDays[day]!;
        return GestureDetector(
          onTap: () => setState(() => _availableDays[day] = !selected),
          child: Container(
            width: dayWidth,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? accentTeal : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? accentTeal : Colors.blueGrey.withOpacity(0.3),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : darkPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------- TIME PICKER ----------------
  Future<void> _pickTime(bool isStart) async {
    final initial = isStart
        ? _startTime ?? TimeOfDay.now()
        : _endTime ?? TimeOfDay.now();
    final picked = await showTealTimePicker(
      context,
      initialTime: initial,
      primary: accentTeal,
    );
    if (picked != null) {
      setState(() {
        if (isStart)
          _startTime = picked;
        else
          _endTime = picked;
      });
    }
  }

  Widget _timeBox(String label, TimeOfDay? time) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
          ),
          const SizedBox(height: 4),
          Text(
            time?.format(context) ?? "--:--",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
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

    if (!_formKey.currentState!.validate()) return;

    if (!_images.any((e) => e != null)) {
      _showAnimatedCard("Upload at least one image", icon: Icons.warning);
      return;
    }

    if (!_availableDays.containsValue(true)) {
      _showAnimatedCard(
        "Select at least one available day",
        icon: Icons.warning,
      );
      return;
    }

    if (_startTime == null || _endTime == null) {
      _showAnimatedCard("Select start and end time", icon: Icons.warning);
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User not authenticated");

      // ---------------- CONVERT TIME ----------------
      String _timeToString(TimeOfDay time) =>
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

      // ---------------- UPLOAD IMAGES ----------------
      List<String> imageUrls = [];

      for (var image in _images.whereType<XFile>()) {
        final file = File(image.path);
        final filePath =
            "${widget.communityId}/${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg";

        await supabase.storage.from('resource-images').upload(filePath, file);
        final imageUrl = supabase.storage
            .from('resource-images')
            .getPublicUrl(filePath);
        imageUrls.add(imageUrl);
      }

      final selectedDays = _availableDays.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      // ---------------- INSERT RESOURCE ----------------
      await supabase.from('resources').insert({
        'community_id': widget.communityId,
        'user_id': user.id,
        'description': _description!.trim(),
        'name': _name!.trim(),
        'rate': double.parse(_rate!.trim()),
        'available_days': selectedDays,
        'start_time': _timeToString(_startTime!),
        'end_time': _timeToString(_endTime!),
        'images': imageUrls,
        'is_enabled': true, // default enabled
      });

      await supabase.functions.invoke(
        'send-community-notification',
        body: {
          "community_id": widget.communityId,
          "title": "New Resource Posted 📦",
          "body": "${_name} is now available",
          "sender_id": user.id,
        },
      );

      if (!mounted) return;

      _showAnimatedCard("Resource Posted Successfully", icon: Icons.check);

      Navigator.pop(context, true);
    } catch (e) {
      _showAnimatedCard(e.toString(), icon: Icons.error);
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
            decoration: const BoxDecoration(
              gradient: appGradient,
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
                      "Post Resource",
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
                  _sectionHeading("RESOURCE IMAGES"),
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
                  const SizedBox(height: 20),
                  _sectionHeading("RESOURCE NAME"),
                  const SizedBox(height: 8),
                  TextFormField(
                    maxLines: 1,
                    decoration: _modernInput("Enter Resource Name"),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Required" : null,
                    onSaved: (v) => _name = v,
                  ),
                  const SizedBox(height: 1),

                  const SizedBox(height: 20),
                  _sectionHeading("DETAILS"),
                  const SizedBox(height: 8),
                  TextFormField(
                    maxLines: 3,
                    maxLength: 250,
                    decoration: _modernInput("Enter Resource Details"),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Required" : null,
                    onSaved: (v) => _description = v,
                  ),
                  const SizedBox(height: 20),

                  _sectionHeading("OPERATIONAL WINDOW"),
                  const SizedBox(height: 8),
                  _buildDayPicker(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickTime(true),
                          child: _timeBox("Start Time", _startTime),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickTime(false),
                          child: _timeBox("End Time", _endTime),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _sectionHeading("PRICING"),
                  const SizedBox(height: 8),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: _modernInput("Hourly Rate (PKR)"),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Required" : null,
                    onSaved: (v) => _rate = v,
                  ),
                  const SizedBox(height: 30),

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
                                "Post Resource",
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
