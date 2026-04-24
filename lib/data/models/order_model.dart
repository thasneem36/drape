import 'cart_item_model.dart';

class OrderModel {
  final String orderId;
  final List<CartItemModel> items;
  final double totalAmount;
  final String status;
  final String date;
  final String deliveryAddress;

  const OrderModel({
    required this.orderId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.date,
    required this.deliveryAddress,
  });
}
