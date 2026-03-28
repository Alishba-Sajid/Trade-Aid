import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'product_upload.dart';
import 'resource_uploads.dart';

const LinearGradient appGradient = LinearGradient(
  colors: [
    Color.fromARGB(255, 15, 119, 124),
    Color.fromARGB(255, 17, 158, 144),
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

const Color kPrimaryTeal = Color(0xFF004D40);

class ManageUploadsScreen extends StatefulWidget {
  final String currentUserName;

  const ManageUploadsScreen({
    super.key,
    required this.currentUserName,
  });

  @override
  State<ManageUploadsScreen> createState() => _ManageUploadsScreenState();
}

class _ManageUploadsScreenState extends State<ManageUploadsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> resources = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _fetchProducts();
      await _fetchResources();
    } catch (e) {
      print("Load error: $e");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ---------------- FETCH PRODUCTS ----------------

  Future<void> _fetchProducts() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('products')
        .select()
        .eq('user_id', user.id)
        .eq('status', 'available') 
        .order('created_at', ascending: false);
        
 if (mounted) {
      setState(() {
        products = response.map((item) {
          return {
            ...item,
            'name': item['title'],
            'image': (item['images'] as List?)?.isNotEmpty == true
                ? item['images'][0]
                : null,
          };
        }).toList();
      });
    }
  } catch (e) {
    print("Product fetch error: $e");
  }
}
  // ---------------- FETCH RESOURCES ----------------

  Future<void> _fetchResources() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('resources')
    .select()
    .eq('user_id', user.id)
    .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          resources = response.map((item) {
            TimeOfDay? parseTime(String? t) {
              if (t == null) return null;
              final parts = t.split(':');
              if (parts.length != 2) return null;
              final hour = int.tryParse(parts[0]);
              final minute = int.tryParse(parts[1]);
              if (hour == null || minute == null) return null;
              return TimeOfDay(hour: hour, minute: minute);
            }

            return {
              ...item,
              'title': item['name'],
              'startTime': parseTime(item['start_time']),
              'endTime': parseTime(item['end_time']),
              'pricePerHour': item['rate'],
              'availableDays': item['available_days'],
              'image': (item['images'] as List?)?.isNotEmpty == true
                  ? item['images'][0]
                  : null,
              'enabled': item['is_enabled'] ?? true,
            };
          }).toList();
        });
      }
    } catch (e) {
      print("Resource fetch error: $e");
    }
  }

  // ---------------- UPDATE & DELETE ----------------

  Future<void> _updateProduct(Map<String, dynamic> updatedProduct) async {
    try {
      await supabase
          .from('products')
          .update({
            'title': updatedProduct['name'],
            'description': updatedProduct['description'],
            'price': updatedProduct['price'],
            'condition': updatedProduct['condition'],
            'used_time': updatedProduct['usedTime'],
            'images': updatedProduct['images'],
          })
          .eq('id', updatedProduct['id']);
      await _fetchProducts();
    } catch (e) {
      print("Update product error: $e");
    }
  }

  Future<void> _deleteProduct(String id) async {
    try {
      await supabase.from('products').delete().eq('id', id);

      await _fetchProducts();
    } catch (e) {
      print("Delete product error: $e");
    }
  }

  Future<void> _updateResource(Map<String, dynamic> updatedResource) async {
    try {
      String? timeToString(TimeOfDay? t) =>
          t != null ? t.hour.toString().padLeft(2, '0') + ':' + t.minute.toString().padLeft(2, '0') : null;

      await supabase
          .from('resources')
          .update({
            'name': updatedResource['title'],
            'description': updatedResource['description'],
            'rate': updatedResource['pricePerHour'],
            'available_days': updatedResource['availableDays'],
            'start_time': timeToString(updatedResource['startTime']),
            'end_time': timeToString(updatedResource['endTime']),
            'images': updatedResource['images'],
            'is_enabled': updatedResource['enabled'],
          })
          .eq('id', updatedResource['id']);

      await _fetchResources();
    } catch (e) {
      print("Update resource error: $e");
    }
  }

  Future<void> _deleteResource(String id) async {
    try {
      await supabase.from('resources').delete().eq('id', id);
      await _fetchResources();
    } catch (e) {
      print("Delete resource error: $e");
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: const BoxDecoration(gradient: appGradient),
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
                      'Manage My Uploads',
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
          TabBar(
            controller: _tabController,
            labelColor: kPrimaryTeal,
            unselectedLabelColor: Colors.grey,
            indicatorColor: kPrimaryTeal,
            tabs: const [
              Tab(icon: Icon(Icons.shopping_bag_outlined), text: 'Products'),
              Tab(icon: Icon(Icons.folder_open), text: 'Resources'),
            ],
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      ProductUploadCard(
                        products: products,
                        currentUserName: widget.currentUserName,
                        onUpdate: _updateProduct,
                        onDelete: _deleteProduct,
                      ),
                      ResourceUploadCard(
                        resources: resources,
                        currentUserName: widget.currentUserName,
                        onUpdate: _updateResource,
                        onDelete: _deleteResource,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}