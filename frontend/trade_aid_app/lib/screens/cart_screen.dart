import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cartItems = [
    {
      'name': 'Spacious Lawn',
      'price': 2000.0,
      'image': 'assets/lawn.jpg',
      'description': 'Lawn booking for 3 hours',
      'seller': 'Hania B.',
    },
    {
      'name': 'Washing Machine',
      'price': 300.0,
      'image': 'assets/washing_machine.jpg',
      'description': 'High efficiency hourly use',
      'seller': 'Ali K.',
    },
    {
      'name': 'Refrigerator',
      'price': 500.0,
      'image': 'assets/fridge.jpg',
      'description': 'Large capacity, party rental',
      'seller': 'Sara A.',
    },
  ];

  Set<int> selectedIndexes = {};

  bool get selectionMode => selectedIndexes.isNotEmpty;
  double get total =>
      selectedIndexes.fold(0, (sum, i) => sum + (cartItems[i]['price'] as double));

  static const Color primaryTeal = Color(0xFF004D40);
  static const Color lightTeal = Color(0xFFE0F2F1);
  static const Color accentTeal = Color(0xFF00796B);
  static const Color purpleTeal = Color(0xFFE8EAF6); // purplish background

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(selectionMode ? '${selectedIndexes.length} Selected' : 'My Cart'),
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        actions: selectionMode
            ? [
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => selectedIndexes.clear())),
              ]
            : null,
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty!'))
          : Column(children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final isSelected = selectedIndexes.contains(index);
                    return GestureDetector(
                      onLongPress: () =>
                          setState(() => selectedIndexes.add(index)),
                      onTap: () => setState(() {
                        if (selectionMode) {
                          if (isSelected) {
                            selectedIndexes.remove(index);
                          } else {
                            selectedIndexes.add(index);
                          }
                        }
                      }),
                      child: _buildCartItemCard(item, index, isSelected),
                    );
                  },
                ),
              ),
              _buildBottomBar(context),
            ]),
    );
  }

  Widget _buildCartItemCard(Map<String, dynamic> item, int index, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? lightTeal
            : selectionMode
                ? purpleTeal
                : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectionMode)
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 10),
              child: Checkbox(
                value: isSelected,
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      selectedIndexes.add(index);
                    } else {
                      selectedIndexes.remove(index);
                    }
                  });
                },
                activeColor: accentTeal,
                checkColor: Colors.white,
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item['image'],
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 70,
                height: 70,
                color: lightTeal,
                alignment: Alignment.center,
                child: const Icon(Icons.image, color: primaryTeal),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'],
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(item['description'],
                    style: const TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 8),
                Text('Provider: ${item['seller']}',
                    style:
                        const TextStyle(fontSize: 12, color: primaryTeal)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Rs ${item['price'].toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _removeItem(index),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    if (!selectionMode) {
      final totalAll = cartItems.fold(
          0.0, (sum, item) => sum + (item['price'] as double));
      return _checkoutBar(context, 'Subtotal', totalAll, true);
    }
    return _checkoutBar(context, 'Selected Total', total, false);
  }

  Widget _checkoutBar(
      BuildContext context, String label, double amt, bool fullCart) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: lightTeal, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label,
                style: const TextStyle(fontSize: 16, color: Colors.black87)),
            Text('Rs ${amt.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
          ]),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: amt > 0
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Proceeding with ${selectionMode ? selectedIndexes.length : 'all'} item(s)...')));
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                selectionMode ? 'Checkout Selected' : 'Proceed to Checkout',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _removeItem(int i) {
    setState(() => cartItems.removeAt(i));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Item removed')));
  }
}
