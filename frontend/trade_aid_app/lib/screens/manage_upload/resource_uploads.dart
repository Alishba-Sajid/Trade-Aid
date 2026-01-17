import 'package:flutter/material.dart';
import 'edit_resource.dart';

// --- Integrated Palette ---
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

class ResourceUploadCard extends StatelessWidget {
  final List<Map<String, dynamic>> resources;
  final String currentUserName;
  final Function(Map<String, dynamic>) onUpdate;
  final Function(String) onDelete;

  const ResourceUploadCard({
    super.key,
    required this.resources,
    required this.currentUserName,
    required this.onUpdate,
    required this.onDelete,
  });

  void _toggleEnable(BuildContext context, Map<String, dynamic> resource) async {
    final bool isCurrentlyEnabled = resource['enabled'] ?? true;

    if (isCurrentlyEnabled) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              'Disable Resource?',
              style: TextStyle(color: kDarkPrimary, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'This will temporarily hide the resource. You can re-enable it whenever you need.',
              style: TextStyle(color: Colors.black54),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: kAppGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Confirm'),
                ),
              ),
            ],
          );
        },
      );

      if (confirm != true) return;
    }

    final updatedResource = {
      ...resource,
      'enabled': !isCurrentlyEnabled,
    };

    onUpdate(updatedResource);
  }

  void _openEditScreen(BuildContext context, Map<String, dynamic> resource) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditUploadResourceScreen(
          resource: Map.from(resource),
          currentUserName: currentUserName,
        ),
      ),
    );

    if (result != null) {
      if (result['_action'] == 'delete') {
        onDelete(resource['id']);
      } else {
        onUpdate(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (resources.isEmpty) {
      return Container(
        color: kBackgroundLight,
        child: const Center(
          child: Text(
            'No resources uploaded yet.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      color: kBackgroundLight,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: resources.length,
        itemBuilder: (ctx, i) {
          final item = resources[i];
          final isEnabled = item['enabled'] ?? true;

          return Card(
            color: isEnabled ? Colors.white : kSubtleGrey,
            elevation: isEnabled ? 1 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // IMAGE SECTION
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: kAccentTeal.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: ColorFiltered(
                        colorFilter: isEnabled
                            ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                            : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                        child: Image.network(
                          item['image'] ?? 'https://via.placeholder.com/80',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // CONTENT SECTION
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: Name + Toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item['title'] ?? 'Unnamed Resource',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isEnabled ? kDarkPrimary : Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: isEnabled,
                                activeColor: kAccentTeal,
                                activeTrackColor: kAccentTeal.withOpacity(0.3),
                                onChanged: (_) => _toggleEnable(context, item),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // TIME + DAYS + ICONS ROW
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Time and Days Column
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item['startTime']} - ${item['endTime']}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isEnabled ? Colors.black87 : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  (item['availableDays'] ?? []).join(', '),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isEnabled ? kAccentTeal : Colors.grey,
                                  ),
                                ),
                              ],
                            ),

                            // Edit/Delete Icons
                            Row(
                              children: [
                                _CompactIconButton(
                                  icon: Icons.edit_outlined,
                                  color: kAccentTeal,
                                  onTap: () => _openEditScreen(context, item),
                                ),
                                const SizedBox(width: 4), // reduced spacing
                                _CompactIconButton(
                                  icon: Icons.delete_outline,
                                  color: Colors.redAccent,
                                  onTap: () => onDelete(item['id']),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
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

class _CompactIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CompactIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
