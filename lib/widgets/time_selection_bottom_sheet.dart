import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;
        
        return Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                ),
                boxShadow: [
                    BoxShadow(
                        color: primaryColor.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                    ),
                ],
                border: Border.all(
                    color: Colors.white.withOpacity(0.8),
                    width: 1,
                ),
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
                    // Handle bar at top with gradient
                    Center(
                        child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [
                                        primaryColor.withOpacity(0.3),
                                        primaryColor.withOpacity(0.5),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(2),
                            ),
                        ),
                    ),
                    
                    // Title with gradient underline
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(
                                'Select Time',
                                style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: theme.textTheme.titleLarge?.color,
                                    letterSpacing: -0.5,
                                ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                                height: 2,
                                width: 60,
                                decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(1),
                                ),
                            ),
                        ],
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
                                    gradient: isSelected ? AppTheme.primaryGradient : null,
                                    color: isSelected ? null : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: isSelected ? Colors.transparent : Colors.grey.shade300,
                                        width: isSelected ? 0 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                                color: primaryColor.withOpacity(0.3),
                                                blurRadius: 10,
                                                offset: const Offset(0, 3),
                                            ),
                                        ]
                                        : null,
                                ),
                                child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                        onTap: () => onTimeSelected(timeSlot),
                                        borderRadius: BorderRadius.circular(16),
                                        child: Center(
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                    if (isSelected)
                                                        const Padding(
                                                            padding: EdgeInsets.only(right: 6),
                                                            child: Icon(
                                                                Icons.access_time,
                                                                color: Colors.white,
                                                                size: 16,
                                                            ),
                                                        ),
                                                    Text(
                                                        timeSlot,
                                                        style: TextStyle(
                                                            color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                                            fontSize: 14,
                                                        ),
                                                    ),
                                                ],
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
