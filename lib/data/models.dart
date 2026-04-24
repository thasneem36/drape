// ─────────────────────────────────────────────────────────────
// Models — Product, Address, Payment, Order, CartItem.
// ─────────────────────────────────────────────────────────────

class Product {
  final String id, name, brand, cat, desc, art;
  final double price;
  final List<String> sizes, colors;
  final double rating;
  final int reviews;
  final bool isNew, isSale;
  final List<int> tint; // [start, end] 0xFF-prefixed color ints

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.cat,
    required this.desc,
    required this.sizes,
    required this.colors,
    required this.rating,
    required this.reviews,
    required this.tint,
    this.art = '',
    this.isNew = false,
    this.isSale = false,
  });
}

class Address {
  final String label, line1, line2;
  final bool isDefault;
  const Address(this.label, this.line1, this.line2, {this.isDefault = false});
}

class Payment {
  final String label, detail, brand;
  const Payment(this.label, this.detail, this.brand);
}

class Order {
  final String id, date, status, address;
  final double total;
  final List<String> itemIds;
  const Order(this.id, this.date, this.status, this.total, this.itemIds, this.address);
}

class CartItem {
  final String productId;
  final String size;
  final String color;
  int qty;
  CartItem({required this.productId, required this.size, required this.color, this.qty = 1});
}
