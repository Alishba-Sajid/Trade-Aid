// member_model.dart
class Member {
  final String name;
  final String location;
  final String email;
  final String phone;
  final double ratingSeller;
  final double ratingBuyer;
  final String image;
  final String status;

  Member({
    required this.name,
    required this.location,
    required this.email,
    required this.phone,
    required this.ratingSeller,
    required this.ratingBuyer,
    required this.image,
    required this.status,
  });

  // Factory constructor to parse JSON from backend
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      ratingSeller: (json['ratingSeller'] ?? 0).toDouble(),
      ratingBuyer: (json['ratingBuyer'] ?? 0).toDouble(),
      image: json['image'] ?? '',
      status: json['status'] ?? 'Away',
    );
  }

  // Convert back to JSON (optional, for backend)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'email': email,
      'phone': phone,
      'ratingSeller': ratingSeller,
      'ratingBuyer': ratingBuyer,
      'image': image,
      'status': status,
    };
  }
}
