class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String sellerUserId;
  final String? condition;
  final String? usedTime;
  final List<String> images;
  final String? sellerName;
final String? sellerAddress;
  final String? sellerProfileImageUrl;
  int currentPageIndex = 0;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.sellerUserId,
    required this.images,
    this.condition,
    this.usedTime,
    this.sellerName,
    this.sellerAddress,
    this.sellerProfileImageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['title'], 
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      sellerUserId: json['user_id'],
      condition: json['condition'],
      usedTime: json['used_time'],
      images: (json['images'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      sellerName: json['sellerName'],
          sellerAddress: json['sellerAddress'],
      sellerProfileImageUrl: json['sellerProfileImageUrl'],
    );
  }
}