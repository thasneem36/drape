class Order {
  final String id, date, status, address;
  final double total;
  final List<String> itemIds;
  const Order(this.id, this.date, this.status, this.total, this.itemIds, this.address);
}
