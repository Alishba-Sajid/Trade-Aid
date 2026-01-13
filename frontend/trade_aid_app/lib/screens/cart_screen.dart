import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // --- Updated  Palette ---
  static const Color darkPrimary = Color(0xFF004D40);
  static const Color backgroundLight = Color(0xFFF8FAFA);
  static const Color accentTeal = Color(0xFF119E90);
  static const Color subtleGrey = Color(0xFFF2F2F2);
  
  static const LinearGradient appGradient = LinearGradient(
    colors: [Color(0xFF2E9499), Color(0xFF119E90)],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  List<Map<String, dynamic>> cartItems = [
    {'name': 'Spacious Lawn', 'price': 2000.0, 'image': 'assets/lawn.jpg', 'description': 'Lawn booking for 3 hours', 'seller': 'Hania B.'},
    {'name': 'Washing Machine', 'price': 300.0, 'image': 'assets/washing_machine.jpg', 'description': 'High efficiency hourly use', 'seller': 'Ali K.'},
    {'name': 'Refrigerator', 'price': 500.0, 'image': 'assets/fridge.jpg', 'description': 'Large capacity, party rental', 'seller': 'Sara A.'},
  ];

  Set<int> selectedIndexes = {};
  bool get selectionMode => selectedIndexes.isNotEmpty;
  
  double get currentTotal {
    if (selectionMode) {
      return selectedIndexes.fold(0, (sum, i) => sum + (cartItems[i]['price'] as double));
    }
    return cartItems.fold(0, (sum, item) => sum + (item['price'] as double));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildModernAppBar(),
          if (cartItems.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildPremiumCard(index),
                  childCount: cartItems.length,
                ),
              ),
            ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: cartItems.isEmpty ? null : _buildFloatingCheckout(),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: backgroundLight.withOpacity(0.8),
      elevation: 0,
      centerTitle: false,
      title: Text(
        selectionMode ? '${selectedIndexes.length} Selected' : 'My Cart',
        style: GoogleFonts.poppins(color: darkPrimary, fontWeight: FontWeight.w700, fontSize: 24),
      ),
      actions: [
        if (selectionMode)
          IconButton(
            icon: const Icon(Icons.deselect_outlined, color: accentTeal),
            onPressed: () => setState(() => selectedIndexes.clear()),
          ),
      ],
    );
  }

  Widget _buildPremiumCard(int index) {
    final item = cartItems[index];
    final isSelected = selectedIndexes.contains(index);

    return Dismissible(
      key: Key(item['name'] + index.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeItem(index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 25),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 30),
      ),
      child: GestureDetector(
        onLongPress: () => setState(() => selectedIndexes.add(index)),
        onTap: () {
          if (selectionMode) {
            setState(() => isSelected ? selectedIndexes.remove(index) : selectedIndexes.add(index));
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? accentTeal : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
            ],
          ),
          child: Row(
            children: [
              // Image container with selection overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 85,
                      height: 85,
                      color: subtleGrey,
                      child: Image.asset(item['image'], fit: BoxFit.cover, 
                        errorBuilder: (c, e, s) => const Icon(Icons.inventory_2_outlined, color: accentTeal)),
                    ),
                  ),
                  if (isSelected)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: darkPrimary.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: darkPrimary)),
                    Text(item['description'], style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]), maxLines: 1),
                    const SizedBox(height: 8),
                    Text('Rs ${item['price'].toStringAsFixed(0)}', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17, color: accentTeal)),
                  ],
                ),
              ),
              // Delete Button
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                onPressed: () => _removeItem(index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingCheckout() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: darkPrimary.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(selectionMode ? 'Selected Total' : 'Total Price', 
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
              Text('Rs ${currentTotal.toStringAsFixed(0)}', 
                style: GoogleFonts.poppins(fontSize: 20, color: darkPrimary, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: appGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: accentTeal.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  selectionMode ? 'Checkout (${selectedIndexes.length})' : 'Checkout',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(color: subtleGrey, shape: BoxShape.circle),
            child: const Icon(Icons.shopping_cart_outlined, size: 60, color: accentTeal),
          ),
          const SizedBox(height: 20),
          Text('Your cart is empty', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: darkPrimary)),
          Text('Items you add will appear here', style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }

  void _removeItem(int i) {
    setState(() {
      cartItems.removeAt(i);
      selectedIndexes.remove(i);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item removed from cart'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: darkPrimary,
      ),
    );
  }
}