import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/booking/booking_flow_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/laundry/laundry_details_screen.dart';
import '../screens/orders/order_tracking_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/payment/payment_history_screen.dart';
import '../screens/payment/wallet_screen.dart';
import '../screens/payment/refund_request_screen.dart';
import '../screens/profile/app_settings_screen.dart';
import '../screens/profile/privacy_security_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/splash_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/laundry',
        builder: (context, state) => LaundryDetailsScreen(
          laundryId: state.uri.queryParameters['id'],
        ),
      ),
      GoRoute(
        path: '/booking',
        builder: (context, state) => const BookingFlowScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/orders/track',
        builder: (context, state) => OrderTrackingScreen(
          orderId: state.uri.queryParameters['id'],
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/payment/history',
        builder: (context, state) => const PaymentHistoryScreen(),
      ),
      GoRoute(
        path: '/payment/wallet',
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: '/payment/refund',
        builder: (context, state) => RefundRequestScreen(
          orderId: state.uri.queryParameters['orderId'] ?? '',
          transactionId: state.uri.queryParameters['transactionId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/profile/settings',
        builder: (context, state) => const AppSettingsScreen(),
      ),
      GoRoute(
        path: '/profile/privacy',
        builder: (context, state) => const PrivacySecurityScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Route not found',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    ),
  );
}