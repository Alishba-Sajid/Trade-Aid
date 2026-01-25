// lib/screens/resource_details.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/resource.dart';

/* ===================== COLORS & GRADIENT ===================== */

const LinearGradient appGradient = LinearGradient(
  colors: [Color(0xFF0F777C), Color(0xFF119E90)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const Color dark = Color(0xFF004D40);
const Color light = Color(0xFFF0F9F8);

/* ===================== SCREEN ===================== */

class ResourceDetailsScreen extends StatelessWidget {
  final Resource resource;
  const ResourceDetailsScreen({super.key, required this.resource});

  /* ---------- Full Screen Image Viewer ---------- */
  void _openFullScreenImage(BuildContext context, String path, String heroTag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
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

  /* ---------- Custom Gradient AppBar ---------- */
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Container(
        decoration: const BoxDecoration(gradient: appGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Text(
                  'Resource Details',
                  style: GoogleFonts.poppins(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    // Safe reader
    String safeString(dynamic Function() getter) {
      try {
        final v = getter();
        return (v == null || v.toString().isEmpty) ? 'N/A' : v.toString();
      } catch (_) {
        return 'N/A';
      }
    }

    /* ---------- Images (min 1, max 3) ---------- */
    List<String> images = [];
    try {
      final dynamic res = resource;
      if (res.images != null && res.images is List) {
        images = List<String>.from(res.images);
      } else if (res.image != null) {
        images = [res.image.toString()];
      }
    } catch (_) {
      images = ['assets/images/placeholder.png'];
    }

    if (images.length > 3) images = images.sublist(0, 3);
    if (images.isEmpty) images = ['assets/images/placeholder.png'];

    /* ---------- Data ---------- */
    final name = safeString(() => resource.name);
    final description = safeString(() => resource.description);
    final priceText = 'Rs ${resource.pricePerHour.toStringAsFixed(0)}/h';
    final days = resource.availableDays.join(', ');
    final time = safeString(() => resource.availableTime);

    final ownerName = safeString(() => resource.ownerName);
    final ownerAddressFull = safeString(() => resource.ownerAddress);
    final addressParts = ownerAddressFull.split(',');
    final houseNumber = addressParts.isNotEmpty
        ? addressParts[0].trim()
        : 'N/A';
    final addressRest = addressParts.length > 1
        ? addressParts.sublist(1).join(',').trim()
        : ownerAddressFull;

    /* ---------- Bottom Bar Spacing ---------- */
    const double bottomBarHeight = 90;
    final double deviceInset = MediaQuery.of(context).padding.bottom;
    final double scrollReserve = bottomBarHeight + deviceInset + 20;

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF8FBFB),
      appBar: _buildAppBar(context),

      /* ===================== BODY ===================== */
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, scrollReserve),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageGallery(context, images),
            const SizedBox(height: 28),

            /// Name + Price
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
              ),
            ),

            const SizedBox(height: 24),
            const Divider(thickness: 1.2),
            const SizedBox(height: 24),

            /// Availability
            Row(
              children: [
                Expanded(
                  child: _SpecTile(
                    label: 'Available Days',
                    value: days,
                    icon: Icons.calendar_today_outlined,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _SpecTile(
                    label: 'Available Time',
                    value: time,
                    icon: Icons.access_time,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Provider Card
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
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage('assets/images/seller.jpg'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ownerName,
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
                  _ChatButton(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Starting chat with $ownerName'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      /* ===================== BOTTOM BAR ===================== */
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

              /// Price
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.4),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    priceText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: dark,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              /// Add to Cart
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${resource.name} added to cart')),
                  );
                },
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

              /// Book Now
              Expanded(
                flex: 2,
                child: InkWell(
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
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: appGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Book Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
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

  /* ===================== IMAGE GALLERY ===================== */

  Widget _buildImageGallery(BuildContext context, List<String> images) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _ImageCard(
              path: images[0],
              heroTag: 'res_img_0',
              onTap: () =>
                  _openFullScreenImage(context, images[0], 'res_img_0'),
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
                      heroTag: 'res_img_1',
                      onTap: () =>
                          _openFullScreenImage(context, images[1], 'res_img_1'),
                    ),
                  ),
                  if (images.length > 2) ...[
                    const SizedBox(height: 12),
                    Expanded(
                      child: _ImageCard(
                        path: images[2],
                        heroTag: 'res_img_2',
                        onTap: () => _openFullScreenImage(
                          context,
                          images[2],
                          'res_img_2',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/* ===================== HELPER WIDGETS ===================== */

class _ImageCard extends StatelessWidget {
  final String path;
  final String heroTag;
  final VoidCallback onTap;

  const _ImageCard({
    required this.path,
    required this.heroTag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: heroTag,
        child: Container(
          decoration: BoxDecoration(
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
              errorBuilder: (_, __, ___) =>
                  const Center(child: Icon(Icons.broken_image)),
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

  const _SpecTile({
    required this.label,
    required this.value,
    required this.icon,
  });

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
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.black.withOpacity(0.4),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: dark,
            ),
          ),
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
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }
}
