class ProfileModel {
  final String userId;
  final String fullName;
  final String? imageUrl;
  final String? address;

  ProfileModel({
    required this.userId,
    required this.fullName,
    this.imageUrl,
    this.address,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['user_id'],
      fullName: json['full_name'] ?? 'Unknown User',
      imageUrl: json['profile_image_url'],
      address: json['address'],
    );
  }
}