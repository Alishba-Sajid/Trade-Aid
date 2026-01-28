// lib/screens/resource_details.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/resource.dart';
import '../widgets/app_bar.dart';

/* ===================== RESOURCE DETAILS SCREEN ===================== */
class ResourceDetailsScreen extends StatefulWidget {
  final Resource resource;
  const ResourceDetailsScreen({super.key, required this.resource});

  @override
  State<ResourceDetailsScreen> createState() => _ResourceDetailsScreenState();
}

class _ResourceDetailsScreenState extends State<ResourceDetailsScreen> {
  int currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final resource = widget.resource;

    String safe(String? value, [String defaultValue = 'N/A']) =>
        (value == null || value.isEmpty) ? defaultValue : value;

    final images = resource.images.isNotEmpty ? resource.images.take(3).toList() : ['assets/placeholder.png'];

    final String name = safe(resource.name);
    final String description = safe(resource.description);
    final String priceText = 'Rs ${resource.pricePerHour.toStringAsFixed(0)}/h';
    final String availableTime = safe(resource.availableTime, '09:00 AM - 05:00 PM');
    final String availability = resource.availableDays.isNotEmpty ? resource.availableDays.join(', ') : 'Mon - Fri';
    final String ownerName = safe(resource.ownerName);
    final String ownerAddressFull = safe(resource.ownerAddress, 'Sample Address Line');

    return Scaffold(
      backgroundColor: light,
      appBar: AppBarWidget(
        title: 'Resource Details',
        onBack: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildImageSlider(images),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 130),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitlePrice(name, priceText),
                  const SizedBox(height: 18),
                  _sectionTitle('Description'),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.7,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildInfoGrid(availableTime, availability),
                  const SizedBox(height: 18),
                  _SellerCard(
                    ownerName: ownerName,
                    address: ownerAddressFull,
                  ),
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
  Widget _buildImageSlider(List<String> images) {
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
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
          ),
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (i) => setState(() => currentImageIndex = i),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => _openZoomViewer(images, i),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                child: Image.asset(
                  images[i],
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
              images.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 5),
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
            onTap: () => _openZoomViewer(images, currentImageIndex),
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
              child: const Icon(Icons.zoom_out_map, size: 20, color: dark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitlePrice(String name, String priceText) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            name,
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
          priceText,
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

Widget _buildInfoGrid(String availableTime, String availability) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start, // align cards at top
    children: [
      Expanded(
        child: _InfoCard(
          icon: Icons.access_time,
          label: 'Time',
          value: availableTime,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _InfoCard(
          icon: Icons.calendar_today,
          label: 'Availability',
          value: availability,
        ),
      ),
    ],
  );
}


  Widget _buildTermsAndConditions() {
    final terms = [
      "Resource booked as per availability",
      "Price is fixed",
      "Verify resource before booking",
      "Platform not liable post-booking",
      "Availability subject to provider",
    ];

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: surface,
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
    final resource = widget.resource;

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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${resource.name} added to cart')),
                );
              },
            ),
          ),
          const SizedBox(width: 14),
          // Book Now Button with Gradient
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
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/booking',
                      arguments: {
                        'resourceId': resource.id,
                        'resourceName': resource.name,
                      },
                    );
                  },
                  child: Center(
                    child: Text(
                      'Book Now',
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
        builder: (_) => _ZoomImageViewer(images: images, initialIndex: index),
      ),
    );
  }
}

/* ===================== SELLER CARD ===================== */
class _SellerCard extends StatefulWidget {
  final String ownerName;
  final String address;
  const _SellerCard({required this.ownerName, required this.address});

  @override
  State<_SellerCard> createState() => _SellerCardState();
}

class _SellerCardState extends State<_SellerCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
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
                      widget.ownerName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: dark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.verified, color: accent, size: 15),
                        const SizedBox(width: 8),
                        Text(
                          'Verified Provider',
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
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Chat with ${widget.ownerName}')),
                  );
                },
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
                  child: const Icon(Icons.chat_bubble_outline, color: accent, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 20, color: accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isExpanded ? widget.address : widget.address.split(',').first,
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
                  child: const Icon(Icons.expand_more, color: Colors.black38, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== INFO CARD ===================== */
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({required this.icon, required this.label, required this.value});
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
        crossAxisAlignment: CrossAxisAlignment.start, // top align icon + text
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black38,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: dark,
                  ),
                  softWrap: true, // allow text to wrap
                ),
              ],
            ),
          ),
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
  late final PageController _pageController;
  final TransformationController _controller = TransformationController();
  TapDownDetails? _doubleTapDetails;
  bool _showHint = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);

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
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
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
                  child: Image.asset(widget.images[index], fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          if (_showHint)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
                      'Pinch to zoom',
                      style: TextStyle(color: Colors.white, fontSize: 14),
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