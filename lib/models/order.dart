enum OrderStatus {
  pending,
  pickedUp,
  washing,
  ready,
  delivered,
}

class Order {
  final String id;
  final String laundryName;
  final OrderStatus status;
  final double total;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.laundryName,
    required this.status,
    required this.total,
    required this.createdAt,
  });
}
