import 'package:flutter/material.dart';
import 'edit_product.dart';

// --- Updated Palette Integration ---
const Color kDarkPrimary = Color(0xFF004D40);
const Color kBackgroundLight = Color(0xFFF8FAFA);
const Color kAccentTeal = Color(0xFF119E90);
const Color kSubtleGrey = Color(0xFFF2F2F2);

const LinearGradient kAppGradient = LinearGradient(
  colors: [
    Color.fromARGB(255, 15, 119, 124),
    Color.fromARGB(255, 17, 158, 144),
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

class ProductUploadCard extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final String currentUserName;
  final Function(Map<String, dynamic>) onUpdate;
  final Function(String) onDelete;

  const ProductUploadCard({
    super.key,
    required this.products,
    required this.currentUserName,
    required this.onUpdate,
    required this.onDelete,
  });

  void _openEditScreen(BuildContext context, Map<String, dynamic> product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditUploadProductScreen(
          product: Map.from(product),
        ),
      ),
    );

    if (result != null) {
      if (result['_action'] == 'delete') {
        onDelete(product['id']);
      } else {
        onUpdate(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Container(
        color: kBackgroundLight,
        child: const Center(
          child: Text(
            'No products uploaded yet.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      color: kBackgroundLight,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        itemCount: products.length,
        itemBuilder: (ctx, i) {
          final item = products[i];

          return Card(
            color: Colors.white,
            elevation: 1,
            shadowColor: kDarkPrimary.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: kSubtleGrey, width: 1),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // --- IMAGE SECTION ---
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kSubtleGrey),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.network(
                        item['image'] ?? '', 
                        fit: BoxFit.cover,
                        // Professional error handling for missing/broken links
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: kSubtleGrey,
                          child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                        ),
                        // Loading placeholder
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: kSubtleGrey,
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: kAccentTeal),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // --- TEXT INFO SECTION ---
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] ?? 'Unnamed Product',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kDarkPrimary,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rs ${item['price']}',
                          style: const TextStyle(
                            color: kAccentTeal,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- ACTIONS SECTION ---
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CompactActionButton(
                        icon: Icons.edit_outlined,
                        color: kAccentTeal,
                        onTap: () => _openEditScreen(context, item),
                      ),
                      const SizedBox(width: 8),
                      _CompactActionButton(
                        icon: Icons.delete_outline,
                        color: Colors.redAccent,
                        onTap: () => onDelete(item['id']),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CompactActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CompactActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}