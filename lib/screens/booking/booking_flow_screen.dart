import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/mock_providers.dart';

class BookingFlowScreen extends ConsumerStatefulWidget {
  const BookingFlowScreen({super.key});

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  int _currentStep = 0;
  final Set<String> _selectedServices = {'Wash & Fold'};
  String _pickupSlot = 'Today • 6:00 - 7:00 PM';
  String _deliverySlot = 'Tomorrow • 6:00 - 8:00 PM';
  String _address = '128 Market Street, San Francisco, CA';

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(servicesProvider);
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Pickup'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 4) {
            setState(() => _currentStep += 1);
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        controlsBuilder: (context, details) {
          final isLast = _currentStep == 4;
          return Row(
            children: [
              FilledButton(
                onPressed: details.onStepContinue,
                child: Text(isLast ? 'Confirm Booking' : 'Continue'),
              ),
              const SizedBox(width: 12),
              if (_currentStep > 0)
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Back'),
                ),
            ],
          );
        },
        steps: [
          Step(
            title: const Text('Select services'),
            isActive: _currentStep >= 0,
            content: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: services.map((service) {
                final isSelected = _selectedServices.contains(service.name);
                return FilterChip(
                  label: Text(service.name),
                  selected: isSelected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _selectedServices.add(service.name);
                      } else {
                        _selectedServices.remove(service.name);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          Step(
            title: const Text('Pickup time'),
            isActive: _currentStep >= 1,
            content: Column(
              children: [
                RadioListTile(
                  value: 'Today • 6:00 - 7:00 PM',
                  groupValue: _pickupSlot,
                  onChanged: (value) {
                    setState(() => _pickupSlot = value as String);
                  },
                  title: const Text('Today • 6:00 - 7:00 PM'),
                ),
                RadioListTile(
                  value: 'Tomorrow • 8:00 - 10:00 AM',
                  groupValue: _pickupSlot,
                  onChanged: (value) {
                    setState(() => _pickupSlot = value as String);
                  },
                  title: const Text('Tomorrow • 8:00 - 10:00 AM'),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Delivery time'),
            isActive: _currentStep >= 2,
            content: Column(
              children: [
                RadioListTile(
                  value: 'Tomorrow • 6:00 - 8:00 PM',
                  groupValue: _deliverySlot,
                  onChanged: (value) {
                    setState(() => _deliverySlot = value as String);
                  },
                  title: const Text('Tomorrow • 6:00 - 8:00 PM'),
                ),
                RadioListTile(
                  value: 'Fri • 6:00 - 8:00 PM',
                  groupValue: _deliverySlot,
                  onChanged: (value) {
                    setState(() => _deliverySlot = value as String);
                  },
                  title: const Text('Fri • 6:00 - 8:00 PM'),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Confirm address'),
            isActive: _currentStep >= 3,
            content: DropdownButtonFormField<String>(
              value: _address,
              decoration: const InputDecoration(labelText: 'Pickup address'),
              items: user.addresses
                  .map((address) => DropdownMenuItem(
                        value: address,
                        child: Text(address),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _address = value);
                }
              },
            ),
          ),
          Step(
            title: const Text('Order summary'),
            isActive: _currentStep >= 4,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected services',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ..._selectedServices
                    .map((service) => Text('• $service'))
                    .toList(),
                const SizedBox(height: 12),
                Text('Pickup: $_pickupSlot'),
                Text('Delivery: $_deliverySlot'),
                const SizedBox(height: 12),
                Text('Address: $_address'),
                const SizedBox(height: 12),
                Text(
                  'Total: \$48',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
