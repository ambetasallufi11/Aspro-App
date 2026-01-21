class Laundry {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double rating;
  final String priceRange;
  final double distanceKm;
  final List<String> services;
  final String eta;
  final String? imageUrl;

  const Laundry({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.priceRange,
    required this.distanceKm,
    required this.services,
    required this.eta,
    this.imageUrl,
  });
}
