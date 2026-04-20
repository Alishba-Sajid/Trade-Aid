import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const LinearGradient appGradient = LinearGradient(
  colors: [
    Color.fromARGB(255, 15, 119, 124),
    Color.fromARGB(255, 17, 158, 144),
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

const Color kPrimaryTeal = Color(0xFF004D40);

class ManageReservationsScreen extends StatefulWidget {
  const ManageReservationsScreen({super.key});

  @override
  State<ManageReservationsScreen> createState() =>
      _ManageReservationsScreenState();
}

class _ManageReservationsScreenState extends State<ManageReservationsScreen>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  late TabController _tabController;

  List<Map<String, dynamic>> productBookings = [];
  List<Map<String, dynamic>> resourceBookings = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    await _fetchProductBookings();
    await _fetchResourceBookings();
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  // ================= FETCH LOGIC =================
  Future<void> _fetchProductBookings() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('transactions')
        .select('*, products(title, price, user_id, images)')
        .eq('buyer_id', user.id)
        .eq('status', 'pending');

    setState(() {
      productBookings = List<Map<String, dynamic>>.from(response);
    });
  }
Future<void> _fetchResourceBookings() async {
  final user = supabase.auth.currentUser;
  if (user == null) return;

  final response = await supabase
      .from('resource_bookings')
      .select('*, resources(name, rate, user_id, images)')
      .eq('user_id', user.id);

  final now = DateTime.now();

  final allBookings = List<Map<String, dynamic>>.from(response);

  final validBookings = allBookings.where((booking) {
    try {
      final date = DateTime.parse(booking['booking_date']);
      final startParts = booking['start_time'].toString().split(':');

      final bookingStart = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(startParts[0]),
        int.parse(startParts[1]),
      );

      // 🔥 FIX: allow same-day + timezone-safe comparison
      return bookingStart.isAfter(now.subtract(const Duration(minutes: 1)));
    } catch (_) {
      return false;
    }
  }).toList();

  if (!mounted) return;

  setState(() {
    resourceBookings = validBookings;
  });
}
  // ================= DELETE LOGIC =================
  Future<void> _deleteProductBooking(Map booking) async {
    final scheduledAt = DateTime.parse(booking['scheduled_at']);
    if (DateTime.now().isAfter(scheduledAt)) {
      _showErrorMessage("Cannot delete after scheduled time");
      return;
    }

    await supabase.from('transactions').delete().eq('id', booking['id']);
    await supabase
        .from('products')
        .update({'reserved_for': null, 'status': 'available'})
        .eq('id', booking['product_id']);

    _fetchProductBookings();
  }

  Future<void> _deleteResourceBooking(Map booking) async {
    final bookingDate = DateTime.parse(booking['booking_date']);
    final startParts = booking['start_time'].toString().split(':');
    final startDateTime = DateTime(
      bookingDate.year,
      bookingDate.month,
      bookingDate.day,
      int.parse(startParts[0]),
      int.parse(startParts[1]),
    );

    if (DateTime.now().isAfter(startDateTime)) {
      _showErrorMessage("Cannot delete after start time");
      return;
    }

    await supabase.from('resource_bookings').delete().eq('id', booking['id']);
    _fetchResourceBookings();
  }

  // 🔥 UPDATED: Animated Card with FULL RED BORDER
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            // Border is now applied to all sides
            border: Border.all(color: Colors.redAccent, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatTime(String time24) {
    final parts = time24.split(":");
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    final period = hour >= 12 ? "PM" : "AM";
    hour = hour % 12 == 0 ? 12 : hour % 12;
    return "$hour:${minute.toString().padLeft(2, '0')} $period";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Styled Header with Back Button
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
                      "Manage Reservations",
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

          // Styled TabBar
          TabBar(
            controller: _tabController,
            labelColor: kPrimaryTeal,
            unselectedLabelColor: Colors.grey,
            indicatorColor: kPrimaryTeal,
            tabs: const [
              Tab(icon: Icon(Icons.shopping_bag_outlined), text: "Products"),
              Tab(icon: Icon(Icons.folder_open), text: "Resources"),
            ],
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(isProduct: true),
                      _buildList(isProduct: false),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildList({required bool isProduct}) {
    final data = isProduct ? productBookings : resourceBookings;

    if (data.isEmpty) {
      return const Center(child: Text("No reservations found."));
    }

    return ListView.builder(
      itemCount: data.length,
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      itemBuilder: (context, index) {
        final item = data[index];
        return isProduct ? _productCard(item) : _resourceCard(item);
      },
    );
  }

  Widget _productCard(Map item) {
    final product = item['products'];
    final imageUrl = (product['images'] as List?)?.isNotEmpty == true
        ? product['images'][0]
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageUrl != null
              ? Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image),
                ),
        ),
        title: Text(
          product['title'] ?? 'Unknown Product',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Price: ${product['price']}"),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _deleteProductBooking(item),
        ),
      ),
    );
  }

  Widget _resourceCard(Map item) {
    final resource = item['resources'];
    final imageUrl = (resource['images'] as List?)?.isNotEmpty == true
        ? resource['images'][0]
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageUrl != null
              ? Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.business),
                ),
        ),
        title: Text(
          resource['name'] ?? 'Unknown Resource',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("Date: ${item['booking_date']}"),
            Text(
              "${formatTime(item['start_time'])} - ${formatTime(item['end_time'])}",
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _deleteResourceBooking(item),
        ),
      ),
    );
  }
}
