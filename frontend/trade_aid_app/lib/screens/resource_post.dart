// lib/screens/resource_post.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ResourcePostScreen extends StatefulWidget {
  const ResourcePostScreen({super.key});

  @override
  State<ResourcePostScreen> createState() => _ResourcePostScreenState();
}

class _ResourcePostScreenState extends State<ResourcePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final List<XFile?> _images = [null, null, null];

  String? _description;
  String? _hourlyRate;
  final Map<String, bool> _availableDays = {
    'Mon': false,
    'Tue': false,
    'Wed': false,
    'Thu': false,
    'Fri': false,
    'Sat': false,
    'Sun': false,
  };
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final Color _teal = const Color(0xFF008080);
  final double _radius = 12;

  Future<void> _pickImage(int slot) async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _images[slot] = picked);
    }
  }

  void _removeImage(int slot) => setState(() => _images[slot] = null);

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
              child: Column(mainAxisSize: MainAxisSize.min, children: [
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
              ]),
            ),
          );
        }
      },
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: img == null
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Icon(Icons.add_a_photo, size: 28, color: Colors.black54),
                SizedBox(height: 6),
                Text('Add', style: TextStyle(color: Colors.black54)),
              ])
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(img.path),
                  fit: BoxFit.cover,
                  width: 110,
                  height: 110,
                ),
              ),
      ),
    );
  }

  // ✅ Updated TimePicker theme using WidgetState and withValues()
  Future<void> _pickTime({required bool isStart}) async {
    final TimeOfDay now = TimeOfDay.now();
    final TimeOfDay initial = isStart ? (_startTime ?? now) : (_endTime ?? now);

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: _teal,        // dial & buttons
            onPrimary: Colors.white, // selected text
            onSurface: Colors.black87, // default text
          ),
          timePickerTheme: TimePickerThemeData(
            backgroundColor: Colors.white,
            dialHandColor: _teal,
            dialBackgroundColor: _teal.withValues(alpha: 0.08),
            hourMinuteTextColor: WidgetStateColor.resolveWith(
              (states) => states.contains(WidgetState.selected) ? Colors.white : _teal,
            ),
            dialTextColor: WidgetStateColor.resolveWith(
              (states) => states.contains(WidgetState.selected) ? Colors.white : _teal,
            ),
            dayPeriodShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: _teal, width: 1.5),
            ),
            dayPeriodTextColor: WidgetStateColor.resolveWith(
              (states) => states.contains(WidgetState.selected) ? Colors.white : _teal,
            ),
            dayPeriodColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return _teal;
              if (states.contains(WidgetState.hovered)) return _teal.withValues(alpha: 0.12);
              return Colors.white;
            }),
            helpTextStyle: TextStyle(fontWeight: FontWeight.bold, color: _teal),
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      ),
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

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Fix form errors')));
      return;
    }
    if (!_availableDays.values.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one available day')));
      return;
    }
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please pick start and end times')));
      return;
    }

    _formKey.currentState!.save();

    final imagesPaths =
        _images.where((e) => e != null).map((e) => e!.path).toList();
    final availableDays = _availableDays.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    final payload = {
      'type': 'resource',
      'images': imagesPaths,
      'description': _description,
      'availableDays': availableDays,
      'startTime': _startTime!.format(context),
      'endTime': _endTime!.format(context),
      'hourlyRate': _hourlyRate,
    };

    debugPrint('Resource posted: $payload');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Resource submitted — ${imagesPaths.length} images')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Resource')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(children: [
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
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, i) => _buildImageSlot(i),
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter description' : null,
                onSaved: (v) => _description = v!.trim(),
              ),
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Available days'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _availableDays.keys.map((d) {
                        final sel = _availableDays[d]!;
                        return FilterChip(
                          label: Text(d),
                          selected: sel,
                          onSelected: (v) => setState(() => _availableDays[d] = v),
                          selectedColor: _teal,
                          checkmarkColor: Colors.white,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                              color: sel ? Colors.white : _teal,
                              fontWeight: FontWeight.w600),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Row(children: [
                Expanded(
                  child: _buildTimeCard(
                      label: 'Start Time',
                      time: _startTime,
                      onTap: () => _pickTime(isStart: true)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeCard(
                      label: 'End Time',
                      time: _endTime,
                      onTap: () => _pickTime(isStart: false)),
                ),
              ]),

              const SizedBox(height: 12),
              TextFormField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Hourly rate (per hour)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter hourly rate';
                  if (double.tryParse(v.trim()) == null) return 'Invalid number';
                  return null;
                },
                onSaved: (v) => _hourlyRate = v!.trim(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _teal,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    'Submit Resource',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCard({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: time != null ? _teal : Colors.white,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: _teal),
        ),
        child: Center(
          child: Text(
            time != null ? time.format(context) : label,
            style: TextStyle(
              color: time != null ? Colors.white : _teal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
