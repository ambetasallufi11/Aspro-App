import '../../models/laundry.dart';
import '../../models/service.dart';
import '../../models/order.dart';
import '../../models/user_profile.dart';

class MockData {
  static const user = UserProfile(
    name: 'Maya Tanaka',
    email: 'maya@aspro.app',
    phone: '+1 (555) 210-3344',
    addresses: [
      '128 Market Street, San Francisco, CA',
      '145 Mission Bay Blvd, San Francisco, CA',
    ],
  );

  static final allowedUsers = <MockUserCredentials>[
    MockUserCredentials(
      name: 'Ambeta Sallufi',
      email: 'ambeta@aspro.app',
      password: 'ambeta123',
      phone: '+355 69 123 4567',
      addresses: [
        'Rruga e Kavajës, Tirana',
        'Rruga Myslym Shyri, Tirana',
      ],
    ),
    MockUserCredentials(
      name: 'Alkida Isaku',
      email: 'alkida@aspro.app',
      password: 'alkida123',
      phone: '+355 68 555 2211',
      addresses: [
        'Bulevardi Zogu I, Tirana',
        'Rruga Dëshmorët e 4 Shkurtit, Tirana',
      ],
    ),
  ];

  static const laundries = [
    Laundry(
      id: 'l1',
      name: 'FreshFold Laundry Co.',
      latitude: 41.3297,
      longitude: 19.8186,
      rating: 4.8,
      priceRange: '\$\$',
      distanceKm: 0.8,
      services: ['Wash & Fold', 'Dry Clean', 'Express'],
      eta: 'Same day',
    ),
    Laundry(
      id: 'l2',
      name: 'Sunrise Suds',
      latitude: 41.3239,
      longitude: 19.8128,
      rating: 4.6,
      priceRange: '\$\$',
      distanceKm: 1.2,
      services: ['Wash & Fold', 'Eco Wash'],
      eta: '24 hrs',
    ),
    Laundry(
      id: 'l3',
      name: 'CloudClean Express',
      latitude: 41.3346,
      longitude: 19.8264,
      rating: 4.9,
      priceRange: '\$\$\$',
      distanceKm: 2.1,
      services: ['Dry Clean', 'Steam Press', 'Premium Care'],
      eta: '8 hrs',
    ),
  ];

  static const services = [
    Service(
      id: 's1',
      name: 'Wash & Fold',
      description: 'Everyday laundry with gentle detergent.',
      price: 18.0,
    ),
    Service(
      id: 's2',
      name: 'Dry Clean',
      description: 'Professional dry cleaning for delicates.',
      price: 28.0,
    ),
    Service(
      id: 's3',
      name: 'Express',
      description: 'Priority turnaround within 8 hours.',
      price: 12.0,
    ),
    Service(
      id: 's4',
      name: 'Premium Care',
      description: 'Hand-finished premium garments.',
      price: 32.0,
    ),
  ];

  static final orders = [
    Order(
      id: 'o1',
      laundryName: 'FreshFold Laundry Co.',
      status: OrderStatus.washing,
      total: 42.5,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Order(
      id: 'o2',
      laundryName: 'Sunrise Suds',
      status: OrderStatus.ready,
      total: 32.0,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    Order(
      id: 'o3',
      laundryName: 'CloudClean Express',
      status: OrderStatus.delivered,
      total: 58.0,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
}

class MockUserCredentials {
  final String name;
  final String email;
  final String password;
  final String phone;
  final List<String> addresses;

  const MockUserCredentials({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.addresses,
  });
}
