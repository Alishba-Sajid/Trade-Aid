class MemberProfile {
  final String name;
  final String address;
  final String phone;
  final String email;
  final String joinedDate;
  final String avatarUrl;
  final double buyerRating; // ⭐ Buyer rating
  final double sellerRating; // ⭐ Seller rating

  MemberProfile({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.joinedDate,
    required this.avatarUrl,
    required this.buyerRating,
    required this.sellerRating,
  });
  
}
