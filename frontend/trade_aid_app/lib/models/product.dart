// simple product model used across product listing/details
class Product {
  final String id;
  final String name;
  final String image; // asset path
  final double price;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.description,
  });
}
