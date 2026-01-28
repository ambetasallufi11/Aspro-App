import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/order.dart';
import '../../models/transaction.dart';
import '../../models/payment_method.dart';
import '../../providers/mock_providers.dart';
import '../../services/payment_service.dart';

class RefundRequestScreen extends ConsumerStatefulWidget {
    final String orderId;
    final String transactionId;

    const RefundRequestScreen({
        super.key,
        required this.orderId,
        required this.transactionId,
    });

    @override
    ConsumerState<RefundRequestScreen> createState() => _RefundRequestScreenState();
}

class _RefundRequestScreenState extends ConsumerState<RefundRequestScreen> {
    final _reasonController = TextEditingController();
    String _selectedReason = '';
    bool _isFullRefund = true;
    double _partialRefundAmount = 0.0;
    
    final List<String> _commonReasons = [
        'Order was cancelled',
        'Service quality issues',
        'Delivery was late',
        'Wrong items delivered',
        'Changed my mind',
    ];

    @override
    void dispose() {
        _reasonController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        final orders = ref.watch(ordersProvider);
        final transactions = ref.watch(transactionsProvider);
        final paymentService = ref.watch(paymentServiceProvider);
        
        final order = orders.firstWhere(
            (o) => o.id == widget.orderId,
            orElse: () => Order(
                id: '',
                laundryName: '',
                status: OrderStatus.pending,
                total: 0,
                createdAt: DateTime.now(),
            ),
        );
        
        final transaction = transactions.firstWhere(
            (t) => t.id == widget.transactionId,
            orElse: () => Transaction(
                id: '',
                orderId: '',
                type: TransactionType.payment,
                status: TransactionStatus.completed,
                amount: 0,
                timestamp: DateTime.now(),
                paymentMethodType: PaymentMethodType.stripe,
            ),
        );
        
        if (order.id.isEmpty || transaction.id.isEmpty) {
            return Scaffold(
                appBar: AppBar(
                    title: const Text('Refund Request'),
                    leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                    ),
                ),
                body: const Center(
                    child: Text('Order or transaction not found'),
                ),
            );
        }
        
        if (_partialRefundAmount == 0) {
            _partialRefundAmount = order.total / 2; // Default to half the order amount
        }
        
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;
        
        return Scaffold(
            appBar: AppBar(
                title: const Text('Refund Request'),
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                ),
            ),
            body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        // Order details card
                        Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                    ),
                                ],
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                            Text(
                                                'Order Details',
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                ),
                                            ),
                                            
                                            Text(
                                                '#${order.id.toUpperCase()}',
                                                style: theme.textTheme.titleSmall?.copyWith(
                                                    color: Colors.grey.shade700,
                                                ),
                                            ),
                                        ],
                                    ),
                                    
                                    const SizedBox(height: 16),
                                    
                                    Row(
                                        children: [
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                        Text(
                                                            'Laundry',
                                                            style: theme.textTheme.bodySmall?.copyWith(
                                                                color: Colors.grey.shade600,
                                                            ),
                                                        ),
                                                        
                                                        Text(
                                                            order.laundryName,
                                                            style: theme.textTheme.bodyMedium?.copyWith(
                                                                fontWeight: FontWeight.w500,
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                            
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                        Text(
                                                            'Date',
                                                            style: theme.textTheme.bodySmall?.copyWith(
                                                                color: Colors.grey.shade600,
                                                            ),
                                                        ),
                                                        
                                                        Text(
                                                            DateFormat('MMM d, yyyy').format(order.createdAt),
                                                            style: theme.textTheme.bodyMedium?.copyWith(
                                                                fontWeight: FontWeight.w500,
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                        ],
                                    ),
                                    
                                    const SizedBox(height: 16),
                                    
                                    Row(
                                        children: [
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                        Text(
                                                            'Status',
                                                            style: theme.textTheme.bodySmall?.copyWith(
                                                                color: Colors.grey.shade600,
                                                            ),
                                                        ),
                                                        
                                                        Container(
                                                            margin: const EdgeInsets.only(top: 4),
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                            decoration: BoxDecoration(
                                                                color: primaryColor.withOpacity(0.1),
                                                                borderRadius: BorderRadius.circular(12),
                                                            ),
                                                            child: Text(
                                                                order.status.toString().split('.').last,
                                                                style: theme.textTheme.bodySmall?.copyWith(
                                                                    color: primaryColor,
                                                                    fontWeight: FontWeight.w500,
                                                                ),
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                            
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                        Text(
                                                            'Total',
                                                            style: theme.textTheme.bodySmall?.copyWith(
                                                                color: Colors.grey.shade600,
                                                            ),
                                                        ),
                                                        
                                                        Text(
                                                            '\$${order.total.toStringAsFixed(2)}',
                                                            style: theme.textTheme.titleMedium?.copyWith(
                                                                fontWeight: FontWeight.w600,
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                        ],
                                    ),
                                ],
                            ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Refund type selection
                        Text(
                            'Refund Type',
                            style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                            ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Row(
                            children: [
                                Expanded(
                                    child: _buildRefundTypeOption(
                                        'Full Refund',
                                        '\$${order.total.toStringAsFixed(2)}',
                                        _isFullRefund,
                                        () => setState(() => _isFullRefund = true),
                                    ),
                                ),
                                
                                const SizedBox(width: 12),
                                
                                Expanded(
                                    child: _buildRefundTypeOption(
                                        'Partial Refund',
                                        '\$${_partialRefundAmount.toStringAsFixed(2)}',
                                        !_isFullRefund,
                                        () => setState(() => _isFullRefund = false),
                                    ),
                                ),
                            ],
                        ),
                        
                        // Partial refund amount slider
                        if (!_isFullRefund)
                            Container(
                                margin: const EdgeInsets.only(top: 16),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Text(
                                            'Refund Amount: \$${_partialRefundAmount.toStringAsFixed(2)}',
                                            style: theme.textTheme.titleSmall,
                                        ),
                                        
                                        Slider(
                                            value: _partialRefundAmount,
                                            min: 1,
                                            max: order.total,
                                            divisions: (order.total * 2).toInt(),
                                            label: '\$${_partialRefundAmount.toStringAsFixed(2)}',
                                            onChanged: (value) {
                                                setState(() {
                                                    _partialRefundAmount = value;
                                                });
                                            },
                                        ),
                                        
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                                Text(
                                                    '\$1.00',
                                                    style: theme.textTheme.bodySmall?.copyWith(
                                                        color: Colors.grey.shade600,
                                                    ),
                                                ),
                                                
                                                Text(
                                                    '\$${order.total.toStringAsFixed(2)}',
                                                    style: theme.textTheme.bodySmall?.copyWith(
                                                        color: Colors.grey.shade600,
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ],
                                ),
                            ),
                        
                        const SizedBox(height: 24),
                        
                        // Reason selection
                        Text(
                            'Reason for Refund',
                            style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                            ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _commonReasons.map((reason) {
                                final isSelected = _selectedReason == reason;
                                return InkWell(
                                    onTap: () {
                                        setState(() {
                                            _selectedReason = reason;
                                            _reasonController.text = reason;
                                        });
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                            color: isSelected ? primaryColor : Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                                color: isSelected ? primaryColor : Colors.grey.shade300,
                                            ),
                                        ),
                                        child: Text(
                                            reason,
                                            style: TextStyle(
                                                color: isSelected ? Colors.white : Colors.black,
                                                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                            ),
                                        ),
                                    ),
                                );
                            }).toList(),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Custom reason text field
                        TextField(
                            controller: _reasonController,
                            decoration: InputDecoration(
                                labelText: 'Custom Reason',
                                hintText: 'Enter your reason for requesting a refund',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                ),
                            ),
                            maxLines: 3,
                            onChanged: (value) {
                                if (_commonReasons.contains(_selectedReason) && value != _selectedReason) {
                                    setState(() {
                                        _selectedReason = '';
                                    });
                                }
                            },
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Submit button
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: paymentService.isProcessing
                                    ? null
                                    : () async {
                                        if (_reasonController.text.trim().isEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                    content: Text('Please provide a reason for the refund'),
                                                ),
                                            );
                                            return;
                                        }
                                        
                                        final amount = _isFullRefund ? order.total : _partialRefundAmount;
                                        
                                        final success = await paymentService.processRefund(
                                            orderId: order.id,
                                            amount: amount,
                                            transactionId: transaction.id,
                                            reason: _reasonController.text.trim(),
                                        );
                                        
                                        if (success) {
                                            if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                        content: Text('Refund of \$${amount.toStringAsFixed(2)} processed successfully'),
                                                        backgroundColor: Colors.green,
                                                    ),
                                                );
                                                
                                                context.pop(true); // Return success
                                            }
                                        } else {
                                            if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                        content: Text(paymentService.errorMessage ?? 'Failed to process refund'),
                                                        backgroundColor: Colors.red,
                                                    ),
                                                );
                                            }
                                        }
                                    },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                    ),
                                ),
                                child: paymentService.isProcessing
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                        ),
                                      )
                                    : Text('Request Refund of \$${(_isFullRefund ? order.total : _partialRefundAmount).toStringAsFixed(2)}'),
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
    
    Widget _buildRefundTypeOption(String title, String subtitle, bool isSelected, VoidCallback onTap) {
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;
        
        return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isSelected ? primaryColor : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                    ),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(
                            children: [
                                Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected ? primaryColor : Colors.white,
                                        border: Border.all(
                                            color: isSelected ? primaryColor : Colors.grey.shade400,
                                            width: 2,
                                        ),
                                    ),
                                    child: isSelected
                                        ? const Center(
                                            child: Icon(
                                                Icons.check,
                                                size: 14,
                                                color: Colors.white,
                                            ),
                                          )
                                        : null,
                                ),
                                
                                const SizedBox(width: 8),
                                
                                Text(
                                    title,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w500,
                                    ),
                                ),
                            ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                            subtitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected ? primaryColor : null,
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}