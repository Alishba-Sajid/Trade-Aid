// lib/models/resource.dart
class Resource {
  final String id;
  final String name;
  final String image; // asset path or remote url
  final String description;
  final String ownerName;
  final String ownerAddress;
  final double pricePerHour;
  final List<String> availableDays;
  final String availableTime;

  Resource({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.ownerName,
    required this.ownerAddress,
    required this.pricePerHour,
    required this.availableDays,
    required this.availableTime,
  });

  // Optional: convenience factory to create from a Map (useful for testing)
  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      description: map['description'] ?? '',
      ownerName: map['ownerName'] ?? '',
      ownerAddress: map['ownerAddress'] ?? '',
      pricePerHour: (map['pricePerHour'] is num) ? (map['pricePerHour'] as num).toDouble() : double.tryParse('${map['pricePerHour']}') ?? 0.0,
      availableDays: (map['availableDays'] is List) ? List<String>.from(map['availableDays']) : <String>[],
      availableTime: map['availableTime'] ?? '',
    );
  }

  // Optional: toMap for serialization if needed later
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'description': description,
      'ownerName': ownerName,
      'ownerAddress': ownerAddress,
      'pricePerHour': pricePerHour,
      'availableDays': availableDays,
      'availableTime': availableTime,
    };
  }
}
