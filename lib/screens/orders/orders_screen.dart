import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/api_providers.dart';
import '../../widgets/order_card.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.t('My Orders')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'), // Navigate to entry page instead of going back
        ),
      ),
      body: ordersAsync.when(
        data: (orders) => ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final order = orders[index];
            return OrderCard(
              order: order,
              onTap: () => context.push('/orders/track?id=${order.id}'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, __) => Center(child: Text('Failed to load orders: $error')),
      ),
    );
  }
}
