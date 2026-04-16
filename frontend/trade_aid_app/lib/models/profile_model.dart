class ProfileModel {
  final String userId;
  final String fullName;
  final String? imageUrl;
  final String? address;
  final String? phone;
  final DateTime? createdAt;
  final double buyerRating;
 final double sellerRating;

  ProfileModel({
    required this.userId,
    required this.fullName,
    required this.buyerRating,
    required this.sellerRating,
    this.imageUrl,
    this.address,
    this.phone,
    this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['user_id'],
      fullName: json['full_name'] ?? 'Unknown User',
      imageUrl: json['profile_image_url'],
      address: json['address'],
      phone: json['phone'],
      // ✅ FIXED FIELD NAMES
    buyerRating: (json['buyer_rating_avg'] ?? 0).toDouble(),
    sellerRating: (json['seller_rating_avg'] ?? 0).toDouble(),

    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : null,
  );

  }
}