import 'package:flutter/material.dart';
import 'product_upload.dart'; //ignore: unused_import
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

  List<Map<String, dynamic>> products = [
    {
      'id': 'p1',
      'name': 'Spacious Lawn',
      'description': 'Lawn booking for 3 hours',
      'price': 2000.0,
      'duration': '3 hours',
      'seller': 'Hania B.',
      'enabled': true,
    },
  ];

  List<Map<String, dynamic>> resources = [
    {
      'id': 'r1',
      'name': 'How to Host an Event',
      'description': 'A quick guide to hosting events',
      'enabled': true,
      'duration': '15 min',
      'author': 'Hania B.',
      'availableDays': ['Mon', 'Wed', 'Fri'],
      'availableFrom': '09:00',
      'availableTo': '17:00',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _updateProduct(Map<String, dynamic> updatedProduct) {
    final index = products.indexWhere((p) => p['id'] == updatedProduct['id']);
    if (index != -1) setState(() => products[index] = updatedProduct);
  }

  void _updateResource(Map<String, dynamic> updatedResource) {
    final index = resources.indexWhere((r) => r['id'] == updatedResource['id']);
    if (index != -1) setState(() => resources[index] = updatedResource);
  }

  void _deleteProduct(String id) {
    setState(() => products.removeWhere((p) => p['id'] == id));
  }

  void _deleteResource(String id) {
    setState(() => resources.removeWhere((r) => r['id'] == id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ================== Custom AppBar ==================
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(gradient: appGradient),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      'Manage My Uploads',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // Placeholder for spacing
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),

          // ================== Tabs ==================
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: kPrimaryTeal,
              unselectedLabelColor: Colors.grey,
              indicatorColor: kPrimaryTeal,
              tabs: const [
                Tab(
                  icon: Icon(Icons.shopping_bag_outlined),
                  text: 'Products',
                ),
                Tab(
                  icon: Icon(Icons.folder_open),
                  text: 'Resources',
                ),
              ],
            ),
          ),

          // ================== Tab Content ==================
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Products Tab
                Container(
                  color: Colors.white,
                  child: ProductUploadCard(
                    products: products,
                    currentUserName: widget.currentUserName,
                    onUpdate: _updateProduct,
                    onDelete: _deleteProduct,
                  ),
                ),

                // Resources Tab
                Container(
                  color: Colors.white,
                  child: ResourceUploadCard(
                    resources: resources,
                    currentUserName: widget.currentUserName,
                    onUpdate: _updateResource,
                    onDelete: _deleteResource,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
