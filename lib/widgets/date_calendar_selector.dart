import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

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
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;

        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                // Title with gradient underline
                Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(
                                widget.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
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
                ),
                
                // Calendar widget with modern styling
                Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                            BoxShadow(
                                color: primaryColor.withOpacity(0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                            ),
                            BoxShadow(
                                color: primaryColor.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                            ),
                        ],
                        border: Border.all(
                            color: Colors.white.withOpacity(0.8),
                            width: 1,
                        ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
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
                            // Today styling
                            todayDecoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [
                                        primaryColor.withOpacity(0.3),
                                        primaryColor.withOpacity(0.2),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                            ),
                            todayTextStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                            ),
                            
                            // Selected day styling
                            selectedDecoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                    BoxShadow(
                                        color: primaryColor.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                    ),
                                ],
                            ),
                            selectedTextStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                            ),
                            
                            // Marker styling
                            markerDecoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                shape: BoxShape.circle,
                            ),
                            
                            // Weekend styling
                            weekendTextStyle: TextStyle(
                                color: theme.colorScheme.secondary,
                            ),
                            
                            // Outside days styling
                            outsideTextStyle: TextStyle(
                                color: Colors.grey.shade400,
                            ),
                        ),
                        headerStyle: HeaderStyle(
                            formatButtonVisible: true,
                            titleCentered: true,
                            formatButtonShowsNext: false,
                            formatButtonDecoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [
                                        primaryColor.withOpacity(0.1),
                                        primaryColor.withOpacity(0.2),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                            ),
                            formatButtonTextStyle: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                            ),
                            titleTextStyle: TextStyle(
                                color: theme.textTheme.titleMedium?.color,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                            ),
                            leftChevronIcon: Icon(
                                Icons.chevron_left_rounded,
                                color: primaryColor,
                                size: 28,
                            ),
                            rightChevronIcon: Icon(
                                Icons.chevron_right_rounded,
                                color: primaryColor,
                                size: 28,
                            ),
                            headerPadding: const EdgeInsets.symmetric(vertical: 12),
                            headerMargin: const EdgeInsets.only(bottom: 8),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                                color: theme.textTheme.bodyMedium?.color,
                                fontWeight: FontWeight.w600,
                            ),
                            weekendStyle: TextStyle(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                            ),
                        ),
                    ),
                ),
                
                // Display selected date with modern styling
                if (_selectedDay != null)
                    Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                    primaryColor.withOpacity(0.08),
                                    primaryColor.withOpacity(0.03),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: primaryColor.withOpacity(0.2),
                                width: 1,
                            ),
                        ),
                        child: Row(
                            children: [
                                Icon(
                                    Icons.event_available,
                                    color: primaryColor,
                                    size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Text(
                                                'Selected Date',
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                                ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                                DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay!),
                                                style: theme.textTheme.bodyLarge?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: primaryColor,
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                            ],
                        ),
                    ),
                
                // Time slots if provided
                if (widget.timeSlots.isNotEmpty)
                    Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                // Time selection title with gradient underline
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Text(
                                            'Select Time',
                                            style: theme.textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.w700,
                                            ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                            height: 2,
                                            width: 40,
                                            decoration: BoxDecoration(
                                                gradient: AppTheme.primaryGradient,
                                                borderRadius: BorderRadius.circular(1),
                                            ),
                                        ),
                                    ],
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
                                                    gradient: isSelected ? AppTheme.primaryGradient : null,
                                                    color: isSelected ? null : Colors.white,
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(
                                                        color: isSelected ? Colors.transparent : Colors.grey.shade300,
                                                        width: isSelected ? 0 : 1,
                                                    ),
                                                    boxShadow: isSelected ? [
                                                        BoxShadow(
                                                            color: primaryColor.withOpacity(0.3),
                                                            blurRadius: 8,
                                                            offset: const Offset(0, 2),
                                                        ),
                                                    ] : null,
                                                ),
                                                child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                        if (isSelected)
                                                            Padding(
                                                                padding: const EdgeInsets.only(right: 6),
                                                                child: Icon(
                                                                    Icons.access_time,
                                                                    color: Colors.white,
                                                                    size: 14,
                                                                ),
                                                            ),
                                                        Text(
                                                            timeSlot,
                                                            style: TextStyle(
                                                                color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                                                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                                            ),
                                                        ),
                                                    ],
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
