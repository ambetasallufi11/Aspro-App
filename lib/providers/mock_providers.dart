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
final allowedUsersProvider =
    Provider<List<MockUserCredentials>>((ref) => MockData.allowedUsers);

class AuthState {
  final List<MockUserCredentials> users;
  final MockUserCredentials? currentUser;

  const AuthState({required this.users, this.currentUser});

  AuthState copyWith({
    List<MockUserCredentials>? users,
    MockUserCredentials? currentUser,
  }) {
    return AuthState(
      users: users ?? this.users,
      currentUser: currentUser ?? this.currentUser,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState(users: MockData.allowedUsers);
  }

  bool registerUser({
    required String name,
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.toLowerCase();
    final exists =
        state.users.any((user) => user.email.toLowerCase() == normalizedEmail);
    if (exists) {
      return false;
    }

    final newUser = MockUserCredentials(
      name: name,
      email: normalizedEmail,
      password: password,
      phone: '+355 69 000 0000',
      addresses: const ['Tirana, Albania'],
    );

    final updated = [...state.users, newUser];
    state = state.copyWith(users: updated, currentUser: newUser);
    return true;
  }

  bool login({
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.toLowerCase();
    final match = state.users.firstWhere(
      (user) =>
          user.email.toLowerCase() == normalizedEmail &&
          user.password == password,
      orElse: () => MockUserCredentials(
        name: '',
        email: '',
        password: '',
        phone: '',
        addresses: const [],
      ),
    );

    if (match.email.isEmpty) {
      return false;
    }

    state = state.copyWith(currentUser: match);
    return true;
  }

  void logout() {
    state = state.copyWith(currentUser: null);
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
