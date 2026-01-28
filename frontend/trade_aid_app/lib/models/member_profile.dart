class MemberProfile {
  final String name;
  final String address;
  final String phone;
  final String email;
  final String joinedDate;
  final String avatarUrl;
  final double rating; // ⭐ Added rating field

  MemberProfile({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.joinedDate,
    required this.avatarUrl,
    required this.rating, // ⭐
  });
}