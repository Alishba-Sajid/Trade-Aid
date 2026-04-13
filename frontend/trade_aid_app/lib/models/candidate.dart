class Candidate {
  final String userId;
  final String name;
  final String location;
  final double sellerRating;
  final double buyerRating;
  int votes;

  Candidate({
    required this.userId,
    required this.name,
    required this.location,
    required this.sellerRating,
    required this.buyerRating,
    this.votes = 0,
  });
}
