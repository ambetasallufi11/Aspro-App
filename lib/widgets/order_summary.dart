import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../models/service.dart';
import '../providers/promo_code_provider.dart';

class OrderSummary extends ConsumerStatefulWidget {
    final Set<String> selectedServices;
    final List<Service> allServices;
    final String pickupSlot;
    final String deliverySlot;
    final String address;

    const OrderSummary({
        super.key,
        required this.selectedServices,
        required this.allServices,
        required this.pickupSlot,
        required this.deliverySlot,
        required this.address,
    });

    @override
    ConsumerState<OrderSummary> createState() => _OrderSummaryState();
}

class _OrderSummaryState extends ConsumerState<OrderSummary> {
    final TextEditingController _promoCodeController = TextEditingController();
    bool _isApplyingPromoCode = false;

    @override
    void dispose() {
        _promoCodeController.dispose();
        super.dispose();
    }

    double get subtotal {
        double total = 0;
        for (final service in widget.allServices) {
            if (widget.selectedServices.contains(service.name)) {
                total += service.price;
            }
        }
        return total;
    }

    double get discount {
        final promoCodeState = ref.watch(appliedPromoCodeProvider);
        return promoCodeState.calculateDiscount(subtotal);
    }

    double get totalPrice {
        return subtotal - discount;
    }

    @override
    Widget build(BuildContext context) {
        final primaryColor = const Color(0xFF2196F3); // Material Blue 500
        final theme = Theme.of(context);

        return Container(
            padding: const EdgeInsets.all(20),
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
                border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                        context.l10n.t('Order summary'),
                        style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                        ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Services section
                    Text(
                        context.l10n.t('Selected Services'),
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                        ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    ...widget.selectedServices.map((serviceName) {
                        final service = widget.allServices.firstWhere(
                            (s) => s.name == serviceName,
                            orElse: () => const Service(
                              id: '',
                              name: '',
                              description: '',
                              price: 0,
                              merchantId: null,
                            ),
                        );
                        
                        return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                    Row(
                                        children: [
                                            Icon(
                                                Icons.check_circle,
                                                color: primaryColor,
                                                size: 18,
                                            ),
                                            
                                            const SizedBox(width: 8),
                                            
                                            Text(
                                                context.l10n.t(service.name),
                                                style: theme.textTheme.bodyLarge,
                                            ),
                                        ],
                                    ),
                                    
                                    Text(
                                        '\$${service.price.toStringAsFixed(2)}',
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                        ),
                                    ),
                                ],
                            ),
                        );
                    }).toList(),
                    
                    const Divider(height: 32),
                    
                    // Schedule section
                    Row(
                        children: [
                            Icon(
                                Icons.schedule,
                                color: primaryColor,
                                size: 20,
                            ),
                            
                            const SizedBox(width: 8),
                            
                            Text(
                                context.l10n.t('Schedule'),
                                style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                ),
                            ),
                        ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Padding(
                        padding: const EdgeInsets.only(left: 28, bottom: 8),
                        child: Row(
                            children: [
                                Text(
                                    context.l10n.t('Pickup'),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey.shade700,
                                    ),
                                ),
                                
                                const SizedBox(width: 8),
                                
                                Text(
                                    widget.pickupSlot,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w500,
                                    ),
                                ),
                            ],
                        ),
                    ),
                    
                    Padding(
                        padding: const EdgeInsets.only(left: 28, bottom: 8),
                        child: Row(
                            children: [
                                Text(
                                    context.l10n.t('Delivery'),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey.shade700,
                                    ),
                                ),
                                
                                const SizedBox(width: 8),
                                
                                Text(
                                    widget.deliverySlot,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w500,
                                    ),
                                ),
                            ],
                        ),
                    ),
                    
                    const Divider(height: 32),
                    
                    // Address section
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Icon(
                                Icons.location_on,
                                color: primaryColor,
                                size: 20,
                            ),
                            
                            const SizedBox(width: 8),
                            
                            Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Text(
                                            context.l10n.t('Address'),
                                            style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                            ),
                                        ),
                                        
                                        const SizedBox(height: 4),
                                        
                                        Text(
                                            widget.address,
                                            style: theme.textTheme.bodyLarge,
                                        ),
                                    ],
                                ),
                            ),
                        ],
                    ),
                    
                    const Divider(height: 32),
                    
                    // Promo code section
                    Row(
                        children: [
                            Icon(
                                Icons.discount,
                                color: primaryColor,
                                size: 20,
                            ),
                            
                            const SizedBox(width: 8),
                            
                            Text(
                                context.l10n.t('Promo Code'),
                                style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                ),
                            ),
                        ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Promo code input field
                    Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                            children: [
                                Expanded(
                                    child: TextField(
                                        controller: _promoCodeController,
                                        decoration: InputDecoration(
                                            hintText: context.l10n.t('Enter promo code'),
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                            hintStyle: TextStyle(color: Colors.grey.shade400),
                                        ),
                                        style: theme.textTheme.bodyLarge,
                                        textCapitalization: TextCapitalization.characters,
                                    ),
                                ),
                                
                                Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(11),
                                            bottomRight: Radius.circular(11),
                                        ),
                                    ),
                                    child: TextButton(
                                        onPressed: _isApplyingPromoCode
                                            ? null
                                            : () {
                                                final code = _promoCodeController.text.trim();
                                                if (code.isNotEmpty) {
                                                    setState(() => _isApplyingPromoCode = true);
                                                    
                                                    // Apply promo code
                                                    ref.read(appliedPromoCodeProvider.notifier).applyPromoCode(code);
                                                    
                                                    // Simulate network delay
                                                    Future.delayed(const Duration(milliseconds: 500), () {
                                                        if (mounted) {
                                                            setState(() => _isApplyingPromoCode = false);
                                                        }
                                                    });
                                                }
                                            },
                                        style: TextButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(11),
                                                    bottomRight: Radius.circular(11),
                                                ),
                                            ),
                                        ),
                                        child: _isApplyingPromoCode
                                            ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              )
                                            : Text(context.l10n.t('Apply')),
                                    ),
                                ),
                            ],
                        ),
                    ),
                    
                    // Show promo code status
                    Consumer(
                        builder: (context, ref, child) {
                            final promoCodeState = ref.watch(appliedPromoCodeProvider);
                            
                            if (promoCodeState.errorMessage != null) {
                                return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                        context.l10n.t(promoCodeState.errorMessage!),
                                        style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize: 12,
                                        ),
                                    ),
                                );
                            }
                            
                            if (promoCodeState.isValid && promoCodeState.promoCode != null) {
                                return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                        children: [
                                            Icon(
                                                Icons.check_circle,
                                                color: Colors.green.shade600,
                                                size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                                '${context.l10n.t('Promo code applied')}: ${promoCodeState.promoCode!.code}',
                                                style: TextStyle(
                                                    color: Colors.green.shade600,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                ),
                                            ),
                                            const Spacer(),
                                            TextButton(
                                                onPressed: () {
                                                    ref.read(appliedPromoCodeProvider.notifier).clearPromoCode();
                                                    _promoCodeController.clear();
                                                },
                                                style: TextButton.styleFrom(
                                                    padding: EdgeInsets.zero,
                                                    minimumSize: const Size(0, 0),
                                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                ),
                                                child: Text(
                                                    context.l10n.t('Remove'),
                                                    style: TextStyle(
                                                        color: Colors.red.shade700,
                                                        fontSize: 12,
                                                    ),
                                                ),
                                            ),
                                        ],
                                    ),
                                );
                            }
                            
                            return const SizedBox.shrink();
                        },
                    ),
                    
                    const Divider(height: 32),
                    
                    // Subtotal, discount, and total
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Text(
                                context.l10n.t('Subtotal'),
                                style: theme.textTheme.bodyLarge,
                            ),
                            
                            Text(
                                '\$${subtotal.toStringAsFixed(2)}',
                                style: theme.textTheme.bodyLarge,
                            ),
                        ],
                    ),
                    
                    if (discount > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                Text(
                                    context.l10n.t('Discount'),
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                        color: Colors.green.shade700,
                                    ),
                                ),
                                
                                Text(
                                    '-\$${discount.toStringAsFixed(2)}',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                        color: Colors.green.shade700,
                                    ),
                                ),
                            ],
                        ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Text(
                                context.l10n.t('Total'),
                                style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                ),
                            ),
                            
                            Text(
                                '\$${totalPrice.toStringAsFixed(2)}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: primaryColor,
                                ),
                            ),
                        ],
                    ),
                ],
            ),
        );
    }
}
