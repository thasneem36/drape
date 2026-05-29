class CartItem {
  /// Firestore document ID — needed for remove / qty-update operations.
  final String docId;
  final String productId, size, color;
  // Product metadata stored at add-to-cart time so the cart can render
  // without a separate products lookup.
  final String name, brand, imageUrl;
  final double price;
  int qty;

  CartItem({
    this.docId = '',
    required this.productId,
    required this.size,
    required this.color,
    this.name = '',
    this.brand = '',
    this.imageUrl = '',
    this.price = 0.0,
    this.qty = 1,
  });

  factory CartItem.fromFirestore(String docId, Map<String, dynamic> d) =>
      CartItem(
        docId: docId,
        productId: (d['productId'] as String?) ?? '',
        size: (d['size'] as String?) ?? '',
        color: (d['color'] as String?) ?? '',
        name: (d['name'] as String?) ?? '',
        brand: (d['brand'] as String?) ?? '',
        imageUrl: (d['imageUrl'] as String?) ?? '',
        price: (d['price'] as num?)?.toDouble() ?? 0.0,
        qty: (d['qty'] as int?) ?? 1,
      );
}
