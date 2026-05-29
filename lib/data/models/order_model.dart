import 'package:cloud_firestore/cloud_firestore.dart';

// ── Per-item detail stored with each order ────────────────────
class OrderItem {
  final String productId, name, brand, size, color, imageUrl;
  final double price;
  final int qty;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.brand,
    required this.size,
    required this.color,
    required this.imageUrl,
    required this.price,
    required this.qty,
  });

  factory OrderItem.fromMap(Map<String, dynamic> d) => OrderItem(
        productId: (d['productId'] as String?) ?? '',
        name:      (d['name']      as String?) ?? '',
        brand:     (d['brand']     as String?) ?? '',
        size:      (d['size']      as String?) ?? '',
        color:     (d['color']     as String?) ?? '',
        imageUrl:  (d['imageUrl']  as String?) ?? '',
        price:     (d['price']     as num?)?.toDouble() ?? 0.0,
        qty:       (d['qty']       as int?) ?? 1,
      );
}

// ── Order ─────────────────────────────────────────────────────
class Order {
  final String id, date, status, address;
  final double total;
  final List<String> itemIds;
  final List<String> itemNames;
  final List<OrderItem> orderItems;

  const Order(
    this.id,
    this.date,
    this.status,
    this.total,
    this.itemIds,
    this.address, {
    this.itemNames = const [],
    this.orderItems = const [],
  });

  factory Order.fromFirestore(String id, Map<String, dynamic> d) {
    final raw = d['items'] as List<dynamic>? ?? [];
    final maps = raw.map((i) => Map<String, dynamic>.from(i as Map)).toList();

    // Build a human-readable date from the server timestamp.
    String date;
    final ts = d['createdAt'];
    if (ts is Timestamp) {
      final dt = ts.toDate();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      date =
          '${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
    } else {
      date = (d['dateStr'] as String?) ?? 'Unknown date';
    }

    return Order(
      id,
      date,
      (d['status'] as String?) ?? 'Processing',
      (d['totalPrice'] as num?)?.toDouble() ?? 0.0,
      maps.map<String>((i) => (i['productId'] as String?) ?? '').toList(),
      (d['address'] as String?) ?? '',
      itemNames: maps.map<String>((i) => (i['name'] as String?) ?? '').toList(),
      orderItems: maps.map(OrderItem.fromMap).toList(),
    );
  }
}
