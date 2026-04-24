class ProductModel {
  final String id;
  final String name;
  final String brand;
  final String price;
  final double priceValue;
  final String imageUrl;
  final String category;
  final String description;
  final List<String> sizes;
  final List<String> colors;
  final double rating;
  final int reviewCount;
  final bool isNew;
  final bool isSale;

  const ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.priceValue,
    required this.imageUrl,
    required this.category,
    required this.description,
    required this.sizes,
    required this.colors,
    required this.rating,
    required this.reviewCount,
    this.isNew = false,
    this.isSale = false,
  });
}
