import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

import '../../data/mock/mock_data.dart';
import '../../providers/mock_providers.dart';
import '../../widgets/booking_step_indicator.dart';
import '../../widgets/service_card.dart';
import '../../widgets/time_slot_selector.dart';
import '../../widgets/date_calendar_selector.dart';
import '../../widgets/address_selector.dart';
import '../../widgets/order_summary.dart';
import '../../widgets/enhanced_button.dart';
import '../../widgets/booking_success_modal.dart';
import '../../widgets/time_selection_bottom_sheet.dart';
import '../../models/service.dart';

class BookingFlowScreen extends ConsumerStatefulWidget {
    const BookingFlowScreen({super.key});

    @override
    ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
    int _currentStep = 0;
    final Set<String> _selectedServices = {'Wash & Fold'};
    String _pickupTimeSlot = '6:00 - 7:00 PM';
    String _deliveryTimeSlot = '6:00 - 8:00 PM';
    String _address = '128 Market Street, San Francisco, CA';
    bool _isLoading = false;
    late List<String> _addresses;
    
    // Date selection
    late DateTime _pickupDate;
    late DateTime _deliveryDate;
    
    // Available time slots
    final List<String> _timeSlots = [
        '8:00 - 10:00 AM',
        '10:00 - 12:00 PM',
        '12:00 - 2:00 PM',
        '2:00 - 4:00 PM',
        '4:00 - 6:00 PM',
        '6:00 - 7:00 PM', // Added to match default pickup time
        '6:00 - 8:00 PM',
    ];
    
    final List<String> _steps = [
        'Services',
        'Pickup',
        'Delivery',
        'Address',
        'Summary',
    ];
    
    // For backward compatibility
    final List<TimeSlot> _pickupSlots = [];
    final List<TimeSlot> _deliverySlots = [];
    
    String get _pickupSlotText {
        final formatter = DateFormat('E, MMM d');
        return '${formatter.format(_pickupDate)} • $_pickupTimeSlot';
    }
    
    String get _deliverySlotText {
        final formatter = DateFormat('E, MMM d');
        return '${formatter.format(_deliveryDate)} • $_deliveryTimeSlot';
    }

    @override
    void initState() {
        super.initState();
        final authState = ref.read(authProvider);
        final fallbackAddresses = MockData.user.addresses;
        _addresses = List.of(authState.currentUser?.addresses ?? fallbackAddresses);
        if (_addresses.isNotEmpty && !_addresses.contains(_address)) {
            _address = _addresses.first;
        }
        
        // Initialize dates
        _pickupDate = DateTime.now();
        _deliveryDate = DateTime.now().add(const Duration(days: 1));
        
        // Initialize pickup and delivery slots for backward compatibility
        _updatePickupSlots();
        _updateDeliverySlots();
    }
    
    void _updatePickupSlots() {
        final now = DateTime.now();
        final tomorrow = DateTime(now.year, now.month, now.day + 1);
        
        String dayLabel;
        if (_pickupDate.year == now.year && 
            _pickupDate.month == now.month && 
            _pickupDate.day == now.day) {
            dayLabel = 'Today';
        } else if (_pickupDate.year == tomorrow.year && 
                   _pickupDate.month == tomorrow.month && 
                   _pickupDate.day == tomorrow.day) {
            dayLabel = 'Tomorrow';
        } else {
            // Format as day of week
            dayLabel = DateFormat('EEEE').format(_pickupDate);
        }
        
        _pickupSlots.clear();
        _pickupSlots.add(
            TimeSlot(
                id: 'pickup_${_pickupDate.millisecondsSinceEpoch}',
                displayText: '$dayLabel • $_pickupTimeSlot',
                day: dayLabel,
                timeRange: _pickupTimeSlot,
                date: _pickupDate,
            ),
        );
    }
    
    void _updateDeliverySlots() {
        final now = DateTime.now();
        final tomorrow = DateTime(now.year, now.month, now.day + 1);
        final dayAfterTomorrow = DateTime(now.year, now.month, now.day + 2);
        
        String dayLabel;
        if (_deliveryDate.year == now.year && 
            _deliveryDate.month == now.month && 
            _deliveryDate.day == now.day) {
            dayLabel = 'Today';
        } else if (_deliveryDate.year == tomorrow.year && 
                   _deliveryDate.month == tomorrow.month && 
                   _deliveryDate.day == tomorrow.day) {
            dayLabel = 'Tomorrow';
        } else if (_deliveryDate.year == dayAfterTomorrow.year && 
                   _deliveryDate.month == dayAfterTomorrow.month && 
                   _deliveryDate.day == dayAfterTomorrow.day &&
                   dayAfterTomorrow.weekday == DateTime.friday) {
            dayLabel = 'Friday';
        } else {
            // Format as day of week
            dayLabel = DateFormat('EEEE').format(_deliveryDate);
        }
        
        _deliverySlots.clear();
        _deliverySlots.add(
            TimeSlot(
                id: 'delivery_${_deliveryDate.millisecondsSinceEpoch}',
                displayText: '$dayLabel • $_deliveryTimeSlot',
                day: dayLabel,
                timeRange: _deliveryTimeSlot,
                date: _deliveryDate,
            ),
        );
    }

    void _nextStep() {
        if (_currentStep < 4) {
            setState(() => _currentStep += 1);
        }
    }

    void _previousStep() {
        if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
        }
    }

    @override
    Widget build(BuildContext context) {
        final services = ref.watch(servicesProvider);
        final authState = ref.watch(authProvider);
        final primaryColor = const Color(0xFF2196F3); // Material Blue 500
    final addresses = authState.currentUser?.addresses ?? MockData.user.addresses;

        return Scaffold(
            appBar: AppBar(
                title: const Text('Book Pickup'),
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).maybePop(),
                ),
                elevation: 0,
                backgroundColor: Colors.white,
            ),
            body: Column(
                children: [
                    // Custom step indicator
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: BookingStepIndicator(
                            currentStep: _currentStep,
                            steps: _steps,
                        ),
                    ),
                    
                    // Main content area
                    Expanded(
                        child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _buildCurrentStepContent(services),
                            ),
                        ),
                    ),
                    
                    // Bottom navigation buttons
                    Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, -5),
                                ),
                            ],
                        ),
                        child: Row(
                            children: [
                                if (_currentStep > 0)
                                    Expanded(
                                        flex: 1,
                                        child: EnhancedButton(
                                            label: 'Back',
                                            onPressed: _previousStep,
                                            isOutlined: true,
                                            icon: Icons.arrow_back,
                                        ),
                                    ),
                                
                                if (_currentStep > 0)
                                    const SizedBox(width: 12),
                                
                                Expanded(
                                    flex: 2,
                                    child: _isLoading
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            decoration: BoxDecoration(
                                                color: primaryColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Center(
                                                child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                        SizedBox(
                                                            width: 20,
                                                            height: 20,
                                                            child: CircularProgressIndicator(
                                                                strokeWidth: 3,
                                                                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                                            ),
                                                        ),
                                                        const SizedBox(width: 12),
                                                        Text(
                                                            'Processing...',
                                                            style: TextStyle(
                                                                color: primaryColor,
                                                                fontWeight: FontWeight.w600,
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                        )
                                        : EnhancedButton(
                                            label: _currentStep == 4 ? 'Confirm Booking' : 'Continue',
                                            onPressed: _currentStep == 4 ? _confirmBooking : _nextStep,
                                            icon: _currentStep == 4 ? Icons.check_circle : Icons.arrow_forward,
                                        ),
                                ),
                            ],
                        ),
                    ),
                ],
            ),
        );
    }
    
    Widget _buildCurrentStepContent(List<Service> services) {
        switch (_currentStep) {
            case 0:
                return _buildServicesStep(services);
            case 1:
                return _buildPickupTimeStep();
            case 2:
                return _buildDeliveryTimeStep();
            case 3:
                return _buildAddressStep();
            case 4:
                return _buildSummaryStep(services);
            default:
                return const SizedBox.shrink();
        }
    }
    
    Widget _buildServicesStep(List<Service> services) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                        'Select Services',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                        ),
                    ),
                ),
                
                Text(
                    'Choose the services you need for your laundry',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                    ),
                ),
                
                const SizedBox(height: 24),
                
                ...services.map((service) {
                    final isSelected = _selectedServices.contains(service.name);
                    return ServiceCard(
                        service: service,
                        isSelected: isSelected,
                        onTap: () {
                            setState(() {
                                if (isSelected) {
                                    _selectedServices.remove(service.name);
                                } else {
                                    _selectedServices.add(service.name);
                                }
                            });
                        },
                    );
                }).toList(),
            ],
        );
    }
    
    Future<void> _showPickupDatePicker(BuildContext context) async {
        final now = DateTime.now();
        final maxDate = now.add(const Duration(days: 30)); // 1 month limit
        
        final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _pickupDate,
            firstDate: now,
            lastDate: maxDate,
            builder: (context, child) {
                return Theme(
                    data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                            primary: Color(0xFF2196F3), // Material Blue 500
                            onPrimary: Colors.white,
                        ),
                        dialogBackgroundColor: Colors.white,
                    ),
                    child: child!,
                );
            },
        );
        
        if (picked != null && picked != _pickupDate) {
            setState(() {
                _pickupDate = picked;
                
                // Ensure delivery date is after pickup date
                if (_deliveryDate.isBefore(_pickupDate)) {
                    _deliveryDate = _pickupDate.add(const Duration(days: 1));
                    _updateDeliverySlots();
                }
                
                _updatePickupSlots();
            });
            
            // Automatically show time selection modal
            _showTimeSelectionModal(context, true); // true for pickup, false for delivery
        }
    }
    
    void _showTimeSelectionModal(BuildContext context, bool isPickup) {
                // Show a modern draggable bottom sheet with time options
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 0.45,
                        minChildSize: 0.3,
                        maxChildSize: 0.85,
                        expand: false,
                        builder: (context, scrollController) => TimeSelectionBottomSheet(
                            timeSlots: _timeSlots,
                            selectedTime: isPickup ? _pickupTimeSlot : _deliveryTimeSlot,
                            onTimeSelected: (time) {
                                setState(() {
                                    if (isPickup) {
                                        _pickupTimeSlot = time;
                                        _updatePickupSlots();
                                    } else {
                                        _deliveryTimeSlot = time;
                                        _updateDeliverySlots();
                                    }
                                });
                                Navigator.pop(context);
                            },
                            scrollController: scrollController,
                        ),
                    ),
                );
    }
    
    Widget _buildPickupTimeStep() {
        final primaryColor = const Color(0xFF2196F3); // Material Blue 500
        final theme = Theme.of(context);
        
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                // Title row with calendar button
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Text(
                            'Select Pickup Time',
                            style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                            ),
                        ),
                        
                        ElevatedButton.icon(
                            onPressed: () => _showPickupDatePicker(context),
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: const Text('Select Date'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                        ),
                    ],
                ),
                
                // Display selected date and time
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 24),
                    padding: const EdgeInsets.all(16),
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
                        border: Border.all(
                            color: primaryColor.withOpacity(0.2),
                        ),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Row(
                                children: [
                                    Icon(
                                        Icons.calendar_month,
                                        color: primaryColor,
                                        size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                        'Date',
                                        style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                        ),
                                    ),
                                ],
                            ),
                            
                            Padding(
                                padding: const EdgeInsets.only(left: 28, top: 4, bottom: 16),
                                child: Text(
                                    DateFormat('EEEE, MMMM d, yyyy').format(_pickupDate),
                                    style: theme.textTheme.bodyMedium,
                                ),
                            ),
                            
                            Row(
                                children: [
                                    Icon(
                                        Icons.access_time,
                                        color: primaryColor,
                                        size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                        'Time',
                                        style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                        ),
                                    ),
                                ],
                            ),
                            
                            Padding(
                                padding: const EdgeInsets.only(left: 28, top: 4),
                                child: Row(
                                    children: [
                                        Text(
                                            _pickupTimeSlot,
                                            style: theme.textTheme.bodyMedium,
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton(
                                            onPressed: () => _showTimeSelectionModal(context, true),
                                            child: Text(
                                                'Change',
                                                style: TextStyle(
                                                    color: primaryColor,
                                                    fontWeight: FontWeight.w600,
                                                ),
                                            ),
                                            style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                minimumSize: const Size(0, 0),
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ],
                    ),
                ),
                
                const SizedBox(height: 24),
                
                // Display selected time slot card
                if (_pickupSlots.isNotEmpty)
                    Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: primaryColor,
                                width: 2,
                            ),
                        ),
                        child: Row(
                            children: [
                                Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: primaryColor,
                                        border: Border.all(
                                            color: primaryColor,
                                            width: 2,
                                        ),
                                    ),
                                    child: Center(
                                        child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                            ),
                                        ),
                                    ),
                                ),
                                
                                const SizedBox(width: 16),
                                
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Text(
                                                _pickupSlots[0].day,
                                                style: theme.textTheme.titleSmall?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: primaryColor,
                                                ),
                                            ),
                                            
                                            const SizedBox(height: 4),
                                            
                                            Text(
                                                _pickupSlots[0].timeRange,
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                    color: Colors.grey.shade700,
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                                
                                Icon(
                                    Icons.check_circle,
                                    color: primaryColor,
                                    size: 24,
                                ),
                            ],
                        ),
                    ),
            ],
        );
    }
    
    Future<void> _showDeliveryDatePicker(BuildContext context) async {
        final now = DateTime.now();
        final maxDate = now.add(const Duration(days: 60)); // 2 months limit for delivery
        
        final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _deliveryDate,
            firstDate: _pickupDate.add(const Duration(days: 1)), // At least one day after pickup
            lastDate: maxDate,
            builder: (context, child) {
                return Theme(
                    data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                            primary: Color(0xFF2196F3), // Material Blue 500
                            onPrimary: Colors.white,
                        ),
                        dialogBackgroundColor: Colors.white,
                    ),
                    child: child!,
                );
            },
        );
        
        if (picked != null && picked != _deliveryDate) {
            setState(() {
                _deliveryDate = picked;
                _updateDeliverySlots();
            });
            
            // Automatically show time selection modal
            _showTimeSelectionModal(context, false); // false for delivery
        }
    }
    
    Widget _buildDeliveryTimeStep() {
        final primaryColor = const Color(0xFF2196F3); // Material Blue 500
        final theme = Theme.of(context);
        
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                // Title row with calendar button
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Text(
                            'Select Delivery Time',
                            style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                            ),
                        ),
                        
                        ElevatedButton.icon(
                            onPressed: () => _showDeliveryDatePicker(context),
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: const Text('Select Date'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                        ),
                    ],
                ),
                
                // Display selected date and time
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 24),
                    padding: const EdgeInsets.all(16),
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
                        border: Border.all(
                            color: primaryColor.withOpacity(0.2),
                        ),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Row(
                                children: [
                                    Icon(
                                        Icons.calendar_month,
                                        color: primaryColor,
                                        size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                        'Date',
                                        style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                        ),
                                    ),
                                ],
                            ),
                            
                            Padding(
                                padding: const EdgeInsets.only(left: 28, top: 4, bottom: 16),
                                child: Text(
                                    DateFormat('EEEE, MMMM d, yyyy').format(_deliveryDate),
                                    style: theme.textTheme.bodyMedium,
                                ),
                            ),
                            
                            Row(
                                children: [
                                    Icon(
                                        Icons.access_time,
                                        color: primaryColor,
                                        size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                        'Time',
                                        style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                        ),
                                    ),
                                ],
                            ),
                            
                            Padding(
                                padding: const EdgeInsets.only(left: 28, top: 4),
                                child: Row(
                                    children: [
                                        Text(
                                            _deliveryTimeSlot,
                                            style: theme.textTheme.bodyMedium,
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton(
                                            onPressed: () => _showTimeSelectionModal(context, false),
                                            child: Text(
                                                'Change',
                                                style: TextStyle(
                                                    color: primaryColor,
                                                    fontWeight: FontWeight.w600,
                                                ),
                                            ),
                                            style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                minimumSize: const Size(0, 0),
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ],
                    ),
                ),
                
                const SizedBox(height: 24),
                
            ],
        );
    }
    
    Widget _buildAddressStep() {
        return AddressSelector(
            addresses: _addresses,
            selectedAddress: _address,
            onAddressSelected: (address) {
                setState(() => _address = address);
            },
            onAddAddress: _showAddAddressModal,
        );
    }
    
    Widget _buildSummaryStep(List<Service> services) {
        return OrderSummary(
            selectedServices: _selectedServices,
            allServices: services,
            pickupSlot: _pickupSlotText,
            deliverySlot: _deliverySlotText,
            address: _address,
        );
    }
    
    void _confirmBooking() async {
        // Set loading state
        setState(() {
            _isLoading = true;
        });
        
        // Simulate API call with a delay
        await Future.delayed(const Duration(seconds: 2));
        
        // Generate a random order number
        final orderNumber = 'ORD${math.Random().nextInt(900000) + 100000}';
        
        // Reset loading state
        setState(() {
            _isLoading = false;
        });
        
        // Show success modal
        if (!mounted) return;
        
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => BookingSuccessModal(
                orderNumber: orderNumber,
                services: _selectedServices,
                pickupTime: _pickupSlotText,
                deliveryTime: _deliverySlotText,
                address: _address,
                onViewOrders: () {
                    context.pop(); // Close the modal
                    context.go('/orders');
                },
                onDone: () {
                    context.pop(); // Close the modal
                    context.go('/home');
                },
            ),
        );
    }

    Future<void> _showAddAddressModal() async {
        final controller = TextEditingController();
        final theme = Theme.of(context);
        final newAddress = await showDialog<String>(
            context: context,
            builder: (context) {
                return AlertDialog(
                    title: const Text('Add New Address'),
                    content: TextField(
                        controller: controller,
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                            hintText: 'Enter pickup address',
                        ),
                        onSubmitted: (_) => Navigator.of(context).pop(controller.text.trim()),
                    ),
                    actions: [
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                            ),
                            child: const Text('Save'),
                        ),
                    ],
                );
            },
        );

        final trimmed = (newAddress ?? '').trim();
        if (trimmed.isEmpty) {
            return;
        }

        if (_addresses.contains(trimmed)) {
            setState(() => _address = trimmed);
            return;
        }

        setState(() {
            _addresses = [..._addresses, trimmed];
            _address = trimmed;
        });
    }
}
