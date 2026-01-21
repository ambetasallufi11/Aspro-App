import 'package:flutter/material.dart';

class TimeSlot {
    final String id;
    final String displayText;
    final String timeRange;
    final String day;

    const TimeSlot({
        required this.id,
        required this.displayText,
        required this.timeRange,
        required this.day,
    });
}

class TimeSlotSelector extends StatelessWidget {
    final List<TimeSlot> timeSlots;
    final String selectedSlotId;
    final Function(String) onSlotSelected;
    final String title;

    const TimeSlotSelector({
        super.key,
        required this.timeSlots,
        required this.selectedSlotId,
        required this.onSlotSelected,
        required this.title,
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
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                        ),
                    ),
                ),
                
                ...timeSlots.map((slot) {
                    final isSelected = slot.id == selectedSlotId;
                    
                    return GestureDetector(
                        onTap: () => onSlotSelected(slot.id),
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
                                    
                                    const SizedBox(width: 16),
                                    
                                    // Time slot details
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Text(
                                                    slot.day,
                                                    style: theme.textTheme.titleSmall?.copyWith(
                                                        fontWeight: FontWeight.w600,
                                                        color: isSelected ? primaryColor : Colors.black,
                                                    ),
                                                ),
                                                
                                                const SizedBox(height: 4),
                                                
                                                Text(
                                                    slot.timeRange,
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                        color: Colors.grey.shade700,
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                    
                                    // Icon for selected
                                    if (isSelected)
                                        Icon(
                                            Icons.check_circle,
                                            color: primaryColor,
                                            size: 24,
                                        ),
                                ],
                            ),
                        ),
                    );
                }).toList(),
            ],
        );
    }
}
