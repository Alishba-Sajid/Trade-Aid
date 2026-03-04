import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
const Color subtleGrey = Color(0xFFF2F2F2);

class EditUploadResourceScreen extends StatefulWidget {
  final Map<String, dynamic> resource;
  final String currentUserName;

  const EditUploadResourceScreen({
    super.key,
    required this.resource,
    required this.currentUserName,
  });

  @override
  State<EditUploadResourceScreen> createState() =>
      _EditUploadResourceScreenState();
}

class _EditUploadResourceScreenState extends State<EditUploadResourceScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final List<XFile?> _images = [null, null, null];

  bool _isLoading = false;
  late Map<String, bool> _availableDays;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _description;
  String? _rate;
  String? _name;

  @override
  void initState() {
    super.initState();
    _name = widget.resource['name'];
    _description = widget.resource['description'];
    _rate = widget.resource['rate']?.toString();
    _startTime = widget.resource['startTime'];
    _endTime = widget.resource['endTime'];

    _availableDays = {
      'MON': false,
      'TUE': false,
      'WED': false,
      'THU': false,
      'FRI': false,
      'SAT': false,
      'SUN': false,
      ...?widget.resource['days'],
    };

    if (widget.resource['images'] != null) {
      for (int i = 0; i < widget.resource['images'].length && i < 3; i++) {
        _images[i] = XFile(widget.resource['images'][i]);
      }
    }
  }

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
                Icons.delete_outline,
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

  // ---------------- INPUT DECORATION ----------------
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

  // ---------------- IMAGE SLOT ----------------
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
    // Calculate width for each day to fit in one line
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = 20 * 2; // left + right padding
    final double spacing = 6 * 6; // 6px spacing between 7 items = 6 gaps
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
    FocusScope.of(context).unfocus();
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

  // ---------------- SUBMIT ----------------
  void _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    final updated = {
      ...widget.resource,
      'name': _name,
      'description': _description,
      'rate': _rate,
      'days': _availableDays,
      'startTime': _startTime,
      'endTime': _endTime,
      'images': _images.whereType<XFile>().map((e) => e.path).toList(),
    };

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: darkPrimary,
        content: Text('Resource updated successfully'),
      ),
    );

    Navigator.pop(context, updated);
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
                      "Edit Resource",
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
                const SizedBox(height: 16),

_sectionHeading("RESOURCE NAME"),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _name,
                  maxLines: 1,
                  maxLength: 100,
                  decoration: _modernInput("Enter Resource Name"),
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                  onSaved: (v) => _name = v,
                ),
                const SizedBox(height: 16),
                _sectionHeading("DESCRIPTION"),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _description,
                  maxLines: 3,
                  maxLength: 250,
                  buildCounter:
                      (
                        context, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) {
                        return Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "$currentLength/$maxLength",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blueGrey[400],
                            ),
                          ),
                        );
                      },
                  decoration: _modernInput("Enter Resource Details"),
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                  onSaved: (v) => _name = v,
                ),
                const SizedBox(height: 16),

                _sectionHeading("DETAILS"),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _description,
                  maxLines: 3,
                  maxLength: 250,
                  buildCounter:
                      (
                        context, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) {
                        return Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "$currentLength/$maxLength",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blueGrey[400],
                            ),
                          ),
                        );
                      },
                  decoration: _modernInput("Enter Resource Details"),
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                  onSaved: (v) => _description = v,
                ),
                const SizedBox(height: 16),
                _sectionHeading("OPERATIONAL WINDOW"),
                const SizedBox(height: 8),
                _buildDayPicker(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickTime(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blueGrey.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "Start Time",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _startTime?.format(context) ?? "--:--",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickTime(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blueGrey.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "End Time",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _endTime?.format(context) ?? "--:--",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _sectionHeading("PRICING"),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _rate,
                  keyboardType: TextInputType.number,
                  decoration: _modernInput("Hourly Rate (PKR)"),
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                  onSaved: (v) => _rate = v,
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
                              "Update Resource",
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
    );
  }
}
