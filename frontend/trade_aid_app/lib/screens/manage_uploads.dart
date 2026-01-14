import 'package:flutter/material.dart';

// 🌿 Color palette
const Color kPrimaryTeal = Color(0xFF004D40);
const Color kLightTeal = Color(0xFF70B2B2);
const Color kSkyBlue = Color(0xFF9ECFD4);
const Color kPaleYellow = Color(0xFFE5E9C5);

void main() {
  runApp(const Manage_Upload());
}

class Manage_Upload extends StatelessWidget {
  const Manage_Upload({super.key});
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
          elevation: 2,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryTeal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: kPrimaryTeal),
            foregroundColor: kPrimaryTeal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kPrimaryTeal,
          elevation: 4,
        ),
      ),
      home: const ManageUploadsScreen(currentUserName: 'Hania B.'), // Example current user
    );
  }
}

class ManageUploadsScreen extends StatefulWidget {
  final String currentUserName; // current logged-in user
  const ManageUploadsScreen({super.key, required this.currentUserName});

  @override
  State<ManageUploadsScreen> createState() => _ManageUploadsScreenState();
}

class _ManageUploadsScreenState extends State<ManageUploadsScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> products = [
    {
      'id': 'p1',
      'type': 'product',
      'name': 'Spacious Lawn',
      'description': 'Lawn booking for 3 hours',
      'price': 2000.0,
      'duration': '3 hours',
      'seller': 'Hania B.',
      'enabled': true,
    },
    {
      'id': 'p2',
      'type': 'product',
      'name': 'Washing Machine',
      'description': 'High efficiency hourly use',
      'price': 300.0,
      'duration': 'per hour',
      'seller': 'Hania B.',
      'enabled': true,
    },
  ];

  List<Map<String, dynamic>> resources = [
    {
      'id': 'r1',
      'type': 'resource',
      'name': 'How to Host an Event',
      'description': 'A quick guide to hosting successful events.',
      'enabled': true,
      'duration': '15 min',
      'author': 'Hania B.',
      'availableDays': ['Mon', 'Wed', 'Fri'],
      'availableFrom': '09:00',
      'availableTo': '17:00',
    },
    {
      'id': 'r2',
      'type': 'resource',
      'name': 'Refrigeration Setup',
      'description': 'Guide to small fridge maintenance.',
      'enabled': false,
      'duration': '8 min',
      'author': 'Hania B.',
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

  void _updateItem(Map<String, dynamic> updated) {
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deleted successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditScreen(Map<String, dynamic> item) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>?>(
      MaterialPageRoute(
        builder: (_) => EditUploadScreen(
          item: Map.from(item),
          currentUserName: widget.currentUserName,
        ),
      ),
    );

    if (result != null) {
      if (result.containsKey('_action') && result['_action'] == 'delete') {
        _deleteItem(item);
      } else {
        _updateItem(result);
      }
    }
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final isProduct = item['type'] == 'product';
    final name = item['name'] ?? 'Unnamed';
    final desc = item['description'] ?? '';
    final enabled = item['enabled'] ?? true;

    final subtitleWidgets = <Widget>[];
    if (isProduct) {
      final price = (item['price'] as num?)?.toDouble();
      if (price != null) subtitleWidgets.add(
        Text('Rs ${price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
      );
      subtitleWidgets.add(Text('Seller: ${item['seller']}', style: const TextStyle(fontSize: 12)));
    } else {
      subtitleWidgets.add(Text('Author: ${item['author']}', style: const TextStyle(fontSize: 12)));
      final days = (item['availableDays'] as List<dynamic>?)?.cast<String>();
      final from = item['availableFrom'] as String?;
      final to = item['availableTo'] as String?;
      if (days != null && days.isNotEmpty) subtitleWidgets.add(Text('Days: ${days.join(', ')}', style: const TextStyle(fontSize: 12)));
      if ((from != null && from.isNotEmpty) || (to != null && to.isNotEmpty)) {
        subtitleWidgets.add(Text('Time: ${from ?? 'Any'} - ${to ?? 'Any'}', style: const TextStyle(fontSize: 12)));
      }
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isProduct ? [kPrimaryTeal, kLightTeal] : [Colors.orange.shade400, Colors.orange.shade200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isProduct ? Icons.shopping_bag_outlined : Icons.build_circle_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black87)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 4, children: subtitleWidgets),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: kPrimaryTeal),
                      onPressed: () => _openEditScreen(item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _deleteItem(item),
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
                          setState(() => item['enabled'] = val);
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
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.shopping_bag_outlined), text: 'Products'),
            Tab(icon: Icon(Icons.folder_open), text: 'Resources'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          products.isEmpty
              ? const Center(child: Text('No products uploaded yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 12, bottom: 16),
                  itemCount: products.length,
                  itemBuilder: (ctx, i) => _buildCard(products[i]),
                ),
          resources.isEmpty
              ? const Center(child: Text('No resources uploaded yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 12, bottom: 16),
                  itemCount: resources.length,
                  itemBuilder: (ctx, i) => _buildCard(resources[i]),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final newId = DateTime.now().millisecondsSinceEpoch.toString();
          final newProduct = {
            'id': newId,
            'type': 'product',
            'name': 'New Product',
            'description': 'Edit to add real details.',
            'price': 0.0,
            'duration': '',
            'seller': widget.currentUserName, // automatically set
            'enabled': true,
          };
          setState(() => products.insert(0, newProduct));
          _openEditScreen(newProduct);
        },
        child: const Icon(Icons.add),
        tooltip: 'Add new product',
      ),
    );
  }
}

// ----------------------------
// Edit Upload Screen
// ----------------------------
class EditUploadScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final String currentUserName;
  const EditUploadScreen({super.key, required this.item, required this.currentUserName});

  @override
  State<EditUploadScreen> createState() => _EditUploadScreenState();
}

class _EditUploadScreenState extends State<EditUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameC;
  late TextEditingController _descC;
  late TextEditingController _priceC;
  late TextEditingController _durationC;
  late bool _enabled;
  late List<String> _availableDays;
  late String _availableFrom;
  late String _availableTo;

  static const List<String> _weekdays = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
  bool get isProduct => widget.item['type'] == 'product';

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(text: widget.item['name'] ?? '');
    _descC = TextEditingController(text: widget.item['description'] ?? '');
    _priceC = TextEditingController(text: widget.item['price']?.toString() ?? '');
    _durationC = TextEditingController(text: widget.item['duration'] ?? '');
    _enabled = widget.item['enabled'] ?? true;
    _availableDays = List<String>.from(widget.item['availableDays'] ?? []);
    _availableFrom = widget.item['availableFrom'] ?? '';
    _availableTo = widget.item['availableTo'] ?? '';
  }

  @override
  void dispose() {
    _nameC.dispose();
    _descC.dispose();
    _priceC.dispose();
    _durationC.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final updated = Map<String, dynamic>.from(widget.item);
    updated['name'] = _nameC.text.trim();
    updated['description'] = _descC.text.trim();
    updated['duration'] = _durationC.text.trim();
    updated['enabled'] = _enabled;

    if (isProduct) {
      updated['price'] = double.tryParse(_priceC.text.trim()) ?? 0.0;
      updated['seller'] = widget.currentUserName;
    } else {
      updated['availableDays'] = List<String>.from(_availableDays);
      updated['availableFrom'] = _availableFrom;
      updated['availableTo'] = _availableTo;
      updated['author'] = widget.currentUserName;
    }

    Navigator.of(context).pop(updated);
  }

  void _delete() => Navigator.of(context).pop({'_action': 'delete'});

  void _toggleDay(String day) {
    setState(() {
      if (_availableDays.contains(day)) _availableDays.remove(day);
      else _availableDays.add(day);
    });
  }

  Future<void> _pickTime({required bool isFrom}) async {
    final result = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (result != null) {
      setState(() {
        if (isFrom) _availableFrom = result.format(context);
        else _availableTo = result.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isProduct ? 'Edit Product' : 'Edit Resource'),
        actions: [
          IconButton(onPressed: _delete, icon: const Icon(Icons.delete_outline, color: Colors.red)),
          IconButton(onPressed: _save, icon: const Icon(Icons.check)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameC,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descC,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              if (isProduct)
                TextFormField(
                  controller: _priceC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              if (isProduct) const SizedBox(height: 12),
              TextFormField(
                controller: _durationC,
                decoration: const InputDecoration(labelText: 'Duration'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(labelText: isProduct ? 'Seller' : 'Author'),
                initialValue: widget.currentUserName,
                readOnly: true,
              ),
              const SizedBox(height: 12),
              if (!isProduct)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Available Days'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _weekdays.map((d) {
                        final selected = _availableDays.contains(d);
                        return FilterChip(
                          selected: selected,
                          onSelected: (_) => _toggleDay(d),
                          label: Text(d, style: TextStyle(color: selected ? kPrimaryTeal : null)),
                          selectedColor: kPrimaryTeal.withOpacity(0.18),
                          checkmarkColor: kPrimaryTeal,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickTime(isFrom: true),
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'From'),
                              child: Text(_availableFrom.isEmpty ? 'Select' : _availableFrom),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickTime(isFrom: false),
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'To'),
                              child: Text(_availableTo.isEmpty ? 'Select' : _availableTo),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Enabled'),
                        Switch(
                          value: _enabled,
                          activeColor: kPrimaryTeal,
                          onChanged: (val) => setState(() => _enabled = val),
                        ),
                      ],
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
