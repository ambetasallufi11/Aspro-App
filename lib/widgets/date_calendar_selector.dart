import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class DateCalendarSelector extends StatefulWidget {
    final DateTime initialDate;
    final DateTime firstDay;
    final DateTime lastDay;
    final Function(DateTime) onDateSelected;
    final String title;
    final DateTime? selectedDate;
    final List<String> timeSlots;
    final String? selectedTimeSlot;
    final Function(String)? onTimeSlotSelected;

    const DateCalendarSelector({
        super.key,
        required this.initialDate,
        required this.firstDay,
        required this.lastDay,
        required this.onDateSelected,
        required this.title,
        this.selectedDate,
        this.timeSlots = const [],
        this.selectedTimeSlot,
        this.onTimeSlotSelected,
    });

    @override
    State<DateCalendarSelector> createState() => _DateCalendarSelectorState();
}

class _DateCalendarSelectorState extends State<DateCalendarSelector> {
    late DateTime _focusedDay;
    late DateTime? _selectedDay;
    late CalendarFormat _calendarFormat;

    @override
    void initState() {
        super.initState();
        _focusedDay = widget.initialDate;
        _selectedDay = widget.selectedDate;
        _calendarFormat = CalendarFormat.month;
    }

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
                        widget.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                        ),
                    ),
                ),
                
                // Calendar widget
                Container(
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
                    ),
                    child: TableCalendar(
                        firstDay: widget.firstDay,
                        lastDay: widget.lastDay,
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                            });
                            widget.onDateSelected(selectedDay);
                        },
                        onFormatChanged: (format) {
                            setState(() {
                                _calendarFormat = format;
                            });
                        },
                        onPageChanged: (focusedDay) {
                            _focusedDay = focusedDay;
                        },
                        calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.3),
                                shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                            ),
                            markerDecoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                            ),
                        ),
                        headerStyle: HeaderStyle(
                            formatButtonVisible: true,
                            titleCentered: true,
                            formatButtonShowsNext: false,
                            formatButtonDecoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                            ),
                            formatButtonTextStyle: TextStyle(
                                color: primaryColor,
                            ),
                            titleTextStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                            ),
                        ),
                    ),
                ),
                
                // Display selected date
                if (_selectedDay != null)
                    Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Text(
                            'Selected Date: ${DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay!)}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: primaryColor,
                            ),
                        ),
                    ),
                
                // Time slots if provided
                if (widget.timeSlots.isNotEmpty)
                    Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(
                                    'Select Time',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                    ),
                                ),
                                
                                const SizedBox(height: 12),
                                
                                Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: widget.timeSlots.map((timeSlot) {
                                        final isSelected = timeSlot == widget.selectedTimeSlot;
                                        
                                        return GestureDetector(
                                            onTap: () {
                                                if (widget.onTimeSlotSelected != null) {
                                                    widget.onTimeSlotSelected!(timeSlot);
                                                }
                                            },
                                            child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                    color: isSelected ? primaryColor : Colors.white,
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(
                                                        color: isSelected ? primaryColor : Colors.grey.shade300,
                                                    ),
                                                ),
                                                child: Text(
                                                    timeSlot,
                                                    style: TextStyle(
                                                        color: isSelected ? Colors.white : Colors.black87,
                                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                                    ),
                                                ),
                                            ),
                                        );
                                    }).toList(),
                                ),
                            ],
                        ),
                    ),
            ],
        );
    }
}
