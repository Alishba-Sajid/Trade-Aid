class Resource {
  final String id;
  final String name;
  final List<String> images;
  final String description;
  final String ownerName;
  final String ownerAddress;
  final double pricePerHour;
  final List<String> availableDays;
  final String availableTime;

  Resource({
    required this.id,
    required this.name,
    required this.images,
    required this.description,
    required this.ownerName,
    required this.ownerAddress,
    required this.pricePerHour,
    required this.availableDays,
    required this.availableTime,
  });
factory Resource.fromJson(
  Map<String, dynamic> json,
  Map<String, dynamic>? profile,
) {
  final start = json['start_time'] ?? '';
  final end = json['end_time'] ?? '';

  return Resource(
    id: json['id'],
    name: json['name'] ?? '', // ✅ NOW USING NAME COLUMN
    images: (json['images'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [],
    description: json['description'] ?? '',
    ownerName: profile?['full_name'] ?? 'Community Member',
    ownerAddress: profile?['address'] ?? '',
    pricePerHour: (json['rate'] as num).toDouble(),
    availableDays: (json['available_days'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [],
    availableTime: "$start - $end",
  );
}}