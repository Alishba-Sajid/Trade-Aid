import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/widgets/time_picker.dart';

/// PREMIUM INDUSTRIAL COLOR PALETTE
/// ============================================================
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
  final String currentUserName; // required for future backend

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

  @override
  void initState() {
    super.initState();
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
      for (int i = 0;
          i < widget.resource['images'].length && i < 3;
          i++) {
        _images[i] = XFile(widget.resource['images'][i]);
      }
    }
  }

  /// ---------------- IMAGE HANDLING ----------------
  Future<void> _pickImage(int slot) async {
    FocusScope.of(context).unfocus();
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _images[slot] = picked);
  }

  void _removeImage(int slot) => setState(() => _images[slot] = null);

  void _showImageOptions(int index) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh_rounded, color: accentTeal),
              title: const Text('Replace Photo',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(index);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Remove Photo',
                  style: TextStyle(fontWeight: FontWeight.w600)),
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

  /// ---------------- INPUT DECORATION ----------------
  InputDecoration _industrialInput(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: const TextStyle(
          color: Colors.blueGrey, fontSize: 14, fontWeight: FontWeight.w500),
      prefixIcon: icon != null ? Icon(icon, color: accentTeal) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blueGrey.withOpacity(0.3), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blueGrey.withOpacity(0.3), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accentTeal.withOpacity(0.6), width: 1.5),
      ),
    );
  }

  /// ---------------- IMAGE SLOT WIDGET ----------------
  Widget _buildImageSlot(int index) {
    final XFile? img = _images[index];
    return GestureDetector(
      onTap: () => img == null ? _pickImage(index) : _showImageOptions(index),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueGrey.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: img == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_camera_outlined,
                      size: 28, color: accentTeal.withOpacity(0.6)),
                  const SizedBox(height: 6),
                  const Text('UPLOAD',
                      style: TextStyle(
                          letterSpacing: 1.2,
                          fontSize: 10,
                          color: darkPrimary,
                          fontWeight: FontWeight.bold)),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.file(File(img.path), fit: BoxFit.cover),
              ),
      ),
    );
  }

  /// ---------------- SECTION WRAPPER ----------------
  Widget _sectionWrapper({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration:
          BoxDecoration(color: subtleGrey, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: const TextStyle(
                  letterSpacing: 2,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  /// ---------------- DAY PICKER ----------------
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
              border: Border.all(color: isSelected ? accentTeal : Colors.blueGrey.withOpacity(0.3)),
            ),
            child: Text(day,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : darkPrimary)),
          ),
        );
      }).toList(),
    );
  }

  /// ---------------- TIME PICKER ----------------
 Future<void> _pickTime(bool isStart) async {
  FocusScope.of(context).unfocus();

  final initial =
      isStart ? _startTime ?? TimeOfDay.now() : _endTime ?? TimeOfDay.now();

  final picked = await showTealTimePicker(
    context,
    initialTime: initial,
    primary: accentTeal,
  );

  if (picked != null) {
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }
}


  /// ---------------- SUBMIT ----------------
  void _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    // FUTURE BACKEND: Send updated resource to API
    final updatedResource = {
      ...widget.resource,
      'description': _description,
      'rate': _rate,
      'days': _availableDays,
      'startTime': _startTime,
      'endTime': _endTime,
      'images': _images.whereType<XFile>().map((e) => e.path).toList(),
    };

    Navigator.pop(context, updatedResource);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: backgroundLight,
        body: Column(
          children: [
            /// ✅ CUSTOM APP BAR
            Container(
              height: 130,
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
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 🔙 Back Button
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),

                      // 🏷 Heading
                      const Text(
                        "Edit Resource",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // Placeholder for spacing
                      const SizedBox(width: 50),
                    ],
                  ),
                ),
              ),
            ),
   const SizedBox(height: 0),
            Expanded(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _sectionWrapper(
                          title: 'Pictures',
                          child: Row(
                            children: List.generate(
                              3,
                              (index) => Expanded(
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(right: index < 2 ? 8.0 : 0),
                                  child: _buildImageSlot(index),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _sectionWrapper(
                          title: 'Specifications',
                          child: TextFormField(
                            initialValue: _description,
                            maxLines: 3,
                            maxLength: 250,
                            decoration: _industrialInput('Enter Resource Details'),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                            onSaved: (v) => _description = v,
                          ),
                          
                        ),
                        const SizedBox(height: 10),
                        _sectionWrapper(
                          title: 'Operational Window',
                          child: Column(
                            children: [
                              _buildDayPicker(),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => _pickTime(true),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Colors.blueGrey
                                                  .withOpacity(0.3),
                                              width: 1),
                                        ),
                                        child: Column(
                                          children: [
                                            const Text('Start Time',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blueGrey)),
                                            const SizedBox(height: 4),
                                            Text(
                                                _startTime?.format(context) ??
                                                    '--:--',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: darkPrimary)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => _pickTime(false),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Colors.blueGrey
                                                  .withOpacity(0.3),
                                              width: 1),
                                        ),
                                        child: Column(
                                          children: [
                                            const Text('End Time',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blueGrey)),
                                            const SizedBox(height: 4),
                                            Text(
                                                _endTime?.format(context) ??
                                                    '--:--',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: darkPrimary)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        _sectionWrapper(
                          title: 'Pricing',
                          child: TextFormField(
                            initialValue: _rate,
                            keyboardType: TextInputType.number,
                            decoration: _industrialInput('Hourly Rate (PKR)',
                                icon: Icons.payments_outlined),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                            onSaved: (v) => _rate = v,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
  width: double.infinity,
  height: 50,
  child: DecoratedBox(
    decoration: BoxDecoration(
      gradient: appGradient,
      borderRadius: BorderRadius.circular(12),
    ),
    child: ElevatedButton(
      onPressed: _isLoading ? null : _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : const Text(
              'Update Resource',
              style: TextStyle(
                  letterSpacing: 2,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
    ),
  ),
),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
