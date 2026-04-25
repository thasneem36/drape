class Product {
  final String id, name, brand, cat, desc, art;
  final double price;
  final List<String> sizes, colors;
  final double rating;
  final int reviews;
  final bool isNew, isSale;
  final List<int> tint;

  const Product({
    required this.id, required this.name, required this.brand,
    required this.price, required this.cat, required this.desc,
    required this.sizes, required this.colors,
    required this.rating, required this.reviews, required this.tint,
    this.art = '', this.isNew = false, this.isSale = false,
  });
}
