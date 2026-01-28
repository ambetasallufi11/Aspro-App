import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/laundry.dart';
import '../models/order.dart';
import '../models/service.dart';
import '../models/user_profile.dart';
import '../services/api_client.dart';
import '../services/token_storage.dart';

const _apiBaseUrl = 'http://127.0.0.1:3000';

class ApiUser {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final List<String> addresses;

  const ApiUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.addresses,
  });

  UserProfile toProfile() => UserProfile(
        name: name,
        email: email,
        phone: phone ?? '',
        addresses: addresses,
      );
}

class AuthState {
  final ApiUser? currentUser;
  final String? token;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.currentUser,
    this.token,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    ApiUser? currentUser,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

final apiClientProvider = Provider<ApiClient>((ref) {
  final token = ref.watch(authProvider).token;
  return ApiClient(baseUrl: _apiBaseUrl, token: token);
});

class AuthNotifier extends Notifier<AuthState> {
  final _storage = TokenStorage();

  @override
  AuthState build() {
    Future.microtask(_restoreSession);
    return const AuthState();
  }

  Future<void> _restoreSession() async {
    final token = await _storage.readToken();
    if (token == null) return;
    try {
      final profileMap = await ApiClient(baseUrl: _apiBaseUrl, token: token).me();
      final user = ApiUser(
        id: profileMap['id'] as int,
        name: profileMap['name'] as String,
        email: profileMap['email'] as String,
        phone: profileMap['phone'] as String?,
        role: profileMap['role'] as String,
        addresses: (profileMap['addresses'] as List<dynamic>).cast<String>(),
      );
      state = state.copyWith(currentUser: user, token: token);
    } catch (_) {
      await _storage.clear();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final api = ApiClient(baseUrl: _apiBaseUrl);
      final data = await api.login(email: email, password: password);
      final token = data['token'] as String;
      final userMap = data['user'] as Map<String, dynamic>;
      final profileMap = await ApiClient(baseUrl: _apiBaseUrl, token: token).me();
      final user = ApiUser(
        id: userMap['id'] as int,
        name: userMap['name'] as String,
        email: userMap['email'] as String,
        phone: profileMap['phone'] as String?,
        role: userMap['role'] as String,
        addresses: (profileMap['addresses'] as List<dynamic>).cast<String>(),
      );
      state = state.copyWith(currentUser: user, token: token, isLoading: false);
      await _storage.writeToken(token);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final api = ApiClient(baseUrl: _apiBaseUrl);
      final data = await api.register(name: name, email: email, password: password);
      final token = data['token'] as String;
      final userMap = data['user'] as Map<String, dynamic>;
      final profileMap = await ApiClient(baseUrl: _apiBaseUrl, token: token).me();
      final user = ApiUser(
        id: userMap['id'] as int,
        name: userMap['name'] as String,
        email: userMap['email'] as String,
        phone: profileMap['phone'] as String?,
        role: userMap['role'] as String,
        addresses: (profileMap['addresses'] as List<dynamic>).cast<String>(),
      );
      state = state.copyWith(currentUser: user, token: token, isLoading: false);
      await _storage.writeToken(token);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void logout() {
    _storage.clear();
    state = const AuthState();
  }
}

final laundriesProvider = FutureProvider<List<Laundry>>((ref) async {
  final api = ref.read(apiClientProvider);
  final data = await api.merchants();
  final services = await api.services();
  final servicesByMerchant = <String, List<String>>{};
  for (final s in services) {
    final merchantId = (s['merchant_id'] as int).toString();
    servicesByMerchant.putIfAbsent(merchantId, () => []);
    servicesByMerchant[merchantId]!.add(s['name'] as String);
  }
  return data.map((m) {
    final merchantId = (m['id'] as int).toString();
    return Laundry(
      id: merchantId,
      name: m['name'] as String,
      latitude: double.tryParse(m['latitude']?.toString() ?? '') ?? 0.0,
      longitude: double.tryParse(m['longitude']?.toString() ?? '') ?? 0.0,
      rating: double.tryParse(m['rating']?.toString() ?? '') ?? 0.0,
      priceRange: (m['price_range'] as String?) ?? '',
      eta: (m['eta'] as String?) ?? '',
      imageUrl: m['image_url'] as String?,
      distanceKm: 0.0,
      services: servicesByMerchant[merchantId] ?? const [],
    );
  }).toList();
});

final servicesProvider = FutureProvider<List<Service>>((ref) async {
  final api = ref.read(apiClientProvider);
  final data = await api.services();
  return data.map((s) {
    return Service(
      id: (s['id'] as int).toString(),
      name: s['name'] as String,
      description: (s['description'] as String?) ?? '',
      price: double.tryParse(s['price']?.toString() ?? '') ?? 0.0,
      merchantId: (s['merchant_id'] as int?)?.toString(),
    );
  }).toList();
});

final ordersProvider = FutureProvider<List<Order>>((ref) async {
  final api = ref.read(apiClientProvider);
  final orders = await api.orders();
  final merchants = await api.merchants();
  final merchantMap = {
    for (final m in merchants) (m['id'] as int).toString(): m['name'] as String,
  };
  return orders.map((o) {
    final merchantId = (o['merchant_id'] as int?)?.toString() ?? '';
    return Order(
      id: (o['id'] as int).toString(),
      laundryName: merchantMap[merchantId] ?? 'Unknown',
      status: _orderStatusFromString(o['status'] as String),
      total: double.tryParse(o['total']?.toString() ?? '') ?? 0.0,
      createdAt: DateTime.parse(o['created_at'] as String),
    );
  }).toList();
});

OrderStatus _orderStatusFromString(String status) {
  switch (status) {
    case 'picked_up':
    case 'picked up':
      return OrderStatus.pickedUp;
    case 'washing':
      return OrderStatus.washing;
    case 'ready':
      return OrderStatus.ready;
    case 'delivered':
      return OrderStatus.delivered;
    default:
      return OrderStatus.pending;
  }
}
