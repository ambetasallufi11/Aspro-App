import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

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
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;

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
                        
                        // Calendar button with gradient background
                        if (widget.onDateSelected != null)
                            Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                        onTap: () => _showDatePicker(context),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Ink(
                                            decoration: BoxDecoration(
                                                gradient: AppTheme.primaryGradient,
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: [
                                                    BoxShadow(
                                                        color: primaryColor.withOpacity(0.2),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 2),
                                                    ),
                                                ],
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                    const Icon(
                                                        Icons.calendar_today,
                                                        color: Colors.white,
                                                        size: 16,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text(
                                                        'Select Date',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: 12,
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                    ),
                                ),
                            ),
                    ],
                ),
                
                // Display selected date if available with gradient underline
                if (widget.selectedDate != null)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Row(
                                    children: [
                                        Icon(
                                            Icons.event,
                                            size: 18,
                                            color: primaryColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                            DateFormat('EEEE, MMMM d').format(widget.selectedDate!),
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                                color: theme.textTheme.titleMedium?.color,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                            ),
                                        ),
                                    ],
                                ),
                                const SizedBox(height: 4),
                                Container(
                                    height: 2,
                                    width: 100,
                                    decoration: BoxDecoration(
                                        gradient: AppTheme.primaryGradient,
                                        borderRadius: BorderRadius.circular(1),
                                    ),
                                ),
                            ],
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
                                gradient: isSelected 
                                    ? LinearGradient(
                                        colors: [
                                            primaryColor.withOpacity(0.08),
                                            primaryColor.withOpacity(0.03),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                    ) 
                                    : null,
                                color: isSelected ? null : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: isSelected ? primaryColor : Colors.grey.shade200,
                                    width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                    BoxShadow(
                                        color: isSelected 
                                            ? primaryColor.withOpacity(0.1) 
                                            : Colors.black.withOpacity(0.03),
                                        blurRadius: isSelected ? 10 : 6,
                                        offset: const Offset(0, 3),
                                    ),
                                ],
                            ),
                            child: Row(
                                children: [
                                    // Radio indicator with gradient
                                    Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: isSelected ? AppTheme.primaryGradient : null,
                                            color: isSelected ? null : Colors.white,
                                            border: Border.all(
                                                color: isSelected ? Colors.transparent : Colors.grey.shade400,
                                                width: 2,
                                            ),
                                            boxShadow: isSelected ? [
                                                BoxShadow(
                                                    color: primaryColor.withOpacity(0.3),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                ),
                                            ] : null,
                                        ),
                                        child: isSelected
                                            ? const Center(
                                                child: Icon(
                                                    Icons.check,
                                                    size: 14,
                                                    color: Colors.white,
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
                                    
                                    // Icon for selected with gradient effect
                                    if (isSelected)
                                        ShaderMask(
                                            shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                                            child: const Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                                size: 28,
                                            ),
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
