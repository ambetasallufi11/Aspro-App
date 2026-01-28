import '../../models/laundry.dart';
import '../../models/service.dart';
import '../../models/order.dart';
import '../../models/user_profile.dart';
import '../../models/payment_method.dart';
import '../../models/transaction.dart';
import '../../models/promo_code.dart';

class MockData {
  static const user = UserProfile(
    name: 'Maya Tanaka',
    email: 'maya@aspro.app',
    phone: '+1 (555) 210-3344',
    addresses: [
      '128 Market Street, San Francisco, CA',
      '145 Mission Bay Blvd, San Francisco, CA',
    ],
    walletBalance: 75.50,
    savedPaymentMethods: ['pm_1', 'pm_2'],
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
      walletBalance: 120.00,
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
      walletBalance: 50.00,
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
      imageUrl: 'assets/Merchant1.png',
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
      imageUrl: 'assets/Merchant2.png',
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
      imageUrl: 'assets/Merchant3.png',
    ),
  ];

  static const services = [
    Service(
      id: 's1',
      name: 'Wash & Fold',
      description: 'Everyday laundry with gentle detergent.',
      price: 18.0,
      merchantId: 'l1',
    ),
    Service(
      id: 's2',
      name: 'Dry Clean',
      description: 'Professional dry cleaning for delicates.',
      price: 28.0,
      merchantId: 'l1',
    ),
    Service(
      id: 's3',
      name: 'Express',
      description: 'Priority turnaround within 8 hours.',
      price: 12.0,
      merchantId: 'l1',
    ),
    Service(
      id: 's4',
      name: 'Premium Care',
      description: 'Hand-finished premium garments.',
      price: 32.0,
      merchantId: 'l1',
    ),
  ];

  static final orders = [
    Order(
      id: 'o1',
      laundryName: 'FreshFold Laundry Co.',
      status: OrderStatus.washing,
      total: 42.5,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      paymentStatus: PaymentStatus.paid,
      paymentMethodId: 'pm_1',
      paidAt: DateTime.now().subtract(const Duration(hours: 5, minutes: 10)),
    ),
    Order(
      id: 'o2',
      laundryName: 'Sunrise Suds',
      status: OrderStatus.ready,
      total: 32.0,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      paymentStatus: PaymentStatus.paid,
      isWalletPayment: true,
      paidAt: DateTime.now().subtract(const Duration(days: 1, hours: 3, minutes: 5)),
    ),
    Order(
      id: 'o3',
      laundryName: 'CloudClean Express',
      status: OrderStatus.delivered,
      total: 58.0,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      paymentStatus: PaymentStatus.paid,
      paymentMethodId: 'pm_2',
      paidAt: DateTime.now().subtract(const Duration(days: 2, minutes: 15)),
    ),
    Order(
      id: 'o4',
      laundryName: 'Sunrise Suds',
      status: OrderStatus.cancelled,
      total: 27.5,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      paymentStatus: PaymentStatus.refunded,
      paymentMethodId: 'pm_1',
      paidAt: DateTime.now().subtract(const Duration(days: 3, hours: 1)),
    ),
  ];
  // Mock payment methods
  static final paymentMethods = [
    PaymentMethod(
      id: 'pm_1',
      type: PaymentMethodType.stripe,
      cardLastFour: '4242',
      cardBrand: 'Visa',
      isDefault: true,
    ),
    PaymentMethod(
      id: 'pm_2',
      type: PaymentMethodType.paypal,
      email: 'maya@aspro.app',
    ),
  ];
  
  // Mock promo codes
  static final promoCodes = [
    PromoCode(
      id: 'p1',
      code: 'WELCOME10',
      merchantId: 'l1', // FreshFold Laundry Co.
      type: PromoCodeType.percentage,
      value: 10.0, // 10% off
      description: 'Welcome discount for new customers',
      expirationDate: DateTime.now().add(const Duration(days: 30)),
      usageLimit: 1,
    ),
    PromoCode(
      id: 'p2',
      code: 'WEEKLY20',
      merchantId: 'l1', // FreshFold Laundry Co.
      type: PromoCodeType.percentage,
      value: 20.0, // 20% off
      description: 'Weekly discount for recurring customers',
      isForRecurringCustomers: true,
    ),
    PromoCode(
      id: 'p3',
      code: 'SUMMER5',
      merchantId: 'l2', // Sunrise Suds
      type: PromoCodeType.fixedAmount,
      value: 5.0, // $5 off
      description: 'Summer promotion',
      expirationDate: DateTime.now().add(const Duration(days: 90)),
    ),
  ];
  
  // Mock transactions
  static final transactions = [
    Transaction(
      id: 't1',
      orderId: 'o1',
      type: TransactionType.payment,
      status: TransactionStatus.completed,
      amount: 42.5,
      timestamp: DateTime.now().subtract(const Duration(hours: 5, minutes: 10)),
      paymentMethodType: PaymentMethodType.stripe,
      paymentId: 'pi_123456',
    ),
    Transaction(
      id: 't2',
      orderId: 'o2',
      type: TransactionType.payment,
      status: TransactionStatus.completed,
      amount: 32.0,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3, minutes: 5)),
      paymentMethodType: PaymentMethodType.wallet,
    ),
    Transaction(
      id: 't3',
      orderId: 'o3',
      type: TransactionType.payment,
      status: TransactionStatus.completed,
      amount: 58.0,
      timestamp: DateTime.now().subtract(const Duration(days: 2, minutes: 15)),
      paymentMethodType: PaymentMethodType.paypal,
      paymentId: 'PAY-456789',
    ),
    Transaction(
      id: 't4',
      orderId: 'o4',
      type: TransactionType.payment,
      status: TransactionStatus.refunded,
      amount: 27.5,
      timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 1)),
      paymentMethodType: PaymentMethodType.stripe,
      paymentId: 'pi_789012',
    ),
    Transaction(
      id: 't5',
      orderId: 'o4',
      type: TransactionType.refund,
      status: TransactionStatus.completed,
      amount: 27.5,
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 14)),
      paymentMethodType: PaymentMethodType.stripe,
      paymentId: 're_123456',
      refundReason: 'Customer requested cancellation',
    ),
    Transaction(
      id: 't6',
      orderId: '',
      type: TransactionType.walletDeposit,
      status: TransactionStatus.completed,
      amount: 100.0,
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      paymentMethodType: PaymentMethodType.stripe,
      paymentId: 'pi_345678',
    ),
  ];
}

class MockUserCredentials {
  final String name;
  final String email;
  final String password;
  final String phone;
  final List<String> addresses;
  final double walletBalance;

  const MockUserCredentials({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.addresses,
    this.walletBalance = 0.0,
  });
}
