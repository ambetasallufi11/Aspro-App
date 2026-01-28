import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../models/transaction.dart';
import '../../providers/mock_providers.dart';

class PaymentHistoryScreen extends ConsumerWidget {
    const PaymentHistoryScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final transactions = ref.watch(transactionsProvider);
        final sortedTransactions = List<Transaction>.from(transactions)
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        return Scaffold(
            appBar: AppBar(
                title: const Text('Payment History'),
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                ),
            ),
            body: transactions.isEmpty
                ? _buildEmptyState(context)
                : _buildTransactionList(context, sortedTransactions),
        );
    }
    
    Widget _buildEmptyState(BuildContext context) {
        return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Icon(
                        Icons.receipt_long,
                        size: 80,
                        color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                        'No transactions yet',
                        style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                        'Your payment history will appear here',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                        ),
                    ),
                ],
            ),
        );
    }
    
    Widget _buildTransactionList(BuildContext context, List<Transaction> transactions) {
        // Group transactions by date
        final Map<String, List<Transaction>> groupedTransactions = {};
        
        for (final transaction in transactions) {
            final date = DateFormat('MMMM d, yyyy').format(transaction.timestamp);
            if (!groupedTransactions.containsKey(date)) {
                groupedTransactions[date] = [];
            }
            groupedTransactions[date]!.add(transaction);
        }
        
        return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedTransactions.length,
            itemBuilder: (context, index) {
                final date = groupedTransactions.keys.elementAt(index);
                final dateTransactions = groupedTransactions[date]!;
                
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                                date,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                ),
                            ),
                        ),
                        ...dateTransactions.map((transaction) => _buildTransactionCard(context, transaction)),
                        const SizedBox(height: 16),
                    ],
                );
            },
        );
    }
    
    Widget _buildTransactionCard(BuildContext context, Transaction transaction) {
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;
        
        return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(
                            children: [
                                Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: transaction.statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                        transaction.typeIcon,
                                        color: transaction.statusColor,
                                        size: 20,
                                    ),
                                ),
                                
                                const SizedBox(width: 12),
                                
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Text(
                                                transaction.typeText,
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                ),
                                            ),
                                            
                                            Text(
                                                DateFormat('h:mm a').format(transaction.timestamp),
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                    color: Colors.grey.shade600,
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                                
                                Text(
                                    '${transaction.type == TransactionType.refund || transaction.type == TransactionType.walletDeposit ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: transaction.type == TransactionType.refund || transaction.type == TransactionType.walletDeposit
                                            ? Colors.green
                                            : null,
                                    ),
                                ),
                            ],
                        ),
                        
                        if (transaction.orderId.isNotEmpty)
                            Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Row(
                                    children: [
                                        Text(
                                            'Order: ',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                                color: Colors.grey.shade700,
                                            ),
                                        ),
                                        
                                        Text(
                                            '#${transaction.orderId.toUpperCase()}',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w500,
                                            ),
                                        ),
                                        
                                        const Spacer(),
                                        
                                        Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                                color: transaction.statusColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                                transaction.statusText,
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                    color: transaction.statusColor,
                                                    fontWeight: FontWeight.w500,
                                                ),
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        
                        if (transaction.refundReason != null)
                            Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                    'Reason: ${transaction.refundReason}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey.shade700,
                                    ),
                                ),
                            ),
                    ],
                ),
            ),
        );
    }
}