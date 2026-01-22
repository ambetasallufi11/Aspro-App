import 'package:flutter/material.dart';

class AddressSelector extends StatelessWidget {
    final List<String> addresses;
    final String selectedAddress;
    final Function(String) onAddressSelected;
    final VoidCallback? onAddAddress;

    const AddressSelector({
        super.key,
        required this.addresses,
        required this.selectedAddress,
        required this.onAddressSelected,
        this.onAddAddress,
    });

    @override
    Widget build(BuildContext context) {
        final primaryColor = const Color(0xFF2196F3); // Material Blue 500
        final theme = Theme.of(context);

        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                        'Pickup Address',
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                        ),
                    ),
                ),
                
                ...addresses.map((address) {
                    final isSelected = address == selectedAddress;
                    
                    return GestureDetector(
                        onTap: () => onAddressSelected(address),
                        child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: isSelected ? primaryColor : Colors.grey.shade200,
                                    width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                    ),
                                ],
                            ),
                            child: Row(
                                children: [
                                    // Icon
                                    Icon(
                                        Icons.location_on,
                                        color: isSelected ? primaryColor : Colors.grey.shade600,
                                        size: 24,
                                    ),
                                    
                                    const SizedBox(width: 16),
                                    
                                    // Address text
                                    Expanded(
                                        child: Text(
                                            address,
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                                color: isSelected ? primaryColor : Colors.black,
                                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                            ),
                                        ),
                                    ),
                                    
                                    // Radio indicator
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
                                            ? Center(
                                                child: Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.white,
                                                    ),
                                                ),
                                            )
                                            : null,
                                    ),
                                ],
                            ),
                        ),
                    );
                }).toList(),
                
                // Add new address button
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: OutlinedButton.icon(
                        onPressed: onAddAddress,
                        icon: Icon(Icons.add, color: primaryColor),
                        label: Text(
                            'Add New Address',
                            style: TextStyle(color: primaryColor),
                        ),
                        style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primaryColor),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                    ),
                ),
            ],
        );
    }
}
