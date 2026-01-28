import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/payment_method.dart';
import '../providers/mock_providers.dart';

class PaymentMethodSelector extends ConsumerStatefulWidget {
    final Function(PaymentMethod) onPaymentMethodSelected;
    final bool showWalletOption;
    final double walletBalance;
    final double orderAmount;

    const PaymentMethodSelector({
        super.key,
        required this.onPaymentMethodSelected,
        this.showWalletOption = true,
        this.walletBalance = 0.0,
        required this.orderAmount,
    });

    @override
    ConsumerState<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends ConsumerState<PaymentMethodSelector> {
    PaymentMethod? _selectedMethod;
    bool _showAddCard = false;

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
                    _selectedMethod = defaultMethod;
                });
                widget.onPaymentMethodSelected(defaultMethod);
            }
        });
    }

    @override
    Widget build(BuildContext context) {
        final paymentMethods = ref.watch(paymentMethodsProvider);
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;
        
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                    'Payment Method',
                    style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                    ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                    'Select how you want to pay',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                    ),
                ),
                
                const SizedBox(height: 24),
                
                // Wallet option
                if (widget.showWalletOption)
                    _buildPaymentOption(
                        PaymentMethod(
                            id: 'wallet',
                            type: PaymentMethodType.wallet,
                        ),
                        isEnabled: widget.walletBalance >= widget.orderAmount,
                        subtitle: widget.walletBalance >= widget.orderAmount
                            ? 'Balance: \$${widget.walletBalance.toStringAsFixed(2)}'
                            : 'Insufficient balance: \$${widget.walletBalance.toStringAsFixed(2)}',
                    ),
                
                // Cash on delivery option
                _buildPaymentOption(
                    PaymentMethod(
                        id: 'cash',
                        type: PaymentMethodType.cash,
                    ),
                ),
                
                // Saved payment methods
                ...paymentMethods.map((method) => _buildPaymentOption(method)),
                
                // Add new card option
                if (!_showAddCard)
                    ListTile(
                        leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                                Icons.add,
                                color: primaryColor,
                            ),
                        ),
                        title: Text(
                            'Add Payment Method',
                            style: theme.textTheme.titleMedium,
                        ),
                        onTap: () {
                            setState(() {
                                _showAddCard = true;
                            });
                        },
                    ),
                
                // Add card form
                if (_showAddCard)
                    _buildAddCardForm(),
            ],
        );
    }
    
    Widget _buildPaymentOption(PaymentMethod method, {bool isEnabled = true, String? subtitle}) {
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;
        
        return Opacity(
            opacity: isEnabled ? 1.0 : 0.5,
            child: ListTile(
                leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: _selectedMethod?.id == method.id
                            ? primaryColor
                            : primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                        IconData(
                            method.type == PaymentMethodType.stripe
                                ? 0xe8a7 // credit_card
                                : method.type == PaymentMethodType.paypal
                                    ? 0xe081 // account_balance
                                    : method.type == PaymentMethodType.cash
                                        ? 0xe8ee // payments
                                        : 0xe850, // account_balance_wallet
                            fontFamily: 'MaterialIcons',
                        ),
                        color: _selectedMethod?.id == method.id
                            ? Colors.white
                            : primaryColor,
                    ),
                ),
                title: Text(
                    method.displayName,
                    style: theme.textTheme.titleMedium,
                ),
                subtitle: subtitle != null ? Text(subtitle) : null,
                trailing: _selectedMethod?.id == method.id
                    ? Icon(
                        Icons.check_circle,
                        color: primaryColor,
                      )
                    : null,
                onTap: isEnabled
                    ? () {
                        setState(() {
                            _selectedMethod = method;
                        });
                        widget.onPaymentMethodSelected(method);
                      }
                    : null,
            ),
        );
    }
    
    Widget _buildAddCardForm() {
        return Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                        'Add New Card',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                        ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Card number field
                    TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Card Number',
                            hintText: '4242 4242 4242 4242',
                        ),
                        keyboardType: TextInputType.number,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Expiry and CVV
                    Row(
                        children: [
                            Expanded(
                                child: TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: 'Expiry Date',
                                        hintText: 'MM/YY',
                                    ),
                                    keyboardType: TextInputType.number,
                                ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            Expanded(
                                child: TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: 'CVV',
                                        hintText: '123',
                                    ),
                                    keyboardType: TextInputType.number,
                                    obscureText: true,
                                ),
                            ),
                        ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                            TextButton(
                                onPressed: () {
                                    setState(() {
                                        _showAddCard = false;
                                    });
                                },
                                child: const Text('Cancel'),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            ElevatedButton(
                                onPressed: () {
                                    // In a real app, we would validate and save the card
                                    // For now, just add a mock card
                                    final newCard = PaymentMethod(
                                        id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
                                        type: PaymentMethodType.stripe,
                                        cardLastFour: '4242',
                                        cardBrand: 'Visa',
                                    );
                                    
                                    setState(() {
                                        _selectedMethod = newCard;
                                        _showAddCard = false;
                                    });
                                    
                                    widget.onPaymentMethodSelected(newCard);
                                },
                                child: const Text('Save Card'),
                            ),
                        ],
                    ),
                ],
            ),
        );
    }
}