import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeSlot {
    final String id;
    final String displayText;
    final String timeRange;
    final String day;
    final DateTime? date; // Added date property

    const TimeSlot({
        required this.id,
        required this.displayText,
        required this.timeRange,
        required this.day,
        this.date, // Optional for backward compatibility
    });
}

class TimeSlotSelector extends StatefulWidget {
    final List<TimeSlot> timeSlots;
    final String selectedSlotId;
    final Function(String) onSlotSelected;
    final String title;
    final DateTime? selectedDate;
    final Function(DateTime)? onDateSelected;
    final DateTime? firstDate;
    final DateTime? lastDate;

    const TimeSlotSelector({
        super.key,
        required this.timeSlots,
        required this.selectedSlotId,
        required this.onSlotSelected,
        required this.title,
        this.selectedDate,
        this.onDateSelected,
        this.firstDate,
        this.lastDate,
    });
    
    @override
    State<TimeSlotSelector> createState() => _TimeSlotSelectorState();
}

class _TimeSlotSelectorState extends State<TimeSlotSelector> {
    late DateTime _selectedDate;
    
    @override
    void initState() {
        super.initState();
        _selectedDate = widget.selectedDate ?? DateTime.now();
    }

    Future<void> _showDatePicker(BuildContext context) async {
        final now = DateTime.now();
        final firstDate = widget.firstDate ?? now;
        final lastDate = widget.lastDate ?? now.add(const Duration(days: 30));
        
        final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: firstDate,
            lastDate: lastDate,
            builder: (context, child) {
                return Theme(
                    data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                            primary: Color(0xFF2196F3),
                            onPrimary: Colors.white,
                        ),
                    ),
                    child: child!,
                );
            },
        );
        
        if (picked != null && picked != _selectedDate) {
            setState(() {
                _selectedDate = picked;
            });
            
            if (widget.onDateSelected != null) {
                widget.onDateSelected!(picked);
            }
        }
    }

    @override
    Widget build(BuildContext context) {
        final primaryColor = const Color(0xFF2196F3); // Material Blue 500
        final theme = Theme.of(context);

        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                                widget.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                ),
                            ),
                        ),
                        
                        // Calendar button
                        if (widget.onDateSelected != null)
                            Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: IconButton(
                                    icon: const Icon(Icons.calendar_today),
                                    onPressed: () => _showDatePicker(context),
                                    tooltip: 'Select Date',
                                    color: primaryColor,
                                ),
                            ),
                    ],
                ),
                
                // Display selected date if available
                if (widget.selectedDate != null)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                            'Selected Date: ${DateFormat('EEEE, MMMM d').format(widget.selectedDate!)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.w500,
                            ),
                        ),
                    ),
                
                ...widget.timeSlots.map((slot) {
                    final isSelected = slot.id == widget.selectedSlotId;
                    
                    return GestureDetector(
                        onTap: () => widget.onSlotSelected(slot.id),
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
