import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/mock_data.dart';
import '../models/laundry.dart';
import '../models/order.dart';
import '../models/service.dart';
import '../models/user_profile.dart';

final userProvider = Provider<UserProfile>((ref) => MockData.user);
final laundriesProvider = Provider<List<Laundry>>((ref) => MockData.laundries);
final servicesProvider = Provider<List<Service>>((ref) => MockData.services);
final ordersProvider = Provider<List<Order>>((ref) => MockData.orders);
