// lib/screens/product_details.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Ensure this is in pubspec.yaml
import '../models/product.dart';
import 'payment_option.dart';

/* ===================== COLORS & GRADIENT ===================== */

const LinearGradient appGradient = LinearGradient(
  colors: [
    Color(0xFF0F777C),
    Color(0xFF119E90),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const Color dark = Color(0xFF004D40);
const Color light = Color(0xFFF0F9F8);
const Color surface = Colors.white;

/* ===================== SCREEN ===================== */

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  // Helper to open full screen image
  void _openFullScreenImage(BuildContext context, String path, String heroTag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: Hero(
              tag: heroTag,
              child: InteractiveViewer(
                child: Image.asset(path, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /* ---------- UPDATED CUSTOM APP BAR ---------- */
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100), // Height for the custom bar
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: appGradient,
          
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Text(
                  "Product Details",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 48), // Balancing spacer
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String safeString(dynamic Function() getter) {
      try {
        final v = getter();
        return (v == null || v.toString().isEmpty) ? 'N/A' : v.toString();
      } catch (_) {
        return 'N/A';
      }
    }

    List<String> images = [];
    try {
      final dynamic prod = product;
      if (prod.images != null && prod.images is List) {
        images = List<String>.from(prod.images);
      } else if (prod.image != null) {
        images = [prod.image.toString()];
      }
    } catch (_) {
      images = ['assets/images/placeholder.png'];
    }

    if (images.length > 3) images = images.sublist(0, 3);
    if (images.isEmpty) images = ['assets/images/placeholder.png'];

    final name = safeString(() => product.name);
    final description = safeString(() => product.description);
    final priceText = 'Rs ${product.price.toStringAsFixed(0)}';
    final condition = safeString(() => (product as dynamic).condition);
    final usedTime = safeString(() => (product as dynamic).usedTime);
    final sellerName = safeString(() => (product as dynamic).sellerName);
    final sellerAddressFull = safeString(() => (product as dynamic).sellerAddress);

    final addressParts = sellerAddressFull.split(',');
    final houseNumber = addressParts.isNotEmpty ? addressParts[0].trim() : 'N/A';
    final addressRest = addressParts.length > 1 ? addressParts.sublist(1).join(',').trim() : sellerAddressFull;

    const double bottomBarHeight = 90;
    final double deviceInset = MediaQuery.of(context).padding.bottom;
    final double scrollReserve = bottomBarHeight + deviceInset + 20;

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF8FBFB),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, 20, 20, scrollReserve),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageGallery(context, images),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: dark,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                Text(
                  priceText,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF119E90),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.black.withOpacity(0.6),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(height: 1, thickness: 1.2),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _SpecTile(
                    label: 'Condition',
                    value: condition,
                    icon: Icons.verified_outlined,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _SpecTile(
                    label: 'Usage Time',
                    value: usedTime,
                    icon: Icons.history_toggle_off_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: dark.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: light,
                    backgroundImage: AssetImage('assets/images/seller.jpg'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sellerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: dark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'House $houseNumber • $addressRest',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ChatButton(onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening chat with $sellerName...')),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 15),
          height: bottomBarHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: dark.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Price',
                      style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.w600)),
                  Text(priceText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: dark)),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Cart'))),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: light,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined, color: dark),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentSelectionScreen()));
                  },
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: appGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF119E90).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Buy Now',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery(BuildContext context, List<String> images) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _ImageCard(
              path: images[0],
              heroTag: 'img_0',
              onTap: () => _openFullScreenImage(context, images[0], 'img_0'),
            ),
          ),
          if (images.length > 1) ...[
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(
                    child: _ImageCard(
                      path: images[1],
                      heroTag: 'img_1',
                      onTap: () => _openFullScreenImage(context, images[1], 'img_1'),
                    ),
                  ),
                  if (images.length > 2) ...[
                    const SizedBox(height: 12),
                    Expanded(
                      child: _ImageCard(
                        path: images[2],
                        heroTag: 'img_2',
                        onTap: () => _openFullScreenImage(context, images[2], 'img_2'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}

/* ===================== HELPER COMPONENTS ===================== */

class _ImageCard extends StatelessWidget {
  final String path;
  final String heroTag;
  final VoidCallback onTap;
  const _ImageCard({required this.path, required this.heroTag, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: heroTag,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: dark.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              path,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpecTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _SpecTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: light.withOpacity(0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: dark.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: dark),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.4), fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: dark)),
        ],
      ),
    );
  }
}

class _ChatButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ChatButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          gradient: appGradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}