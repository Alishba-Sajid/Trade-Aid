import 'package:flutter/material.dart';
import '../widgets/time_picker.dart';
// Teal color palette (consistent)
const Color kPrimaryTeal = Color(0xFF004D40); // main teal used across the UI
const Color kLightTeal = Color(0xFF70B2B2); // lighter teal accent
const Color kSkyBlue = Color(0xFF9ECFD4); // soft blue used for placeholders
const Color kPaleYellow = Color(0xFFE5E9C5); // subtle yellow/green tint used sparingly

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manage Uploads Demo',
      theme: ThemeData(
        primaryColor: kPrimaryTeal,
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryTeal),
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryTeal,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryTeal),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kPrimaryTeal,
        ),
      ),
      home: const ManageUploadsScreen(),
    );
  }
}

class ManageUploadsScreen extends StatefulWidget {
  const ManageUploadsScreen({super.key});

  @override
  State<ManageUploadsScreen> createState() => _ManageUploadsScreenState();
}

class _ManageUploadsScreenState extends State<ManageUploadsScreen>
    with SingleTickerProviderStateMixin {
  // Weekday constants (short)
  static const List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // Sample product list
  List<Map<String, dynamic>> products = [
    {
      'id': 'p1',
      'type': 'product',
      'name': 'Spacious Lawn',
      'description': 'Lawn booking for 3 hours',
      'price': 2000.0,
      'duration': '3 hours',
      'seller': 'Hania B.',
      'image': 'assets/lawn.jpg',
      'enabled': true,
    },
    {
      'id': 'p2',
      'type': 'product',
      'name': 'Washing Machine',
      'description': 'High efficiency hourly use',
      'price': 300.0,
      'duration': 'per hour',
      'seller': 'Ali K.',
      'image': 'assets/washing_machine.jpg',
      'enabled': true,
    },
  ];

  // Sample resources list (contains availableDays/from/to)
  List<Map<String, dynamic>> resources = [
    {
      'id': 'r1',
      'type': 'resource',
      'name': 'How to Host an Event',
      'description': 'A quick guide to hosting successful events.',
      'image': 'assets/resource_event.jpg',
      'enabled': true,
      'duration': '15 min',
      'author': 'Panaversity',
      'availableDays': ['Mon', 'Wed', 'Fri'],
      'availableFrom': '09:00',
      'availableTo': '17:00',
    },
    {
      'id': 'r2',
      'type': 'resource',
      'name': 'Refrigeration Setup',
      'description': 'Guide to small fridge maintenance.',
      'image': 'assets/resource_fridge.jpg',
      'enabled': false,
      'duration': '8 min',
      'author': 'Sara A.',
      'availableDays': ['Tue', 'Thu'],
      'availableFrom': '10:30',
      'availableTo': '14:00',
    },
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _updateProductOrResource(Map<String, dynamic> updated) {
    setState(() {
      if (updated['type'] == 'product') {
        final idx = products.indexWhere((p) => p['id'] == updated['id']);
        if (idx != -1) products[idx] = Map.from(updated);
      } else {
        final idx = resources.indexWhere((r) => r['id'] == updated['id']);
        if (idx != -1) resources[idx] = Map.from(updated);
      }
    });
  }

  void _deleteItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                if (item['type'] == 'product') {
                  products.removeWhere((p) => p['id'] == item['id']);
                } else {
                  resources.removeWhere((r) => r['id'] == item['id']);
                }
              });
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted successfully')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditScreen(Map<String, dynamic> item) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>?>(
      MaterialPageRoute(builder: (_) => EditUploadScreen(item: Map.from(item))),
    );

    if (result != null) {
      // result has either updated item, or a special {'_action': 'delete'}
      if (result.containsKey('_action') && result['_action'] == 'delete') {
        _deleteItem(item);
      } else {
        _updateProductOrResource(result);
      }
    }
  }

  String _formatDaysList(List<dynamic>? days) {
    if (days == null || days.isEmpty) return 'Any day';
    return (days.cast<String>()).join(', ');
  }

  String _formatTimeRange(String? from, String? to) {
    if ((from == null || from.isEmpty) && (to == null || to.isEmpty)) return '';
    if (from == null || from.isEmpty) return 'Until ${to ?? ''}';
    if (to == null || to.isEmpty) return 'From ${from}';
    return '$from - $to';
  }

  Widget _buildCardForItem(Map<String, dynamic> item) {
    final isProduct = item['type'] == 'product';
    final name = item['name'] as String? ?? 'Unnamed';
    final desc = item['description'] as String? ?? '';
    final image = item['image'] as String? ?? '';
    final enabled = item['enabled'] as bool? ?? true;
    final subtitleWidgets = <Widget>[];

    if (isProduct) {
      final price = (item['price'] as num?)?.toDouble();
      final seller = item['seller'] as String?;
      if (price != null) subtitleWidgets.add(Text('Rs ${price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)));
      if (seller != null) subtitleWidgets.add(Text('Provider: $seller'));
    } else {
      final author = item['author'] as String?;
      if (author != null) subtitleWidgets.add(Text('Author: $author'));

      // Resource-specific info: days & time
      final availableDays = (item['availableDays'] as List<dynamic>?)?.cast<String>();
      final from = item['availableFrom'] as String?;
      final to = item['availableTo'] as String?;
      final daysText = _formatDaysList(availableDays);
      final timeText = _formatTimeRange(from, to);

      if (daysText.isNotEmpty) subtitleWidgets.add(Text('Days: $daysText', style: const TextStyle(fontSize: 12)));
      if (timeText.isNotEmpty) subtitleWidgets.add(Text('Time: $timeText', style: const TextStyle(fontSize: 12)));
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (c, e, st) => Container(
                  width: 80,
                  height: 80,
                  color: kSkyBlue,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image, color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black87)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 4, children: subtitleWidgets),
                ],
              ),
            ),
            // Actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: kPrimaryTeal),
                      onPressed: () => _openEditScreen(item),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteItem(item),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
                if (!isProduct)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(enabled ? 'Enabled' : 'Disabled', style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 6),
                      Switch(
                        value: enabled,
                        activeColor: kPrimaryTeal,
                        onChanged: (val) {
                          setState(() {
                            item['enabled'] = val;
                          });
                          // optional: show feedback
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(val ? 'Resource enabled' : 'Resource disabled')),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage My Uploads'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.shopping_bag_outlined), text: 'Products'),
            Tab(icon: Icon(Icons.folder_open), text: 'Resources'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Products Tab
          products.isEmpty
              ? const Center(child: Text('No products uploaded yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 12, bottom: 16),
                  itemCount: products.length,
                  itemBuilder: (ctx, i) => _buildCardForItem(products[i]),
                ),
          // Resources Tab
          resources.isEmpty
              ? const Center(child: Text('No resources uploaded yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 12, bottom: 16),
                  itemCount: resources.length,
                  itemBuilder: (ctx, i) => _buildCardForItem(resources[i]),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryTeal,
        onPressed: () {
          // Example: add a new product (you could show a create screen)
          final newId = DateTime.now().millisecondsSinceEpoch.toString();
          final newProduct = {
            'id': newId,
            'type': 'product',
            'name': 'New Product',
            'description': 'Edit to add real details.',
            'price': 0.0,
            'duration': '',
            'seller': '',
            'image': '', // empty will show placeholder
            'enabled': true,
          };
          setState(() => products.insert(0, newProduct));
          // open editor immediately
          _openEditScreen(newProduct);
        },
        child: const Icon(Icons.add),
        tooltip: 'Add new product',
      ),
    );
  }
}

/// Generic edit screen used for both product and resource editing.
/// It accepts an `item` map and returns the updated map on pop.
/// If user chooses to delete from editor, it returns {'_action': 'delete'}.
class EditUploadScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  const EditUploadScreen({super.key, required this.item});

  @override
  State<EditUploadScreen> createState() => _EditUploadScreenState();
}

class _EditUploadScreenState extends State<EditUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameC;
  late TextEditingController _descC;
  late TextEditingController _priceC;
  late TextEditingController _durationC;
  late TextEditingController _sellerC;
  late String _imagePath;
  late bool _enabled;

  // Resource-specific state
  late List<String> _availableDays; // e.g. ['Mon','Wed']
  late String _availableFrom; // '09:00'
  late String _availableTo; // '17:00'

  static const List<String> _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  bool get isProduct => widget.item['type'] == 'product';

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(text: widget.item['name'] as String? ?? '');
    _descC = TextEditingController(text: widget.item['description'] as String? ?? '');
    _priceC = TextEditingController(text: (widget.item['price']?.toString() ?? ''));
    _durationC = TextEditingController(text: widget.item['duration'] as String? ?? '');
    _sellerC = TextEditingController(text: (widget.item['seller'] as String?) ?? (widget.item['author'] as String?) ?? '');
    _imagePath = widget.item['image'] as String? ?? '';
    _enabled = widget.item['enabled'] as bool? ?? true;

    // Initialize resource-specific fields
    _availableDays = (widget.item['availableDays'] as List<dynamic>?)?.cast<String>() ?? <String>[];
    _availableFrom = widget.item['availableFrom'] as String? ?? '';
    _availableTo = widget.item['availableTo'] as String? ?? '';
  }

  @override
  void dispose() {
    _nameC.dispose();
    _descC.dispose();
    _priceC.dispose();
    _durationC.dispose();
    _sellerC.dispose();
    super.dispose();
  }

  // Utility to convert "HH:mm" string to TimeOfDay
  TimeOfDay? _parseTime(String? hhmm) {
    if (hhmm == null || hhmm.isEmpty) return null;
    final parts = hhmm.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
Future<void> _pickFromTime() async {
  final initial = _parseTime(_availableFrom) ?? const TimeOfDay(hour: 9, minute: 0);
  final picked = await showTealTimePicker(
    context,
    initialTime: initial,
    primary: kPrimaryTeal,
  );
  if (picked != null) {
    setState(() {
      _availableFrom = _formatTimeOfDay(picked);
    });
  }
}

Future<void> _pickToTime() async {
  final initial = _parseTime(_availableTo) ?? const TimeOfDay(hour: 17, minute: 0);
  final picked = await showTealTimePicker(
    context,
    initialTime: initial,
    primary: kPrimaryTeal,
  );
  if (picked != null) {
    setState(() {
      _availableTo = _formatTimeOfDay(picked);
    });
  }
}


  void _toggleDay(String day) {
    setState(() {
      if (_availableDays.contains(day)) {
        _availableDays.remove(day);
      } else {
        _availableDays.add(day);
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final updated = Map<String, dynamic>.from(widget.item);
    updated['name'] = _nameC.text.trim();
    updated['description'] = _descC.text.trim();
    updated['duration'] = _durationC.text.trim();
    updated['image'] = _imagePath;
    updated['enabled'] = _enabled;

    if (isProduct) {
      final price = double.tryParse(_priceC.text.trim()) ?? 0.0;
      updated['price'] = price;
      updated['seller'] = _sellerC.text.trim();
    } else {
      updated['author'] = _sellerC.text.trim();
      // Resource-specific save fields
      updated['availableDays'] = List<String>.from(_availableDays);
      updated['availableFrom'] = _availableFrom;
      updated['availableTo'] = _availableTo;
    }

    Navigator.of(context).pop(updated);
  }

  void _delete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete item'),
        content: const Text('Delete this upload permanently?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // close dialog
              Navigator.of(context).pop({'_action': 'delete'});
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // For demo: just toggle between an empty placeholder and a sample asset
  void _pickImageDemo() {
    setState(() {
      if (_imagePath.isEmpty) {
        _imagePath = isProduct ? 'assets/lawn.jpg' : 'assets/resource_event.jpg';
      } else {
        _imagePath = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = isProduct ? 'Edit Product' : 'Edit Resource';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: kPrimaryTeal,
        actions: [
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: _delete, tooltip: 'Delete'),
          IconButton(icon: const Icon(Icons.check, color: Colors.white), onPressed: _save, tooltip: 'Save'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image preview + pick demo
              GestureDetector(
                onTap: _pickImageDemo,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _imagePath.isEmpty
                      ? Container(
                          width: double.infinity,
                          height: 180,
                          color: kSkyBlue,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.photo, size: 48, color: Colors.white70),
                              SizedBox(height: 8),
                              Text('Tap to set image (demo)', style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                        )
                      : Image.asset(_imagePath, width: double.infinity, height: 180, fit: BoxFit.cover, errorBuilder: (c, e, st) {
                          return Container(
                            width: double.infinity,
                            height: 180,
                            color: kSkyBlue,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image, color: Colors.white70),
                          );
                        }),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameC,
                decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder(), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: kPrimaryTeal))),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descC,
                minLines: 3,
                maxLines: 6,
                decoration: InputDecoration(labelText: 'Description', border: const OutlineInputBorder(), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: kPrimaryTeal))),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Description required' : null,
              ),
              const SizedBox(height: 12),
              if (isProduct)
                TextFormField(
                  controller: _priceC,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Price', border: const OutlineInputBorder(), prefixText: 'Rs ', focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: kPrimaryTeal))),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Price required';
                    return double.tryParse(v.trim()) == null ? 'Enter valid number' : null;
                  },
                ),
              if (isProduct) const SizedBox(height: 12),
              TextFormField(
                controller: _durationC,
                decoration: InputDecoration(labelText: 'Duration / Time', border: const OutlineInputBorder(), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: kPrimaryTeal))),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sellerC,
                decoration: InputDecoration(labelText: isProduct ? 'Seller / Provider' : 'Author', border: const OutlineInputBorder(), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: kPrimaryTeal))),
              ),

              // ---------------------------
              // Resource-specific controls
              // ---------------------------
              if (!isProduct) ...[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Available Days', style: Theme.of(context).textTheme.titleMedium),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _weekdays.map((d) {
                    final selected = _availableDays.contains(d);
                    return FilterChip(
                      selectedColor: kPrimaryTeal.withOpacity(0.18),
                      checkmarkColor: kPrimaryTeal,
                      selected: selected,
                      label: Text(d, style: TextStyle(color: selected ? kPrimaryTeal : null)),
                      onSelected: (_) => _toggleDay(d),
                      backgroundColor: Colors.grey[100],
                      side: BorderSide(color: selected ? kPrimaryTeal : Colors.transparent),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Available Time', style: Theme.of(context).textTheme.titleMedium),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kPrimaryTeal),
                          foregroundColor: kPrimaryTeal,
                        ),
                        onPressed: _pickFromTime,
                        child: Text(_availableFrom.isEmpty ? 'From' : 'From: $_availableFrom'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kPrimaryTeal),
                          foregroundColor: kPrimaryTeal,
                        ),
                        onPressed: _pickToTime,
                        child: Text(_availableTo.isEmpty ? 'To' : 'To: $_availableTo'),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),
              if (!isProduct)
              Row(
                children: [
                  const Text('Enabled', style: TextStyle(fontSize: 16)),
                  const Spacer(),
                  Switch(
                    value: _enabled,
                    activeColor: kPrimaryTeal,
                    onChanged: (v) => setState(() => _enabled = v),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImageDemo,
                      icon: const Icon(Icons.photo_library, color: kPrimaryTeal),
                      label: const Text('Pick Image (demo)', style: TextStyle(color: kPrimaryTeal)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: kPrimaryTeal)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(backgroundColor: kPrimaryTeal),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
