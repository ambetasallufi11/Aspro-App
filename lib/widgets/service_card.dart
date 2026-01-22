import 'package:flutter/material.dart';
import '../models/service.dart';
import '../utils/service_localization.dart';
import 'package:aspro_app/l10n/app_localizations.dart';

class ServiceCard extends StatelessWidget {
    final Service service;
    final bool isSelected;
    final VoidCallback onTap;

    const ServiceCard({
        super.key,
        required this.service,
        required this.isSelected,
        required this.onTap,
    });

    @override
    Widget build(BuildContext context) {
        final primaryColor = const Color(0xFF2196F3); // Material Blue 500
        final theme = Theme.of(context);
        final l10n = AppLocalizations.of(context)!;

        return GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                    color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: isSelected ? primaryColor : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                        ),
                    ],
                ),
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                        children: [
                            // Checkbox or selection indicator
                            Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? primaryColor : Colors.white,
                                    border: isSelected 
                                        ? null 
                                        : Border.all(color: Colors.grey.shade300),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                    )
                                    : null,
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Service details
                            Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Text(
                                            localizeServiceName(l10n, service.name),
                                            style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: isSelected ? primaryColor : Colors.black,
                                            ),
                                        ),
                                        
                                        const SizedBox(height: 4),
                                        
                                        Text(
                                            localizeServiceDescription(l10n, service.description),
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                                color: Colors.grey.shade700,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // Price
                            Text(
                                '\$${service.price.toStringAsFixed(2)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? primaryColor : Colors.black,
                                ),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}
