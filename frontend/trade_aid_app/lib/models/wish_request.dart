class WishRequest {
  final String id;
  final String requesterName;
  final String requesterUserId;
  final String item;
  final String description;
  final DateTime createdAt;

  WishRequest({
    required this.id,
    required this.requesterName,
    required this.requesterUserId,
    required this.item,
    required this.description,
    required this.createdAt,
  });
}
