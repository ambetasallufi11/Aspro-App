import 'package:flutter/material.dart';

class TimeSelectionBottomSheet extends StatelessWidget {
    final List<String> timeSlots;
    final String selectedTime;
    final Function(String) onTimeSelected;

    const TimeSelectionBottomSheet({
        super.key,
        required this.timeSlots,
        required this.selectedTime,
        required this.onTimeSelected,
    });

    @override
    Widget build(BuildContext context) {
        final primaryColor = const Color(0xFF2196F3); // Material Blue 500
        final theme = Theme.of(context);
        
        return Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                ),
                boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                    ),
                ],
            ),
            padding: const EdgeInsets.only(
                top: 16,
                bottom: 32,
                left: 24,
                right: 24,
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    // Handle bar at top
                    Center(
                        child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                            ),
                        ),
                    ),
                    
                    // Title
                    Text(
                        'Select Time',
                        style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                        ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Time slots grid
                    GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                        ),
                        itemCount: timeSlots.length,
                        itemBuilder: (context, index) {
                            final timeSlot = timeSlots[index];
                            final isSelected = timeSlot == selectedTime;
                            
                            return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                    color: isSelected ? primaryColor : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: isSelected ? primaryColor : Colors.grey.shade300,
                                        width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                                color: primaryColor.withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                            ),
                                        ]
                                        : null,
                                ),
                                child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                        onTap: () => onTimeSelected(timeSlot),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Center(
                                            child: Text(
                                                timeSlot,
                                                style: TextStyle(
                                                    color: isSelected ? Colors.white : Colors.black87,
                                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                                    fontSize: 14,
                                                ),
                                            ),
                                        ),
                                    ),
                                ),
                            );
                        },
                    ),
                ],
            ),
        );
    }
}
