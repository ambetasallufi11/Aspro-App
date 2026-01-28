import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/transaction.dart';
import '../../models/payment_method.dart';
import '../../models/order.dart';
import '../../providers/mock_providers.dart';
import '../../widgets/status_timeline.dart';

class OrderTrackingScreen extends ConsumerWidget {
  final String? orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final order = orders.firstWhere(
      (item) => item.id == orderId,
      orElse: () => orders.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.laundryName,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text('Order #${order.id.toUpperCase()}'),
                const SizedBox(height: 12),
                StatusTimeline(status: order.status),
                
                // Payment information
                if (order.paymentStatus != PaymentStatus.pending)
                  _buildPaymentInfo(context, order, ref),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Delivery route',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: const LatLng(41.3275, 19.8187),
                  initialZoom: 12,
                  interactionOptions:
                      const InteractionOptions(flags: InteractiveFlag.none),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.aspro_app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: const LatLng(41.3275, 19.8187),
                        width: 36,
                        height: 36,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.directions_bike,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.notifications_active_outlined, 
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Driver is on the way. You will receive updates automatically.'),
                ),
              ],
            ),
          ),
          
          // Refund button if eligible
          if (order.isRefundable)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton.icon(
                onPressed: () => _showRefundOptions(context, order, ref),
                icon: const Icon(Icons.replay),
                label: const Text('Request Refund'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 0,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentInfo(BuildContext context, order, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final transactions = ref.watch(transactionsProvider);
    
    // Find the payment transaction for this order
    final paymentTransaction = transactions.firstWhere(
      (t) => t.orderId == order.id && t.type == TransactionType.payment,
      orElse: () => Transaction(
        id: '',
        orderId: '',
        type: TransactionType.payment,
        status: TransactionStatus.pending,
        amount: 0,
        timestamp: DateTime.now(),
        paymentMethodType: PaymentMethodType.cash,
      ),
    );
    
    // Find any refund transaction for this order
    final refundTransaction = transactions.firstWhere(
      (t) => t.orderId == order.id && t.type == TransactionType.refund,
      orElse: () => Transaction(
        id: '',
        orderId: '',
        type: TransactionType.refund,
        status: TransactionStatus.pending,
        amount: 0,
        timestamp: DateTime.now(),
        paymentMethodType: PaymentMethodType.cash,
      ),
    );
    
    final hasRefund = refundTransaction.id.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Payment',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(order.paymentStatus).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                order.paymentStatusText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getStatusColor(order.paymentStatus),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Payment method
        Row(
          children: [
            Icon(
              order.isWalletPayment
                  ? Icons.account_balance_wallet
                  : Icons.payment,
              size: 16,
              color: Colors.grey.shade700,
            ),
            const SizedBox(width: 8),
            Text(
              order.isWalletPayment
                  ? 'Wallet Balance'
                  : paymentTransaction.paymentMethodType == PaymentMethodType.cash
                      ? 'Cash on Delivery'
                      : paymentTransaction.paymentMethodType == PaymentMethodType.stripe
                          ? 'Credit Card'
                          : 'PayPal',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Payment date
        if (order.paidAt != null)
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'Paid on ${DateFormat('MMM d, yyyy').format(order.paidAt!)}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        
        // Refund information if applicable
        if (hasRefund)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.replay,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Refund Processed',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Amount: \$${refundTransaction.amount.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  
                  if (refundTransaction.refundReason != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Reason: ${refundTransaction.refundReason}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Date: ${DateFormat('MMM d, yyyy').format(refundTransaction.timestamp)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.refunded:
        return Colors.blue;
      case PaymentStatus.partiallyRefunded:
        return Colors.lightBlue;
    }
  }
  
  void _showRefundOptions(BuildContext context, order, WidgetRef ref) {
    final transactions = ref.read(transactionsProvider);
    
    // Find the payment transaction for this order
    final paymentTransaction = transactions.firstWhere(
      (t) => t.orderId == order.id && t.type == TransactionType.payment,
      orElse: () => Transaction(
        id: '',
        orderId: '',
        type: TransactionType.payment,
        status: TransactionStatus.pending,
        amount: 0,
        timestamp: DateTime.now(),
        paymentMethodType: PaymentMethodType.cash,
      ),
    );
    
    if (paymentTransaction.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot find payment transaction for this order'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    context.push('/payment/refund?orderId=${order.id}&transactionId=${paymentTransaction.id}');
  }
}
