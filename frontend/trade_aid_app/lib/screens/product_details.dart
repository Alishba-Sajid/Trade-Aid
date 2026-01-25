// lib/screens/product_details.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product.dart';
import 'payment_option.dart';
import 'chat/chat_screen.dart'; // Your actual chat screen

/* ===================== COLORS & GRADIENT ===================== */

const LinearGradient appGradient = LinearGradient(
  colors: [Color(0xFF2E9499), Color(0xFF119E90)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const Color dark = Color(0xFF004D40);
const Color light = Color(0xFFF0F9F8);

/* ===================== PRODUCT DETAILS SCREEN ===================== */

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: light,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSlider(product),
                  const SizedBox(height: 16),
                  _buildTitlePrice(product),
                  const SizedBox(height: 10),
                  _buildDescription(product),
                  const SizedBox(height: 20),
                  _buildSpecs(product),
                  const SizedBox(height: 20),
                  _SellerCard(product: product),
                  const SizedBox(height: 20),
                  _buildBuyNowBar(product),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── APP BAR ─────────────
  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 100,
      decoration: const BoxDecoration(gradient: appGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Spacer(),
              Text(
                'Product Details',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────── IMAGE SLIDER ─────────────
  Widget _buildImageSlider(Product product) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: dark.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            SizedBox(
              height: 260,
              child: PageView.builder(
                itemCount: product.images.length,
                onPageChanged: (index) =>
                    setState(() => currentImageIndex = index),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _openZoomViewer(product.images, index),
                    child: Image.asset(
                      product.images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                },
              ),
            ),
            if (product.images.length > 1)
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    product.images.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: currentImageIndex == index ? 8 : 6,
                      height: currentImageIndex == index ? 8 : 6,
                      decoration: BoxDecoration(
                        color: currentImageIndex == index
                            ? appGradient.colors[1]
                            : Colors.white70,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ───────────── TITLE + PRICE ─────────────
  Widget _buildTitlePrice(Product product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            product.name,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: dark,
            ),
          ),
        ),
        Text(
          "Rs ${product.price}",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: appGradient.colors[1],
          ),
        ),
      ],
    );
  }

  // ───────────── DESCRIPTION ─────────────
  Widget _buildDescription(Product product) {
    return Text(
      product.description,
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: Colors.black54,
        height: 1.5,
      ),
    );
  }

  // ───────────── SPECIFICATIONS ─────────────
  Widget _buildSpecs(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Information',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _SpecTile('Condition', product.condition ?? 'N/A'),
        _SpecTile('Used', product.usedTime ?? 'N/A'),
        _SpecTile('Seller', product.sellerName ?? 'N/A'),
      ],
    );
  }

  // ───────────── BUY NOW BAR ─────────────
  Widget _buildBuyNowBar(Product product) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Added to Cart')));
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: dark.withOpacity(0.1)),
              ),
              child: const Icon(Icons.shopping_bag_outlined, color: dark),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PaymentSelectionScreen()),
            ),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: appGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'Buy Now',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ───────────── FULL SCREEN ZOOM ─────────────
  void _openZoomViewer(List<String> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _ZoomImageViewer(images: images, initialIndex: initialIndex),
      ),
    );
  }
}

/* ===================== SPEC TILE ===================== */
class _SpecTile extends StatelessWidget {
  final String title;
  final String value;

  const _SpecTile(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          Text(value, style: GoogleFonts.poppins(color: Colors.black54)),
        ],
      ),
    );
  }
}

/* ===================== ZOOM VIEWER ===================== */
class _ZoomImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _ZoomImageViewer({required this.images, required this.initialIndex});

  @override
  State<_ZoomImageViewer> createState() => _ZoomImageViewerState();
}

class _ZoomImageViewerState extends State<_ZoomImageViewer> {
  late final PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: controller,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(child: Image.asset(widget.images[index])),
          );
        },
      ),
    );
  }
}

/* ===================== CHAT BUTTON ===================== */
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
        child: const Icon(
          Icons.chat_bubble_outline_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

/* ===================== SELLER CARD ===================== */
class _SellerCard extends StatefulWidget {
  final Product product;

  const _SellerCard({required this.product});

  @override
  State<_SellerCard> createState() => _SellerCardState();
}

class _SellerCardState extends State<_SellerCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late final AnimationController _controller;
  late final Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _arrowAnimation = Tween<double>(begin: 0, end: 0.5).animate(_controller);
  }

  void _toggleExpand() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sellerName = widget.product.sellerName ?? 'Seller';
    final address = widget.product.sellerAddress ?? 'House 123, Sample Street';

    return Container(
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
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: light,
                backgroundImage: AssetImage('assets/seller.jpg'),
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
                      address.split(',').first,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              _ChatButton(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(sellerName: sellerName),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _toggleExpand,
                child: RotationTransition(
                  turns: _arrowAnimation,
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.black54,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Full Address: $address',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),

                  const SizedBox(height: 8),
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
