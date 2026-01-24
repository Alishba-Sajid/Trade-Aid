class Product {
  final String id;
  final String name;
  final List<String> images; // <-- change/add this
  final int price;
  final String description;
  final String? condition;
  final String? usedTime;
  final String? sellerName;
  final String? sellerAddress;

  Product({
    required this.id,
    required this.name,
    required this.images, // <-- required list now
    required this.price,
    required this.description,
    this.condition,
    this.usedTime,
    this.sellerName,
    this.sellerAddress,
  });
}
