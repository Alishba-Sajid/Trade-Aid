class Resource {
  final String id;
  final String name;
  final List<String> images; // now supports multiple images
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

  // Factory to create from Map
  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      images: (map['images'] is List) ? List<String>.from(map['images']) : <String>[],
      description: map['description'] ?? '',
      ownerName: map['ownerName'] ?? '',
      ownerAddress: map['ownerAddress'] ?? '',
      pricePerHour: (map['pricePerHour'] is num)
          ? (map['pricePerHour'] as num).toDouble()
          : double.tryParse('${map['pricePerHour']}') ?? 0.0,
      availableDays: (map['availableDays'] is List)
          ? List<String>.from(map['availableDays'])
          : <String>[],
      availableTime: map['availableTime'] ?? '',
    );
  }

  // Convert back to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'images': images,
      'description': description,
      'ownerName': ownerName,
      'ownerAddress': ownerAddress,
      'pricePerHour': pricePerHour,
      'availableDays': availableDays,
      'availableTime': availableTime,
     
    };
  }
}
