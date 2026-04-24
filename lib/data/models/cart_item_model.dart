import 'product_model.dart';

class CartItemModel {
  final String id;
  final ProductModel product;
  final String selectedSize;
  final String selectedColor;
  int quantity;

  CartItemModel({
    required this.id,
    required this.product,
    required this.selectedSize,
    required this.selectedColor,
    this.quantity = 1,
  });

  double get totalPrice => product.priceValue * quantity;
}
