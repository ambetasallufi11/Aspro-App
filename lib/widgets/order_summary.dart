import 'package:flutter/material.dart';
import '../models/service.dart';

class OrderSummary extends StatelessWidget {
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

    double get totalPrice {
        double total = 0;
        for (final service in allServices) {
            if (selectedServices.contains(service.name)) {
                total += service.price;
            }
        }
        return total;
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
                        'Order Summary',
                        style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                        ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Services section
                    Text(
                        'Selected Services',
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                        ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    ...selectedServices.map((serviceName) {
                        final service = allServices.firstWhere(
                            (s) => s.name == serviceName,
                            orElse: () => const Service(
                                id: '',
                                name: '',
                                description: '',
                                price: 0,
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
                                                service.name,
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
                                'Schedule',
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
                                    'Pickup:',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey.shade700,
                                    ),
                                ),
                                
                                const SizedBox(width: 8),
                                
                                Text(
                                    pickupSlot,
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
                                    'Delivery:',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey.shade700,
                                    ),
                                ),
                                
                                const SizedBox(width: 8),
                                
                                Text(
                                    deliverySlot,
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
                                            'Address',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                            ),
                                        ),
                                        
                                        const SizedBox(height: 4),
                                        
                                        Text(
                                            address,
                                            style: theme.textTheme.bodyLarge,
                                        ),
                                    ],
                                ),
                            ),
                        ],
                    ),
                    
                    const Divider(height: 32),
                    
                    // Total section
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Text(
                                'Total',
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
