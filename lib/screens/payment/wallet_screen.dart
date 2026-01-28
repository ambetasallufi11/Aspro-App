import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/transaction.dart';
import '../../models/payment_method.dart';
import '../../providers/mock_providers.dart';
import '../../services/payment_service.dart';

class WalletScreen extends ConsumerStatefulWidget {
    const WalletScreen({super.key});

    @override
    ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
    bool _isAddingFunds = false;
    double _amountToAdd = 50.0;
    PaymentMethod? _selectedPaymentMethod;
    final List<double> _quickAmounts = [10.0, 25.0, 50.0, 100.0, 200.0];

    @override
    void initState() {
        super.initState();
        // Set default payment method if available
        WidgetsBinding.instance.addPostFrameCallback((_) {
            final methods = ref.read(paymentMethodsProvider);
            if (methods.isNotEmpty) {
                final defaultMethod = methods.firstWhere(
                    (m) => m.isDefault, 
                    orElse: () => methods.first
                );
                setState(() {
                    _selectedPaymentMethod = defaultMethod;
                });
            }
        });
    }

    @override
    Widget build(BuildContext context) {
        final wallet = ref.watch(walletProvider);
        final paymentService = ref.watch(paymentServiceProvider);
        final transactions = wallet.transactions.where(
            (t) => t.type == TransactionType.walletDeposit || 
                  t.type == TransactionType.walletWithdrawal
        ).toList();
        
        // Sort transactions by timestamp (newest first)
        transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;
        
        return Scaffold(
            appBar: AppBar(
                title: const Text('Wallet'),
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                ),
                actions: [
                    IconButton(
                        icon: const Icon(Icons.history),
                        onPressed: () => context.push('/payment/history'),
                        tooltip: 'Transaction History',
                    ),
                ],
            ),
            body: Column(
                children: [
                    // Wallet balance card
                    Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                    primaryColor,
                                    primaryColor.withBlue(primaryColor.blue + 40),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                                BoxShadow(
                                    color: primaryColor.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                ),
                            ],
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Row(
                                    children: [
                                        const Icon(
                                            Icons.account_balance_wallet,
                                            color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                            'Wallet Balance',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                            ),
                                        ),
                                    ],
                                ),
                                
                                const SizedBox(height: 16),
                                
                                Text(
                                    '\$${wallet.balance.toStringAsFixed(2)}',
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                    ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                ElevatedButton.icon(
                                    onPressed: () {
                                        setState(() {
                                            _isAddingFunds = true;
                                        });
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Funds'),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: primaryColor,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                ),
                            ],
                        ),
                    ),
                    
                    // Add funds form
                    if (_isAddingFunds)
                        _buildAddFundsForm(context, paymentService),
                    
                    // Recent transactions
                    Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                Text(
                                    'Recent Transactions',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                    ),
                                ),
                                
                                TextButton(
                                    onPressed: () => context.push('/payment/history'),
                                    child: const Text('View All'),
                                ),
                            ],
                        ),
                    ),
                    
                    // Transaction list
                    Expanded(
                        child: transactions.isEmpty
                            ? Center(
                                child: Text(
                                    'No wallet transactions yet',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                        color: Colors.grey.shade600,
                                    ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: transactions.length > 5 ? 5 : transactions.length,
                                itemBuilder: (context, index) {
                                    final transaction = transactions[index];
                                    return _buildTransactionItem(context, transaction);
                                },
                              ),
                    ),
                ],
            ),
        );
    }
    
    Widget _buildAddFundsForm(BuildContext context, PaymentService paymentService) {
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;
        final paymentMethods = ref.watch(paymentMethodsProvider).where(
            (m) => m.type == PaymentMethodType.stripe || m.type == PaymentMethodType.paypal
        ).toList();
        
        return Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                                'Add Funds',
                                style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                ),
                            ),
                            
                            IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                    setState(() {
                                        _isAddingFunds = false;
                                    });
                                },
                            ),
                        ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Amount selection
                    Text(
                        'Select Amount',
                        style: theme.textTheme.titleSmall,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Quick amount buttons
                    Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _quickAmounts.map((amount) {
                            final isSelected = _amountToAdd == amount;
                            return InkWell(
                                onTap: () {
                                    setState(() {
                                        _amountToAdd = amount;
                                    });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                        color: isSelected ? primaryColor : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: isSelected ? primaryColor : Colors.grey.shade300,
                                        ),
                                    ),
                                    child: Text(
                                        '\$${amount.toStringAsFixed(0)}',
                                        style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.black,
                                            fontWeight: FontWeight.w500,
                                        ),
                                    ),
                                ),
                            );
                        }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Payment method selection
                    Text(
                        'Payment Method',
                        style: theme.textTheme.titleSmall,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Payment method options
                    ...paymentMethods.map((method) {
                        final isSelected = _selectedPaymentMethod?.id == method.id;
                        return ListTile(
                            leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: isSelected ? primaryColor : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                    IconData(
                                        method.type == PaymentMethodType.stripe
                                            ? 0xe8a7 // credit_card
                                            : 0xe081, // account_balance
                                        fontFamily: 'MaterialIcons',
                                    ),
                                    color: isSelected ? Colors.white : Colors.grey.shade700,
                                ),
                            ),
                            title: Text(method.displayName),
                            trailing: isSelected
                                ? Icon(Icons.check_circle, color: primaryColor)
                                : null,
                            onTap: () {
                                setState(() {
                                    _selectedPaymentMethod = method;
                                });
                            },
                        );
                    }).toList(),
                    
                    const SizedBox(height: 24),
                    
                    // Add funds button
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: paymentService.isProcessing
                                ? null
                                : () async {
                                    if (_selectedPaymentMethod == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                                content: Text('Please select a payment method'),
                                            ),
                                        );
                                        return;
                                    }
                                    
                                    final success = await paymentService.addFundsToWallet(
                                        amount: _amountToAdd,
                                        paymentMethodType: _selectedPaymentMethod!.type,
                                        paymentMethodId: _selectedPaymentMethod!.id,
                                    );
                                    
                                    if (success) {
                                        setState(() {
                                            _isAddingFunds = false;
                                        });
                                        
                                        if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                    content: Text('Successfully added \$${_amountToAdd.toStringAsFixed(2)} to your wallet'),
                                                    backgroundColor: Colors.green,
                                                ),
                                            );
                                        }
                                    } else {
                                        if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                    content: Text(paymentService.errorMessage ?? 'Failed to add funds'),
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
                                : Text('Add \$${_amountToAdd.toStringAsFixed(2)}'),
                        ),
                    ),
                ],
            ),
        );
    }
    
    Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
        final theme = Theme.of(context);
        final isDeposit = transaction.type == TransactionType.walletDeposit;
        
        return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: (isDeposit ? Colors.green : Colors.red).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                    isDeposit ? Icons.add : Icons.remove,
                    color: isDeposit ? Colors.green : Colors.red,
                ),
            ),
            title: Text(
                isDeposit ? 'Added Funds' : 'Withdrawal',
                style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                ),
            ),
            subtitle: Text(
                DateFormat('MMM d, yyyy • h:mm a').format(transaction.timestamp),
                style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                ),
            ),
            trailing: Text(
                '${isDeposit ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDeposit ? Colors.green : Colors.red,
                ),
            ),
        );
    }
}