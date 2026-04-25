class CartItem {
  final String productId, size, color;
  int qty;
  CartItem({required this.productId, required this.size, required this.color, this.qty = 1});
}
