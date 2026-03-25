class ProfileModel {
  final String userId;
  final String fullName;
  final String? imageUrl;
  final String? address;
  final String? phone;
  final DateTime? createdAt;

  ProfileModel({
    required this.userId,
    required this.fullName,
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
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}