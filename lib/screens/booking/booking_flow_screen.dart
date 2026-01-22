import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'package:aspro_app/l10n/app_localizations.dart';

import '../../data/mock/mock_data.dart';
import '../../providers/mock_providers.dart';
import '../../widgets/booking_step_indicator.dart';
import '../../widgets/service_card.dart';
import '../../widgets/time_slot_selector.dart';
import '../../widgets/address_selector.dart';
import '../../widgets/order_summary.dart';
import '../../widgets/enhanced_button.dart';
import '../../widgets/booking_success_modal.dart';
import '../../models/service.dart';

class BookingFlowScreen extends ConsumerStatefulWidget {
    const BookingFlowScreen({super.key});

    @override
    ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
    int _currentStep = 0;
    final Set<String> _selectedServices = {'Wash & Fold'};
    String _pickupSlotId = 'pickup_today';
    String _deliverySlotId = 'delivery_tomorrow';
    String _address = '128 Market Street, San Francisco, CA';
    bool _isLoading = false;
    late List<String> _addresses;
    
    List<String> _steps(AppLocalizations l10n) => [
        l10n.bookingStepServices,
        l10n.bookingStepPickup,
        l10n.bookingStepDelivery,
        l10n.bookingStepAddress,
        l10n.bookingStepSummary,
    ];

    List<TimeSlot> _pickupSlots(AppLocalizations l10n) => [
        TimeSlot(
            id: 'pickup_today',
            displayText: '${l10n.today} • 6:00 - 7:00 PM',
            day: l10n.today,
            timeRange: '6:00 - 7:00 PM',
        ),
        TimeSlot(
            id: 'pickup_tomorrow',
            displayText: '${l10n.tomorrow} • 8:00 - 10:00 AM',
            day: l10n.tomorrow,
            timeRange: '8:00 - 10:00 AM',
        ),
    ];

    List<TimeSlot> _deliverySlots(AppLocalizations l10n) => [
        TimeSlot(
            id: 'delivery_tomorrow',
            displayText: '${l10n.tomorrow} • 6:00 - 8:00 PM',
            day: l10n.tomorrow,
            timeRange: '6:00 - 8:00 PM',
        ),
        TimeSlot(
            id: 'delivery_friday',
            displayText: '${l10n.fridayShort} • 6:00 - 8:00 PM',
            day: l10n.fridayShort,
            timeRange: '6:00 - 8:00 PM',
        ),
    ];

    String _pickupSlotText(AppLocalizations l10n) => _pickupSlots(l10n)
        .firstWhere((slot) => slot.id == _pickupSlotId)
        .displayText;

    String _deliverySlotText(AppLocalizations l10n) => _deliverySlots(l10n)
        .firstWhere((slot) => slot.id == _deliverySlotId)
        .displayText;

    @override
    void initState() {
        super.initState();
        final authState = ref.read(authProvider);
        final fallbackAddresses = MockData.user.addresses;
        _addresses = List.of(authState.currentUser?.addresses ?? fallbackAddresses);
        if (_addresses.isNotEmpty && !_addresses.contains(_address)) {
            _address = _addresses.first;
        }
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
        final primaryColor = const Color(0xFF2196F3); // Material Blue 500
        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
            appBar: AppBar(
                title: Text(l10n.bookingTitle),
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
                            steps: _steps(l10n),
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
                                            label: l10n.back,
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
                                                            l10n.processing,
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
                                            label: _currentStep == 4 ? l10n.confirmBooking : l10n.continueLabel,
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
        final l10n = AppLocalizations.of(context)!;
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                        l10n.selectServicesTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                        ),
                    ),
                ),
                
                Text(
                    l10n.selectServicesSubtitle,
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
    
    Widget _buildPickupTimeStep() {
        final l10n = AppLocalizations.of(context)!;
        return TimeSlotSelector(
            title: l10n.selectPickupTimeTitle,
            timeSlots: _pickupSlots(l10n),
            selectedSlotId: _pickupSlotId,
            onSlotSelected: (id) {
                setState(() => _pickupSlotId = id);
            },
        );
    }
    
    Widget _buildDeliveryTimeStep() {
        final l10n = AppLocalizations.of(context)!;
        return TimeSlotSelector(
            title: l10n.selectDeliveryTimeTitle,
            timeSlots: _deliverySlots(l10n),
            selectedSlotId: _deliverySlotId,
            onSlotSelected: (id) {
                setState(() => _deliverySlotId = id);
            },
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
        final l10n = AppLocalizations.of(context)!;
        return OrderSummary(
            selectedServices: _selectedServices,
            allServices: services,
            pickupSlot: _pickupSlotText(l10n),
            deliverySlot: _deliverySlotText(l10n),
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
        final l10n = AppLocalizations.of(context)!;
        
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => BookingSuccessModal(
                orderNumber: orderNumber,
                services: _selectedServices,
                pickupTime: _pickupSlotText(l10n),
                deliveryTime: _deliverySlotText(l10n),
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
        final l10n = AppLocalizations.of(context)!;
        final newAddress = await showDialog<String>(
            context: context,
            builder: (context) {
                return AlertDialog(
                    title: Text(l10n.addAddressTitle),
                    content: TextField(
                        controller: controller,
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                            hintText: l10n.addAddressHint,
                        ),
                        onSubmitted: (_) => Navigator.of(context).pop(controller.text.trim()),
                    ),
                    actions: [
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(l10n.cancel),
                        ),
                        ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                            ),
                            child: Text(l10n.save),
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
