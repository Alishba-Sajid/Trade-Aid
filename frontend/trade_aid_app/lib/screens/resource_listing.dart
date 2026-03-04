import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/resource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 🌿 Premium Color Constants
const LinearGradient appGradient = LinearGradient(
  colors: [
    Color.fromARGB(255, 15, 119, 124),
    Color.fromARGB(255, 17, 158, 144),
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

const Color dark = Color(0xFF004D40);
const Color light = Color(0xFFF0F9F8);
const Color accent = Color(0xFF119E90);

class ResourceListingScreen extends StatefulWidget {
  final String communityId;

  const ResourceListingScreen({
    super.key,
    required this.communityId,
  });

  @override
  State<ResourceListingScreen> createState() => _ResourceListingScreenState();
}
class _ResourceListingScreenState extends State<ResourceListingScreen> {
  String searchQuery = '';
  List<Resource> resources = [];
  bool isLoading = true;

  // ✅ Add your toggleResource method here
  Future<void> toggleResource(String resourceId, bool enable) async {
    final supabase = Supabase.instance.client;
    await supabase
        .from('resources')
        .update({'is_enabled': enable})
        .eq('id', resourceId);
    _fetchResources(); // refresh the list
  }

  List<Resource> get filteredResources {
    if (searchQuery.trim().isEmpty) return resources;
    final q = searchQuery.toLowerCase();
    return resources.where((r) {
      return r.name.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q) ||
          r.ownerName.toLowerCase().contains(q) ||
          r.ownerAddress.toLowerCase().contains(q);
    }).toList();
  }
  Future<void> _fetchResources() async {
    setState(() => isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // 1️⃣ Fetch resources for this community
      final resourceResponse = await supabase
          .from('resources')
          .select()
          .eq('community_id', widget.communityId)
          .eq('is_enabled', true);

      final resourceList = resourceResponse as List;

      if (resourceList.isEmpty) {
        setState(() {
          resources = [];
          isLoading = false;
        });
        return;
      }

      // 2️⃣ Extract unique user IDs
      final userIds = resourceList
          .map((r) => r['user_id'])
          .where((id) => id != null)
          .map((id) => id.toString())
          .toSet()
          .toList();

      // 3️⃣ Fetch profiles for those users
      final profileResponse = await supabase
          .from('profiles')
          .select('user_id, full_name, address')
          .inFilter('user_id', userIds);

      final profileList = profileResponse as List;

      // 4️⃣ Create profile lookup map
      final profileMap = {
        for (var p in profileList) p['user_id'].toString(): p
      };

      // 5️⃣ Merge resources with profile data
      final List<Resource> fetched = resourceList.map((json) {
        final map = json as Map<String, dynamic>;

        final profile = profileMap[map['user_id']?.toString()];

        return Resource.fromJson(map, profile);
      }).toList();

      setState(() {
        resources = fetched;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("RESOURCE ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchResources();
  }

  @override
  Widget build(BuildContext context) {
    final items = filteredResources;

    return Scaffold(
      backgroundColor: light,
      body: Column(
        children: [
          _buildPremiumAppBar(context),
          Container(
            color: light,
            padding: const EdgeInsets.all(16),
            child: _buildSearchBar(),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: accent))
                : items.isEmpty
                    ? _buildNoResourcesFound()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final r = items[index];
                          return _buildPremiumResourceCard(context, r);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // 🔹 App Bar
  Widget _buildPremiumAppBar(BuildContext context) {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        gradient: appGradient,
      ),
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
              Text(
                "Resources",
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
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (v) => setState(() => searchQuery = v),
      decoration: InputDecoration(
        hintText: 'Search resources',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ⭐ Resource Card with Image Slider
  Widget _buildPremiumResourceCard(BuildContext context, Resource r) {
    int currentImageIndex = 0;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/resource_details',
          arguments: {'resource': r},
        );
      },
      child: StatefulBuilder(
        builder: (context, setState) {
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: dark.withOpacity(0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGE SLIDER
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(
                      color: accent.withOpacity(0.2),
                      width: 1.2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 220,
                          width: double.infinity,
                          child: PageView.builder(
                            itemCount: r.images.length,
                            onPageChanged: (index) {
                              setState(() {
                                currentImageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Image.network(
                                r.images[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(Icons.broken_image,
                                        size: 40, color: Colors.grey),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        if (r.images.length > 1)
                          Positioned(
                            bottom: 8,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                r.images.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 3),
                                  width: currentImageIndex == index ? 8 : 6,
                                  height: currentImageIndex == index ? 8 : 6,
                                  decoration: BoxDecoration(
                                    color: currentImageIndex == index
                                        ? accent
                                        : Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // NAME & PRICE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        r.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: dark,
                        ),
                      ),
                    ),
                    Text(
                      'Rs ${r.pricePerHour.toStringAsFixed(0)}/h',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // DESCRIPTION
                Text(
                  r.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                ),

                const SizedBox(height: 10),

                _infoRow(
                    Icons.calendar_today, "Days", r.availableDays.join(', ')),
                _infoRow(Icons.access_time, "Time", r.availableTime),
                _infoRow(Icons.person_outline, "Owner", r.ownerName),

                const SizedBox(height: 12),

                // ACTION BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: appGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/booking',
                              arguments: {
                                'resourceId': r.id,
                                'resourceName': r.name
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Book",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        gradient: appGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${r.name} added to cart.')),
                          );
                        },
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 6),
          Text(
            "$label: ",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: dark,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResourcesFound() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: dark.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? "No resources available yet."
                  : "No resources found for \"$searchQuery\"",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: dark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}