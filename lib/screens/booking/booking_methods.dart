import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import '../../models/payment_method.dart';
import '../../providers/mock_providers.dart';
import '../../services/payment_service.dart';
import '../../widgets/booking_success_modal.dart';

// Calculate total price based on selected services
double calculateTotalPrice(WidgetRef ref, Set<String> selectedServices) {
  final services = ref.read(servicesProvider);
  double total = 0;
  for (final service in services) {
    if (selectedServices.contains(service.name)) {
      total += service.price;
    }
  }
  return total;
}

// Process payment and confirm booking
Future<void> confirmBooking({
  required BuildContext context,
  required WidgetRef ref,
  required Set<String> selectedServices,
  required String pickupSlotText,
  required String deliverySlotText,
  required String address,
  required PaymentMethod? selectedPaymentMethod,
  required Function(bool) setLoading,
}) async {
  // Check if payment method is selected
  if (selectedPaymentMethod == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select a payment method'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  
  // Set loading state
  setLoading(true);
  
  // Generate a random order number
  final orderNumber = 'ORD${math.Random().nextInt(900000) + 100000}';
  
  // Process payment
  final paymentService = ref.read(paymentServiceProvider);
  final totalPrice = calculateTotalPrice(ref, selectedServices);
  
  bool paymentSuccess = false;
  
  if (selectedPaymentMethod.type == PaymentMethodType.wallet) {
    // Pay with wallet
    paymentSuccess = await paymentService.payWithWallet(
      orderId: orderNumber,
      amount: totalPrice,
    );
  } else {
    // Process regular payment
    paymentSuccess = await paymentService.processPayment(
      orderId: orderNumber,
      amount: totalPrice,
      paymentMethodType: selectedPaymentMethod.type,
      paymentMethodId: selectedPaymentMethod.id,
    );
  }
  
  // Reset loading state
  setLoading(false);
  
  if (!paymentSuccess) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(paymentService.errorMessage ?? 'Payment failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return;
  }
  
  // Show success modal
  if (!context.mounted) return;
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => BookingSuccessModal(
      orderNumber: orderNumber,
      services: selectedServices,
      pickupTime: pickupSlotText,
      deliveryTime: deliverySlotText,
      address: address,
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

// Show add address modal
Future<String?> showAddAddressModal(BuildContext context) async {
  final controller = TextEditingController();
  final theme = Theme.of(context);
  
  return showDialog<String>(
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
}