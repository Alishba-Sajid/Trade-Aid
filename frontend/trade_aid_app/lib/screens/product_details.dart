// lib/screens/product_details.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product.dart';
import 'payment_option.dart';
import 'chat/chat_screen.dart';
import '../widgets/app_bar.dart';

/* ===================== COLORS ===================== */
const Color dark = Color(0xFF0B2F2A);
const Color light = Color(0xFFF4FAF9);
const Color accent = Color(0xFF119E90);
const Color surface = Color(0xFFFFFFFF);
const LinearGradient appGradient = LinearGradient(
  colors: [
    Color.fromARGB(255, 15, 119, 124),
    Color.fromARGB(255, 17, 158, 144),
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);
/* ===================== SELLER CARD ===================== */
class _SellerCard extends StatefulWidget {
  final Product product;
  const _SellerCard({required this.product});

  @override
  State<_SellerCard> createState() => _SellerCardState();
}

class _SellerCardState extends State<_SellerCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final sellerName = widget.product.sellerName ?? 'Community Member';
    final address =
        widget.product.sellerAddress ?? 'Sample Address Line, Gulberg Greens';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: accent.withOpacity(.12),
                child: const Icon(Icons.person, color: accent, size: 30),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sellerName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: dark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.verified,
                            color: accent, size: 15),
                        const SizedBox(width: 8),
                        Text(
                          'Verified Seller',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ChatScreen(sellerName: sellerName),
                  ),
                ),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: accent.withOpacity(.2),
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(Icons.chat_bubble_outline,
                      color: accent, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 20, color: accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isExpanded ? address : address.split(',').first,
                    maxLines: isExpanded ? 3 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedRotation(
                  turns: isExpanded ? .5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.expand_more,
                      color: Colors.black38, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== PRODUCT DETAILS ===================== */
class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: light,
      appBar: AppBarWidget(
        title: 'Product Details',
        onBack: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildImageSlider(product),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 24, 20, 130),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitlePrice(product),
                  const SizedBox(height: 18),
                  _sectionTitle('Description'),
                  const SizedBox(height: 3),
                  _buildDescription(product),
                  const SizedBox(height: 18),
                  _buildInfoGrid(product),
                  const SizedBox(height: 18),
                  _SellerCard(product: product),
                  const SizedBox(height: 18),
                  _buildTermsAndConditions(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomAction(context),
    );
  }

  /* ================= IMAGE SLIDER ================= */
  Widget _buildImageSlider(Product product) {
    return Stack(
      children: [
        Container(
          height: 380,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF119E90), Color(0xFF00BFA5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius:
                BorderRadius.vertical(bottom: Radius.circular(40)),
          ),
          child: PageView.builder(
            itemCount: product.images.length,
            onPageChanged: (i) =>
                setState(() => currentImageIndex = i),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () =>
                  _openZoomViewer(product.images, i),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(
                        bottom: Radius.circular(40)),
                child: Image.asset(
                  product.images[i],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              product.images.length,
              (i) => AnimatedContainer(
                duration:
                    const Duration(milliseconds: 300),
                margin:
                    const EdgeInsets.symmetric(horizontal: 5),
                width: currentImageIndex == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: currentImageIndex == i
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          top: 24,
          right: 20,
          child: GestureDetector(
            onTap: () => _openZoomViewer(
                product.images, currentImageIndex),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.zoom_out_map,
                  size: 20, color: dark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitlePrice(Product product) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            product.name,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: dark,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          "Rs ${product.price}",
          style: GoogleFonts.poppins(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: accent,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: dark,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildDescription(Product product) {
    return Text(
      product.description,
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: Colors.black54,
        height: 1.7,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildInfoGrid(Product product) {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            icon: Icons.history,
            label: 'Used For',
            value: product.usedTime ?? 'New',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _InfoCard(
            icon: Icons.check_circle_outline,
            label: 'Condition',
            value: product.condition ?? 'Available',
          ),
        ),
      ],
    );
  }
Widget _buildTermsAndConditions() {
  final terms = [
    "Posted by a community seller",
    "Price is fixed",
    "Verify product before payment",
    "Platform not liable post-payment",
    "Availability subject to seller",
  ];

  return Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: surface, // white block
      borderRadius: BorderRadius.circular(26),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading inside the same block
        Text(
          'Terms & Conditions',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: dark,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 14),

        // Terms list
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            terms.length,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index < terms.length - 1 ? 12 : 0),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: accent.withOpacity(0.85), size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      terms[index],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


Widget _buildBottomAction(BuildContext context) {
  return Container(
    padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
    decoration: BoxDecoration(
      color: surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 24,
          offset: const Offset(0, -8),
        ),
      ],
    ),
    child: Row(
      children: [
        // Add to Cart Button
        Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: accent.withOpacity(0.2),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            color: accent,
            iconSize: 22,
            onPressed: () {
           
            },
          ),
        ),
        const SizedBox(width: 14),
        // Buy Now Button with Gradient
        Expanded(
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              gradient: appGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 17, 158, 144).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PaymentSelectionScreen(),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Buy Now',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


  void _openZoomViewer(List<String> images, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _ZoomImageViewer(images: images, initialIndex: index),
      ),
    );
  }
}

/* ================= INFO CARD ================= */
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard(
      {required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: accent),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black38,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value,
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: dark)),
            ],
          ),
        ],
      ),
    );
  }
}

/* ================= ZOOM VIEWER ================= */

class _ZoomImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _ZoomImageViewer(
      {required this.images, required this.initialIndex});

  @override
  State<_ZoomImageViewer> createState() =>
      _ZoomImageViewerState();
}

class _ZoomImageViewerState extends State<_ZoomImageViewer> {
  late final PageController _pageController;
  final TransformationController _controller = TransformationController();
  TapDownDetails? _doubleTapDetails;

  bool _showHint = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);

    // Hide hint after 2 seconds
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _showHint = false);
    });
  }

  void _handleDoubleTap() {
    final position = _doubleTapDetails!.localPosition;
    if (_controller.value != Matrix4.identity()) {
      _controller.value = Matrix4.identity();
    } else {
      _controller.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(3.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            itemBuilder: (_, index) => GestureDetector(
              onDoubleTapDown: (details) => _doubleTapDetails = details,
              onDoubleTap: _handleDoubleTap,
              child: InteractiveViewer(
                transformationController: _controller,
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Image.asset(
                    widget.images[index],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          if (_showHint)
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.search, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Pinch or double-tap to zoom',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
