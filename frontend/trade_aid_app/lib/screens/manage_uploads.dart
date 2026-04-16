import 'package:flutter/material.dart';

// 🌿 Teal color palette
const Color kPrimaryTeal = Color(0xFF004D40);
const Color kLightTeal = Color(0xFF70B2B2);
const Color kSkyBlue = Color(0xFF9ECFD4);
const Color kPaleYellow = Color(0xFFE5E9C5);

void main() {
  runApp(const ManageUploadApp());
}

class ManageUploadApp extends StatelessWidget {
  const ManageUploadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manage Uploads',
      theme: ThemeData(
        primaryColor: kPrimaryTeal,
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryTeal),
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryTeal,
          foregroundColor: Colors.white,
        ),
      ),
      home: const ManageUploadsScreen(currentUserName: 'Hania B.'),
    );
  }
}

class ManageUploadsScreen extends StatefulWidget {
  final String currentUserName;
  const ManageUploadsScreen({super.key, required this.currentUserName});

  @override
  State<ManageUploadsScreen> createState() => _ManageUploadsScreenState();
}

class _ManageUploadsScreenState extends State<ManageUploadsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> products = [];
  final List<Map<String, dynamic>> resources = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _openEdit(Map<String, dynamic> item) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditUploadScreen(
          item: Map.from(item),
          currentUserName: widget.currentUserName,
        ),
      ),
    );

    if (result == null) return;

    if (result['_action'] == 'delete') {
      setState(() {
        (item['type'] == 'product' ? products : resources).removeWhere(
          (e) => e['id'] == item['id'],
        );
      });
    } else {
      setState(() {
        final list = item['type'] == 'product' ? products : resources;
        final i = list.indexWhere((e) => e['id'] == item['id']);
        if (i != -1) list[i] = result;
      });
    }
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final isProduct = item['type'] == 'product';

    return Card(
      margin: const EdgeInsets.all(12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kPrimaryTeal,
          child: Icon(
            isProduct ? Icons.shopping_bag : Icons.menu_book,
            color: Colors.white,
          ),
        ),
        title: Text(item['name']),
        subtitle: Text(item['description']),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: kPrimaryTeal),
          onPressed: () => _openEdit(item),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Uploads'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Products'),
            Tab(text: 'Resources'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView(children: products.map(_buildCard).toList()),
          ListView(children: resources.map(_buildCard).toList()),
        ],
      ),
    );
  }
}

// ======================================================
// EDIT SCREEN
// ======================================================

class EditUploadScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final String currentUserName;

  const EditUploadScreen({
    super.key,
    required this.item,
    required this.currentUserName,
  });

  @override
  State<EditUploadScreen> createState() => _EditUploadScreenState();
}

class _EditUploadScreenState extends State<EditUploadScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameC;
  late TextEditingController _descC;
  late TextEditingController _priceC;
  late TextEditingController _durationC;

  bool _enabled = true;
  List<String> _availableDays = [];
  String _availableFrom = '';
  String _availableTo = '';

  bool get isProduct => widget.item['type'] == 'product';

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(text: widget.item['name'] ?? '');
    _descC = TextEditingController(text: widget.item['description'] ?? '');
    _priceC = TextEditingController(
      text: widget.item['price']?.toString() ?? '',
    );
    _durationC = TextEditingController(text: widget.item['duration'] ?? '');

    _enabled = widget.item['enabled'] ?? true;
    _availableDays = List<String>.from(widget.item['availableDays'] ?? []);
    _availableFrom = widget.item['availableFrom'] ?? '';
    _availableTo = widget.item['availableTo'] ?? '';
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final updated = Map<String, dynamic>.from(widget.item)
      ..addAll({
        'name': _nameC.text,
        'description': _descC.text,
        'duration': _durationC.text,
        'enabled': _enabled,
      });

    if (isProduct) {
      updated['price'] = double.tryParse(_priceC.text) ?? 0;
      updated['seller'] = widget.currentUserName;
    } else {
      updated['author'] = widget.currentUserName;
      updated['availableDays'] = _availableDays;
      updated['availableFrom'] = _availableFrom;
      updated['availableTo'] = _availableTo;
    }

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isProduct ? 'Edit Product' : 'Edit Resource'),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _save)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameC,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descC,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              if (isProduct) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceC,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
