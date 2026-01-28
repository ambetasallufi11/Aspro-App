class Service {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? merchantId;

  const Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.merchantId,
  });
}
